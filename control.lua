--Makes lists of portals and labels and unit_numbers on init
script.on_init(function()
	global.a_portals = {} --list[player_index] = portal
	global.b_portals = {} --list[player_index] = portal
	global.a_labels = {} --list[player_index] = label 
	global.b_labels = {} --list[player_index] = label 
	global.a_numbers = {} --list[unit_number] = player_index
	global.b_numbers = {} --list[unit_number] = player_index
	global.teleport_delay = {} --list[player_index] = game.tick + 47
	global.disable_long_distance_placing = false
end)

script.on_configuration_changed(function()
	if not global.a_numbers then --both a and b numbers don't exist then because they were added in the same version
		--since the number tables didn't exist I also have to migrate to the new entity for the portal bases... now called portal (yes, just portal) 
		local a_portals = {}
		for index,portal in pairs(global.a_portals) do
			if portal.valid then
				local new_portal = portal.surface.create_entity{name ="portal-a", position = portal.position, force = portal.force}
				new_portal.operable = false
				new_portal.destructible = false
				portal.destroy()
				local new_index = tonumber(index)
				a_portals[new_index] = new_portal
			end
		end
		global.a_portals = a_portals
		local b_portals = {}
		for index,portal in pairs(global.b_portals) do
			if portal.valid then
				local new_portal = portal.surface.create_entity{name ="portal-b", position = portal.position, force = portal.force}
				new_portal.operable = false
				new_portal.destructible = false
				portal.destroy()
				local new_index = tonumber(index)
				b_portals[new_index] = new_portal
			end
		end
		global.b_portals = b_portals
		
		--make indexes integers not strings, also replace the flying text with a one with a custom name so that it gets removed correctly when the mod is removed
		local a_labels = {}
		for index,label in pairs(global.a_labels) do
			if label.valid then
				local new_label = label.surface.create_entity({name="portal-label", position=label.position, text=label.text, color=label.color})
				new_label.active = false
				label.destroy()
				local new_index = tonumber(index)
				a_labels[new_index] = new_label
			end
		end
		global.a_labels = a_labels
		local b_labels = {}
		for index,label in pairs(global.b_labels) do
			if label.valid then
				local new_label = label.surface.create_entity({name="portal-label", position=label.position, text=label.text, color=label.color})
				new_label.active = false
				label.destroy()
				local new_index = tonumber(index)
				b_labels[new_index] = new_label
			end
		end
		global.b_labels = b_labels
		
		--add the unit numbers for the portals when migrating from version 0.2.4 or lower which used backer_name instead
		global.a_numbers = {} 
		for key,portal in pairs(global.a_portals) do
			global.a_numbers[portal.unit_number] = key
		end
		global.b_numbers = {}
		for key,portal in pairs(global.b_portals) do
			global.b_numbers[portal.unit_number] = key
		end
	end
	global.teleport_delay = global.teleport_delay or {}
	global.disable_long_distance_placing = global.disable_long_distance_placing or false
end)



-- CUSTOM EVENT HANDLING --
--(remote interface is lower in the file, there I describe how to subscribe to my events)
local on_player_teleported_event = script.generate_event_name() --uint
local on_player_placed_portal_event = script.generate_event_name()


--destroy the animation of the base entity when given the base entity surface and position, and which animation to destroy:
local function destroy_ani(surface, pos, which)
	local ani = surface.find_entities_filtered{area={{pos.x-0.1,pos.y+0.9}, {pos.x+0.1,pos.y+1.1}}, name=which, limit = 1}[1] --find the animation
	if ani then ani.destroy() end
end

--destroy the label of the base entity when given the list the label is in and its text:
local function destroy_label(list, player_index)
	local label = list[player_index]
	if label and label.valid then 
		list[player_index] = nil --remove label from list
		label.destroy()
	elseif label then
		list[player_index] = nil --remove label from list because it's not valid
	end
end

--destroy the old portal with that associated player_index, needs the list the portal is in and the animation.name
local function destroy_other_portal(list, player_index, ani)
	local base = list[player_index]
	if base and base.valid then --is there a already existing portal-base with the same associated player_index? 
		destroy_ani(base.surface, base.position, ani) --find the animation of the base and destroy it
		--find the label and destroy it:
		if list == global.a_portals then 
			destroy_label(global.a_labels, player_index)
			global.a_numbers[base.unit_number] = nil --that portal is no longer associated with a player_index
		elseif list == global.b_portals then
			destroy_label(global.b_labels, player_index)
			global.b_numbers[base.unit_number] = nil
		end
		list[player_index] = nil --remove the base from the list
		base.destroy()
	elseif base then
		if list == global.a_portals then
			global.a_numbers[base.unit_number] = nil --that portal is no longer associated with a player_index
		elseif list == global.b_portals then
			global.b_numbers[base.unit_number] = nil
		end
		list[player_index] = nil --remove the base from the list because it's not valid
	end
end

local function build_portal(player, surface, base, ani, pos, list, by_player)
	surface.create_entity{name = ani, position = {pos.x, pos.y+1}} --creates portal animation
	local portal = surface.create_entity{name = base, position = pos, force = player.force} --creates new portal-base
	if by_player then
		script.raise_event(on_player_placed_portal_event, {player_index = player.index, portal = portal})
	end
	portal.operable = false
	portal.destructible = false
	destroy_other_portal(list, player.index, ani)
	list[player.index] = portal --adds new portal to list, sorted by player_index
	local portal_colour = {}
	if base == "portal-a" then portal_colour = {r = 1, g = 0.55, b = 0.1} end --orange portals get orange number
	if base == "portal-b" then portal_colour = {r = 0.5, g = 0.5, b = 1} end --blue portals get blue number
	local label = surface.create_entity({name="portal-label", position={pos.x-0.5, pos.y-0.9}, text=player.index, color=portal_colour}) --creates portal text
	label.active = false
	--adds new label to the list, sorted by player_index:
	if list == global.a_portals then 
		global.a_labels[player.index] = label 
		global.a_numbers[portal.unit_number] = player.index --save the player_index that is associated with this portal
	elseif list == global.b_portals then
		global.b_labels[player.index] = label
		global.b_numbers[portal.unit_number] = player.index
	end
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
				build_portal(player, player.surface, "portal-b", "portal-animation-b", new_position, global.b_portals, true)
			end
		else
			player.surface.play_sound{path = "portalgun-shoot-b", position = new_position}
			build_portal(player, player.surface, "portal-b", "portal-animation-b", new_position, global.b_portals, true)
		end
	elseif event.created_entity.name == "portal" then --is portal normally placed?
		local new_position = event.created_entity.position
		local player = game.players[event.player_index]
		event.created_entity.destroy() --destroy portal which is just a placeholder entity
		player.cursor_stack.set_stack{name="portal-gun", count = 1} --make player hold one portal gun, does not care if player already holds portal guns
		player.surface.play_sound{path = "portalgun-shoot-a", position = new_position}
		build_portal(player, player.surface, "portal-a", "portal-animation-a", new_position, global.a_portals, true)
	end
end)

--destroy animation, label, and base if the base entity is given
local function destroy_portal_from_base(entity)
	local pos = entity.position
	local surface = entity.surface
	if entity.name == "portal-a" then
		destroy_ani(surface, pos, "portal-animation-a")
		local player_index = global.a_numbers[entity.unit_number] --find the player_index associated with that portal
		destroy_label(global.a_labels, player_index)
		global.a_portals[player_index] = nil --remove the base from the list
		global.a_numbers[entity.unit_number] = nil --that portal is no longer associated with a player_index
		if entity.valid then entity.destroy() end
	elseif entity.name == "portal-b" then
		destroy_ani(surface, pos, "portal-animation-b")
		local player_index = global.b_numbers[entity.unit_number]
		destroy_label(global.b_labels, player_index)
		global.b_portals[player_index] = nil
		global.b_numbers[entity.unit_number] = nil
		if entity.valid then entity.destroy() end
	end
end

--when base is mined/dies, destroy animation and label, and base:
script.on_event({defines.events.on_preplayer_mined_item, defines.events.on_entity_died}, function (event)
	local entity = event.entity
	destroy_portal_from_base(entity)
end)


--Events that run every tick/often: TELEPORTING THE PLAYER

local function on_portal(player, portal)
	local player_pos = player.position
	return player.surface.find_entities_filtered{area={{player_pos.x-0.7,player_pos.y-0.3}, {player_pos.x+0.7,player_pos.y+0.1}}, name = portal, force = player.force, limit = 1}[1]
end
    
local function try_teleport(player, exit_portal, entrance_portal)	
	local tick = game.tick
	if exit_portal and exit_portal.valid then
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
script.on_event(defines.events.on_tick, function(event)
	if event.tick % 2 ~= 0 then return end --if it's not divisible by 2 end function 
	for index, player in pairs(game.connected_players) do
		if player.character and not player.vehicle then --checks if player has a character (not god mode) and isn't in an vehicle
			local entry_portal_1 = on_portal(player, "portal-a")
			if entry_portal_1 then --if on portal then teleport to other portal
				local player_index_1 = global.a_numbers[entry_portal_1.unit_number]
				try_teleport(player, global.b_portals[player_index_1], entry_portal_1) --teleport to the b_portal with the same associated player_index as the portal the player is on
			else
				local entry_portal_2 = on_portal(player, "portal-b")
				if entry_portal_2 then --if on portal then teleport to other portal
					local player_index_2 = global.b_numbers[entry_portal_2.unit_number]
					try_teleport(player, global.a_portals[player_index_2], entry_portal_2) --teleport to the b_portal with the same associated player_index as the portal the player is on
				end
			end
		end
	end
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
	build_portal_a = function(player, surface, position) build_portal(player, surface, "portal-a", "portal-animation-a", position, global.a_portals, false) end, --orange portal
		-- position: Position of the new portal
		-- surface: LuaSurface, the surface of the new portal
		-- player: LuaPlayer that the portal belongs to. This player can't have more than one pair, build_portal will delete any excess portals
	build_portal_b = function(player, surface, position) build_portal(player, surface, "portal-b", "portal-animation-b", position, global.b_portals, false) end, --blue portal
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
