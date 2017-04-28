--Makes lists of portals on init

script.on_init(function() -- All globals are tables, entities are saved in them by entity.backer_name (except for teleport delay which actually uses player.index)
	global.a_portals = {}
	global.b_portals = {}
	global.a_labels = {}
	global.b_labels = {}
	global.teleport_delay = {}
end)

script.on_configuration_changed(function() --initialize new globals when mod version changes
	global.teleport_delay = global.teleport_delay or {}
end)

--Creates portal-2 when portal is ghost-placed, creates portal-1 when portal is normally placed:
script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.type == "entity-ghost" and event.created_entity.ghost_name == "portal" then --is portal ghost-placed?
		local new_position = event.created_entity.position
		local player = game.players[event.player_index]
		event.created_entity.destroy() --destroy portal which is just a placeholder entitiy
		build_portal(player, "portal-base-b", "portal-animation-b", new_position, global.b_portals, event.player_index)
	elseif event.created_entity.name == "portal" then --is portal normally placed?
		local new_position = event.created_entity.position
		local player = game.players[event.player_index]
		event.created_entity.destroy() --destroy portal which is just a placeholder entity
		player.cursor_stack.set_stack{name="portal-gun", count = 1} --make player hold one portal gun, does not care if player already holds portal guns
		build_portal(player, "portal-base-a", "portal-animation-a", new_position, global.a_portals, event.player_index)
	end
end)

function build_portal(player, base, ani, pos, list, backer_name)
	player.surface.create_entity{name = ani, position = {pos.x, pos.y+1}} --creates portal animation
	local portal = player.surface.create_entity{name = base, position = pos, force = player.force} --creates new portal-base
	portal.operable = false
	portal.destructible = false
	portal.backer_name = backer_name
	destroy_other_portal(list, portal.backer_name, ani)
	list[portal.backer_name] = portal --adds new portal to list, sorted by backer_name
	if base == "portal-base-a" then portal_colour = {r = 1, g = 0.55, b = 0.1} end --orange portals get orange number
	if base == "portal-base-b" then portal_colour = {r = 0.5, g = 0.5, b = 1} end --blue portals get blue number
	local label = player.surface.create_entity({name="flying-text", position={pos.x-0.5, pos.y-0.9}, text=backer_name, color=portal_colour}) --creates portal text
	label.active = false
	--adds new label to the list, sorted by backer_name:
	if list == global.a_portals then 
	global.a_labels[portal.backer_name] = label 
	elseif list == global.b_portals then
	global.b_labels[portal.backer_name] = label
	end
end

--destroy the old portal with that backer_name, needs the list the portal is in and the animation.name
function destroy_other_portal(list, backer_name, ani)
	local base = list[backer_name]
	if base and base.valid then --is there a already existing portal-base with the same backer_name? 
		destroy_ani(base.surface, base.position, ani) --find the animation of the base and destroy it
		--find the label and destroy it:
		if list == global.a_portals then 
		destroy_label(global.a_labels, backer_name)
		elseif list == global.b_portals then
		destroy_label(global.b_labels, backer_name)
		end
		list[backer_name] = nil --remove the base from the list
		base.destroy()
	end
end

--destroy the animation of the base entity when given the base entity surface and position, and which animation to destroy:
function destroy_ani(surface, pos, which)
	local entities = surface.find_entities_filtered{area={{pos.x-0.1,pos.y+0.9}, {pos.x+0.1,pos.y+1.1}}, name=which} --find the animation
	if type(entities[1]) ~= "nil"  and entities[1].valid then entities[1].destroy() end --if the variable in the table is not of the type nil then destroy it
end

--destroy the label of the base entity when given the list the label is in and its text:
function destroy_label(list, backer_name)
	local label = list[backer_name]
	if label and label.valid then 
		list[backer_name] = nil --remove label from list
		label.destroy()
	end
end

--when player mines portal, removed the dropped item from the players inventory
script.on_event(defines.events.on_player_mined_item, function (event)
	if event.item_stack.name == "portal-drop" then --did player mine portal?
		game.players[event.player_index].remove_item(event.item_stack) --remove item dropped by portal from mining player inventory
	end
end)

--when base is mined, destroy animation and label:
script.on_event(defines.events.on_preplayer_mined_item, function (event)
	local pos = event.entity.position
	local surface = game.players[event.player_index].surface
	if event.entity.name == "portal-base-a" then
		destroy_ani(surface, pos, "portal-animation-a")
		destroy_label(global.a_labels, event.entity.backer_name)
	end
	if event.entity.name == "portal-base-b" then
		destroy_ani(surface, pos, "portal-animation-b")
		destroy_label(global.b_labels, event.entity.backer_name)
	end	
end)

--Events that run every tick/often: TELEPORTING THE PLAYER

--tries to teleport when player connected, has character, not in vehicle:
script.on_event(defines.events.on_tick, function(event)
if event.tick % 4 ~= 0 then return end --if it's not divisible by 5 end function 
	for index, player in pairs(game.connected_players) do --for connected player do stuff
		if player.character and not player.vehicle then --checks if player has a character (not god mode) and isn't in an vehicle
			local entry_portal_1 = on_portal(player, "portal-base-a") --returns the portal entity the player is on or false
			if entry_portal_1 then -- checks if the player is on an entry_portal_1
				try_teleport(player, global.b_portals[entry_portal_1.backer_name]) --teleport to the b_portal with the same backer_name as the portal the player is on
			else
				local entry_portal_2 = on_portal(player, "portal-base-b") --returns the portal entity the player is on or false
				if entry_portal_2 then --checks if the player is on an entry_portal_2
					try_teleport(player, global.a_portals[entry_portal_2.backer_name]) --teleport to the b_portal with the same backer_name as the portal the player is on
				end
			end
		end
	end
end)

function on_portal(player, portal)
	local player_pos = player.position
	local entities = player.surface.find_entities_filtered{area={{player_pos.x-0.5,player_pos.y-0.3}, {player_pos.x+0.5,player_pos.y+0.1}}, name = portal}
	if entities[1] and entities[1].valid then
		return entities[1]
	else
		return false
	end
end
    
function try_teleport(player, exit_portal)	
	local tick = game.tick
	if exit_portal and exit_portal.valid then --does that base exist and is it valid?
		if (not global.teleport_delay[player.index]) or global.teleport_delay[player.index] < game.tick then
			player.teleport({exit_portal.position.x, exit_portal.position.y-0.9}, exit_portal.surface) --teleport player to the top of the exit_portal entity
			global.teleport_delay[player.index] = tick + 39
		end
	end
end