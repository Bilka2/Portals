# Portals

Adds portals that can teleport players (and only players!). Build the portals using the portal gun: Left click for the orange portal, SHIFT+ Left click (ghost build) for the blue portal. Every player can have one set of portals which can be distinguished using the number next to the portal. Adds combustible lemons that work similiar to cluster grenades, just with fire. This mod can also be found on [the forums.](https://forums.factorio.com/viewtopic.php?f=93&t=44305)

Known issues: The teleportation sound does not play for the player using the portal if the portals are on different surfaces. It does however play for any other player near the portals. This is an issue with the game, not the mod.

## Custom events

on_player_teleported_event:
- When a player teleports using a portal.
- Contains:
  - player_index = Index of the player that is teleporting
  - entrance_portal = LuaEntity, the portal the player is teleporting from
  - target_portal = LuaEntity, the portal the player is teleporting to

on_player_placed_portal_event:
- When a player places a portal using the portal gun.
- Contains:
  - portal = LuaEntity, the portal that was placed
  - player_index = Index of the player that placed the portal, which is the player the portal belongs to
	
### Example usage

	script.on_load(function()
		script.on_event(remote.call("portals", "get_on_player_teleported_event"), function(event)
			game.print("Woosh!")
			game.print(game.players[event.player_index].name .. " teleported from " .. serpent.line(event.entrance_portal.position) .. " to " .. serpent.line(event.target_portal.position))
		end)
	
		script.on_event(remote.call("portals", "get_on_player_placed_portal_event"), function(event)
			game.print(game.players[event.player_index].name .. " created " .. event.portal.name .. " at " .. serpent.line(event.portal.position))
		end)
	end)
	
	script.on_init(function()
		script.on_event(remote.call("portals", "get_on_player_teleported_event"), function(event)
			game.print("Woosh!")
			game.print(game.players[event.player_index].name .. " teleported from " .. serpent.line(event.entrance_portal.position) .. " to " .. serpent.line(event.target_portal.position))
		end)
		
		script.on_event(remote.call("portals", "get_on_player_placed_portal_event"), function(event)
			game.print(game.players[event.player_index].name .. " created " .. event.portal.name .. " at " .. serpent.line(event.portal.position))
		end)
	end)


## Remote functions

build_portal_a: function(player, surface, position)
- Build an orange portal.
- Parameters:
  - position: Position of the new portal
  - surface: LuaSurface, the surface of the new portal
  - player: LuaPlayer that the portal belongs to. This player can't have more than one pair, build_portal will delete any excess portals

build_portal_b: function(player, surface, position)
- Build a blue portal.
- Parameters:
  - position: Position of the new portal
  - surface: LuaSurface, the surface of the new portal
  - player: LuaPlayer that the portal belongs to. This player can't have more than one pair, build_portal will delete any excess portals

destroy_portal: function(entity)
- Destroy the given entity if it is a portal (also destroys label + animation).
- Parameter:
  - entity: LuaEntity, the portal to destroy

disable_long_distance_placing: function(bool)
- Change whether the blue portal can be placed from a long distance.
- Parameter:
  - bool: Boolean, if this is true the player can never place from a long distance, if it is false, the player can place from a long distance depending on the mod option
	
### Example usage in the console

	/c remote.call("portals", "build_portal_b", game.player, game.player.surface, game.player.position) --place at current player position
	/c remote.call("portals", "destroy_portal", game.player.selected) --destroy currently selected portal
	/c remote.call("portals", "disable_long_distance_placing", true) --disable long distance placing
