-- CUSTOM EVENT HANDLING --
--(remote interface is lower in the file, there I describe how to subscribe to my events)
local on_player_teleported_event = script.generate_event_name() --uint
local on_player_placed_portal_event = script.generate_event_name()


-- UTILITIES --
--get the portal this one is connected to
local function get_opposite_portal(entity)
	for _, v in pairs(global.portals) do
		if v.b and v.b == entity then
			if v.a and v.a.valid then return v.a end
		elseif v.a and v.a == entity then
			if v.b and v.b.valid then return v.b end
		end
	end
end

--get a portal if you know which one you want and who owns it
local function get_players_portal(player_index, portal_type) -- example: 1, "a"   --DOES NOT CHECK .VALID!!!
	return global.portals[player_index] and global.portals[player_index][portal_type] or nil
end

--gets which type the portal is (portal-a is a, portal-b is b)
local function get_portals_type(entity)
	return entity.name:match(%-[ab])
end

--gets the player_index of the owner of the portal
local function get_portals_owner(entity)
	for player_index, table in pairs(global.portals) do
		if (table.a and table.a == entity) or (table.b and table.b == entity) then
			return player_index
		end
	end
end

--save the portal in the global table
local function save_portal(player_index, portal_type, entity)
	global.portals[player_index] = global.portals[player_index] or {}
	global.portals[player_index][portal_type] = entity
end


-- BUILDING AND REMOVING --
--destroy the label of the base entity when given the base entity surface and position:
local function destroy_label(surface, pos)
	local label = surface.find_entities_filtered{area={{pos.x-0.5, pos.y-1}, {pos.x-0.3, pos.y-0.8}}, name="portal-label", limit = 1}[1] --find the label
	if label then label.destroy() end
end

--destroy the old portal with that associated player_index, needs which type the portal is of
local function destroy_other_portal(player_index, portal_type)
	local portal = get_players_portal(player_index, portal_type)
	if portal then
		if portal.valid then
			destroy_label(portal.surface, portal.position)
			portal.destroy()
		end
		global.portals[player_index][portal_type] = nil --remove the portal from the list
	end
end

local function build_portal(player, surface, pos, portal_type, by_player)
	local portal = surface.create_entity{name = "portal-" .. portal_type, position = pos, force = player.force} --creates new portal-base
	if by_player then
		script.raise_event(on_player_placed_portal_event, {player_index = player.index, portal = portal})
	end
	portal.operable = false
	portal.destructible = false
	destroy_other_portal(player.index, portal_type)
	save_portal(player.index, portal_type, portal)
	local portal_colour = {}
	if portal_type == "a" then portal_colour = {r = 1, g = 0.55, b = 0.1} end --orange portals get orange number
	if portal_type == "b" then portal_colour = {r = 0.5, g = 0.5, b = 1} end --blue portals get blue number
	surface.create_entity({name="portal-label", position={pos.x-0.5, pos.y-1}, text=player.index, color=portal_colour}) --creates portal text
end

--Creates portal-b when portal is ghost-placed, creates portal-a when portal is normally placed:
script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.type == "entity-ghost" and event.created_entity.ghost_name == "portal" then --is portal ghost-placed?
		local new_position = event.created_entity.position
		local player = game.players[event.player_index]
		if global.disable_long_distance_placing or settings.global["portals-disable-long-distance-placing"].value then
			local max_dist = player.build_distance
			local X = new_position.x
			local Y = new_position.y
			local pY=player.position.y
			local pX=player.position.x
			event.created_entity.destroy() --destroy portal which is just a placeholder entitiy
			if X>=pX-max_dist and X<=pX+max_dist and Y>=pY-max_dist and Y<=pY+max_dist then
				player.surface.play_sound{path = "portalgun-shoot-b", position = new_position}
				build_portal(player, player.surface, new_position, "b", true)
			end
		else
			player.surface.play_sound{path = "portalgun-shoot-b", position = new_position}
			build_portal(player, player.surface, new_position, "b", true)
		end
	elseif event.created_entity.name == "portal" then --is portal normally placed?
		local new_position = event.created_entity.position
		local player = game.players[event.player_index]
		event.created_entity.destroy() --destroy portal which is just a placeholder entity
		player.cursor_stack.set_stack{name="portal-gun", count = 1} --make player hold one portal gun, does not care if player already holds portal guns
		player.surface.play_sound{path = "portalgun-shoot-a", position = new_position}
		build_portal(player, player.surface, new_position, "a", true)
	end
end)

--destroy label and base if the base entity is given
local function destroy_portal_from_base(entity)
	if not entity.name:find("portal") then return end
	global.portals[get_portals_owner(entity)][get_portals_type(entity)] = nil --remove the portal from the list
	if entity.valid then
		destroy_label(entity.surface, entity.position)
		entity.destroy()
	end
end

--when base is mined/dies, destroy label, and base:
script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_entity_died}, function (event)
	destroy_portal_from_base(event.entity)
end)


-- Events that run every tick/often: TELEPORTING THE PLAYER --
local function on_portal(player)
	local player_pos = player.position
	local entity = player.surface.find_entities_filtered{area={{player_pos.x-0.7,player_pos.y-0.3}, {player_pos.x+0.7,player_pos.y+0.1}}, type = "simple-entity-with-owner", force = player.force, limit = 1}[1]
	if entity and entity.name:find("portal") then
		return entity
	end
end
    
local function try_teleport(player, exit_portal, entrance_portal)	
	local tick = game.tick
	if exit_portal then
		if (not global.teleport_delay[player.index]) or global.teleport_delay[player.index] < tick then
			script.raise_event(on_player_teleported_event, {player_index = player.index, entrance_portal = entrance_portal, target_portal = exit_portal})
			player.surface.play_sound({path="portal-enter", position=player.position})
			player.teleport({exit_portal.position.x, exit_portal.position.y-0.9}, exit_portal.surface) --teleport player to the top of the exit_portal entity
			exit_portal.surface.play_sound({path="portal-exit", position=exit_portal.position})
			global.teleport_delay[player.index] = tick + 47
		end
	end
end

--tries to teleport when player connected, has character, not in vehicle:
script.on_event(defines.events.on_player_changed_position, function(event)
	for index, player in pairs(game.connected_players) do
		if player.character and not player.vehicle then --checks if player has a character (not god mode) and isn't in an vehicle
			local portal = on_portal(player)
			if portal then
				try_teleport(player, get_opposite_portal(portal), portal)
			end
		end
	end
end)


-- INIT --
--Makes lists of portals on init
script.on_init(function()
	global.portals = {} --list[player_index] = {a = LuaEntity, b = LuaEntity}
	global.teleport_delay = {} --list[player_index] = game.tick + 47
	global.disable_long_distance_placing = false
end)

script.on_configuration_changed(function(event)	
	if not event.mod_changes["Portals"] then return end
	global.teleport_delay = global.teleport_delay or {}
	global.disable_long_distance_placing = global.disable_long_distance_placing or false
	
	local old_version = event.mod_changes["Portals"].old_version
	--no migration from <= 0.2.3
	if old_version:match("^0.1") then
		error("Migrating from versions older than 0.2.3 of the mod is not supported. Use version 0.2.5 to migrate from those version and then use this version again.")
	end
	local bad_versions = {"0.2.1", "0.2.2", "0.2.3"}
	for _, v in pairs(bad_versions) do
		if old_version == v then
			error("Migrating from versions older than 0.2.3 of the mod is not supported. Use version 0.2.5 to migrate from those version and then use this version again.")
		end
	end
	
	global.portals = {}
	for _, surface in pairs(game.surfaces) do
		local entities = surface.find_entities_filtered{name="portal-a"}
		if  not entities then return end
		for _, entity in pairs(entities) do
			local pos = entity.position
			local label_text = surface.find_entities_filtered{area={{pos.x-0.5, pos.y-1}, {pos.x-0.3, pos.y-0.8}}, name="portal-label", limit = 1}[1].text
			if label_text then
				save_portal(tonumber(label_text), "a", entity)
			end
		end
		local entities = surface.find_entities_filtered{name="portal-b"}
		if  not entities then return end
		for _, entity in pairs(entities) do
			local pos = entity.position
			local label_text = surface.find_entities_filtered{area={{pos.x-0.5, pos.y-1}, {pos.x-0.3, pos.y-0.8}}, name="portal-label", limit = 1}[1].text
			if label_text then
				save_portal(tonumber(label_text), "b", entity)
			end
		end
	end
	global.a_portals = nil
	global.b_portals = nil
	global.a_numbers = nil
	global.b_numbers = nil
end)

remote.add_interface("portals",
{
--[[subscribing to my events:

	script.on_event(remote.call("portals", "get_on_player_teleported_event"), function(event)
		--do your stuff
	end)
	WARNING: this has to be done within on_init and on_load, otherwise the game will error about the remote.call

	
	if your dependency on my mod is optional and/or does not specify that version >= 0.2.8, remember to check if the remote interface exists before calling it:
	if remote.interfaces["portals"] then
		--interface exists
	end]]


	get_on_player_placed_portal_event = function() return on_player_placed_portal_event end,
		-- event.portal = LuaEntity, the portal that was placed
		-- event.player_index = Index of the player that placed the portal, which is the player the portal belongs to
	get_on_player_teleported_event = function() return on_player_teleported_event end,
		-- event.player_index = Index of the player that is teleporting
		-- event.entrance_portal = LuaEntity, the portal the player is teleporting from
		-- event.target_portal = LuaEntity, the portal the player is teleporting to
	build_portal_a = function(player, surface, position) build_portal(player, surface, position, "a", false) end, --orange portal
		-- position: Position of the new portal
		-- surface: LuaSurface, the surface of the new portal
		-- player: LuaPlayer that the portal belongs to. This player can't have more than one pair, build_portal will delete any excess portals
	build_portal_b = function(player, surface, position) build_portal(player, surface, position, "b", false) end, --blue portal
		-- position: Position of the new portal
		-- surface: LuaSurface, the surface of the new portal
		-- player: LuaPlayer that the portal belongs to. This player can't have more than one pair, build_portal will delete any excess portals
	destroy_portal = function(entity) destroy_portal_from_base(entity) end,
		-- entity: LuaEntity, the portal to destroy
	disable_long_distance_placing = function(bool) global.disable_long_distance_placing = bool end
		-- whether the blue portal can be placed from a long distance. If this is true the player can never place from a long distance, if it is false, the player can place from a long distance depending on the mod option
	
	-- some examples --
	--/c remote.call("portals", "build_portal_b", game.player, game.player.surface, game.player.position)
	--/c remote.call("portals", "destroy_portal", game.player.selected)
	--/c remote.call("portals", "disable_long_distance_placing", true)
})
