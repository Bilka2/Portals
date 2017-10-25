--Makes lists of portals and labels and unit_numbers on init
script.on_init(function()
	global.a_portals = {} --list[player_index] = portal
	global.b_portals = {} --list[player_index] = portal
	global.a_labels = {} --list[player_index] = label 
	global.b_labels = {} --list[player_index] = label 
	global.a_numbers = {} --list[unit_number] = player_index
	global.b_numbers = {} --list[unit_number] = player_index
	global.teleport_delay = {} --list[player_index] = game.tick + 47
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
end)


--destroy the animation of the base entity when given the base entity surface and position, and which animation to destroy:
local function destroy_ani(surface, pos, which)
	local entities = surface.find_entities_filtered{area={{pos.x-0.1,pos.y+0.9}, {pos.x+0.1,pos.y+1.1}}, name=which} --find the animation
	if type(entities[1]) ~= "nil"  and entities[1].valid then entities[1].destroy() end --if the variable in the table is not of the type nil then destroy it
end

--destroy the label of the base entity when given the list the label is in and its text:
local function destroy_label(list, player_index)
	local label = list[player_index]
	if label and label.valid then 
		list[player_index] = nil --remove label from list
		label.destroy()
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
		elseif list == global.b_portals then
		destroy_label(global.b_labels, player_index)
		end
		if list == global.a_portals then
			global.a_numbers[base.unit_number] = nil --that portal is no longer associated with a player_index
		elseif list == global.b_portals then
			global.b_numbers[base.unit_number] = nil
		end
		list[player_index] = nil --remove the base from the list
		base.destroy()
	end
end

local function build_portal(player, base, ani, pos, list, player_index)
	player.surface.create_entity{name = ani, position = {pos.x, pos.y+1}} --creates portal animation
	local portal = player.surface.create_entity{name = base, position = pos, force = player.force} --creates new portal-base
	portal.operable = false
	portal.destructible = false
	destroy_other_portal(list, player_index, ani)
	list[player_index] = portal --adds new portal to list, sorted by player_index
	local portal_colour = {}
	if base == "portal-a" then portal_colour = {r = 1, g = 0.55, b = 0.1} end --orange portals get orange number
	if base == "portal-b" then portal_colour = {r = 0.5, g = 0.5, b = 1} end --blue portals get blue number
	local label = player.surface.create_entity({name="portal-label", position={pos.x-0.5, pos.y-0.9}, text=player_index, color=portal_colour}) --creates portal text
	label.active = false
	--adds new label to the list, sorted by player_index:
	if list == global.a_portals then 
		global.a_labels[player_index] = label 
		global.a_numbers[portal.unit_number] = player_index --save the player_index that is associated with this portal
	elseif list == global.b_portals then
		global.b_labels[player_index] = label
		global.b_numbers[portal.unit_number] = player_index
	end
end

--Creates portal-b when portal is ghost-placed, creates portal-a when portal is normally placed:
script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.type == "entity-ghost" and event.created_entity.ghost_name == "portal" then --is portal ghost-placed?
		local new_position = event.created_entity.position
		local player = game.players[event.player_index]
		if settings.global["portals-disable-long-distance-placing"].value then
			local max_dist = player.build_distance
			local X = new_position.x
			local Y = new_position.y
			local pY=player.position.y
			local pX=player.position.x
			event.created_entity.destroy() --destroy portal which is just a placeholder entitiy
			if X>=pX-max_dist and X<=pX+max_dist and Y>=pY-max_dist and Y<=pY+max_dist then
				player.surface.create_entity{name = "portalgun-shoot-b", position = new_position}
				build_portal(player, "portal-b", "portal-animation-b", new_position, global.b_portals, event.player_index)
			end
		else
			player.surface.create_entity{name = "portalgun-shoot-b", position = new_position}
			build_portal(player, "portal-b", "portal-animation-b", new_position, global.b_portals, event.player_index)
		end
	elseif event.created_entity.name == "portal" then --is portal normally placed?
		local new_position = event.created_entity.position
		local player = game.players[event.player_index]
		event.created_entity.destroy() --destroy portal which is just a placeholder entity
		player.cursor_stack.set_stack{name="portal-gun", count = 1} --make player hold one portal gun, does not care if player already holds portal guns
		player.surface.create_entity{name = "portalgun-shoot-a", position = new_position}
		build_portal(player, "portal-a", "portal-animation-a", new_position, global.a_portals, event.player_index)
	end
end)

--when player mines portal, remove the dropped item from the players inventory
script.on_event(defines.events.on_player_mined_item, function (event)
	if event.item_stack.name == "portal-drop" then --did player mine portal?
		game.players[event.player_index].remove_item(event.item_stack) --remove item dropped by portal from mining player inventory
	end
end)

--when base is mined, destroy animation and label:
script.on_event(defines.events.on_preplayer_mined_item, function (event)
	local entity = event.entity
	local pos = entity.position
	local surface = game.players[event.player_index].surface
	if entity.name == "portal-a" then
		destroy_ani(surface, pos, "portal-animation-a")
		local player_index = global.a_numbers[entity.unit_number] --find the player_index associated with that portal
		destroy_label(global.a_labels, player_index)
		global.a_portals[player_index] = nil --remove the base from the list
		global.a_numbers[entity.unit_number] = nil --that portal is no longer associated with a player_index
	elseif entity.name == "portal-b" then
		destroy_ani(surface, pos, "portal-animation-b")
		local player_index = global.b_numbers[entity.unit_number]
		destroy_label(global.b_labels, player_index)
		global.b_portals[player_index] = nil
		global.b_numbers[entity.unit_number] = nil
	end	
end)


--Events that run every tick/often: TELEPORTING THE PLAYER

local function on_portal(player, portal)
	local player_pos = player.position
	local entities = player.surface.find_entities_filtered{area={{player_pos.x-0.7,player_pos.y-0.3}, {player_pos.x+0.7,player_pos.y+0.1}}, name = portal}
	if entities[1] and entities[1].valid then
		return entities[1]
	else
		return false
	end
end
    
local function try_teleport(player, exit_portal)	
	local tick = game.tick
	if exit_portal and exit_portal.valid then --does that base exist and is it valid?
		if (not global.teleport_delay[player.index]) or global.teleport_delay[player.index] < tick then
			player.surface.create_entity({name="portal-enter", position=player.position})
			player.teleport({exit_portal.position.x, exit_portal.position.y-0.9}, exit_portal.surface) --teleport player to the top of the exit_portal entity
			exit_portal.surface.create_entity({name="portal-exit", position=exit_portal.position})
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
				try_teleport(player, global.b_portals[player_index_1]) --teleport to the b_portal with the same associated player_index as the portal the player is on
			else
				local entry_portal_2 = on_portal(player, "portal-b")
				if entry_portal_2 then --if on portal then teleport to other portal
					local player_index_2 = global.b_numbers[entry_portal_2.unit_number]
					try_teleport(player, global.a_portals[player_index_2]) --teleport to the b_portal with the same associated player_index as the portal the player is on
				end
			end
		end
	end
end)
