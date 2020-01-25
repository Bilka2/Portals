-- CUSTOM EVENT HANDLING --
--(remote interface is lower in the file, there I describe how to subscribe to my events)
local on_player_teleported_event = script.generate_event_name() --uint
local on_player_placed_portal_event = script.generate_event_name()


-- UTILITIES --

-- make a build error in the same way as the base game
local function build_error(err, player, position)
  player.play_sound{path = "utility/cannot_build"}
  player.create_local_flying_text{text = err, position = position}
end

-- returns whether this portal is one of mine
local portal_names = 
{
  ["portal"] = true,
  ["portal-a"] = true,
  ["portal-b"] = true,
}
local function is_portal(entity)
  return portal_names[entity.name] or false
end

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

-- destroy the portal and remove it from the global table
local function destroy_portal(player_index, portal_type, portal)
  portal.destroy()
  if global.portals[player_index] and global.portals[player_index][portal_type] then
    global.portals[player_index][portal_type] = nil -- remove the portal from the list
  end
end

--gets which type the portal is (portal-a is a, portal-b is b)
local function get_portals_type(entity)
  return entity.name:find("-b") and "b" or "a"
end

--gets the player_index of the owner of the portal
local function get_portals_owner(entity)
  for player_index, tbl in pairs(global.portals) do
    if (tbl.a and tbl.a == entity) or (tbl.b and tbl.b == entity) then
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

--destroy the old portal with that associated player_index, needs which type the portal is of
local function destroy_other_portal(player_index, portal_type)
  local portal = get_players_portal(player_index, portal_type)
  if portal then
    destroy_portal(player_index, portal_type, portal)
  end
end

local function build_portal(player, surface, pos, portal_type, by_player)
  local portal = surface.create_entity{name = "portal-" .. portal_type, position = pos, force = player.force} --creates new portal-base
  local index = player.index
  if by_player then
    script.raise_event(on_player_placed_portal_event, {player_index = index, portal = portal})
  end
  if (not portal) or (not portal.valid) then -- another mod destroyed the new portal
    return -- we don't destroy the old one
  end
  
  portal.destructible = false
  destroy_other_portal(index, portal_type)
  save_portal(index, portal_type, portal)
  if index ~= 1 or not settings.global["portals-dont-number-portal-pair-one"].value then
    local portal_colour = {}
    if portal_type == "a" then portal_colour = {r = 1, g = 0.55, b = 0.1} end --orange portals get orange number
    if portal_type == "b" then portal_colour = {r = 0.5, g = 0.5, b = 1} end --blue portals get blue number
    rendering.draw_text({ text=index, target=portal, target_offset={-0.5, -1}, surface=surface, color=portal_colour }) --creates portal text
  end
end

--Creates portal-b when portal is ghost-placed, creates portal-a when portal is normally placed:
script.on_event(defines.events.on_built_entity, function(event)
  if event.created_entity.type == "entity-ghost" and event.created_entity.ghost_name == "portal" then --is portal ghost-placed?
    local new_position = event.created_entity.position
    local new_surface = event.created_entity.surface
    local player = game.get_player(event.player_index)
    event.created_entity.destroy() --destroy portal which is just a placeholder entity
    
    if not event.stack.valid_for_read and player.cursor_ghost and player.cursor_ghost.name == "portal-gun" then -- player used ghost cursor
      build_error({"cant-use-ghost-cursor-for-portal"}, player, new_position)
      return
    end
    
    if global.disable_long_distance_placing or settings.global["portals-disable-long-distance-placing"].value then
      local max_dist = player.build_distance
      local X = new_position.x
      local Y = new_position.y
      local pY=player.position.y
      local pX=player.position.x
      if X>=pX-max_dist and X<=pX+max_dist and Y>=pY-max_dist and Y<=pY+max_dist and player.surface == new_surface then
        new_surface.play_sound{path = "portalgun-shoot-b", position = new_position}
        build_portal(player, new_surface, new_position, "b", true)
      else
        build_error({"cant-reach"}, player, new_position)
      end
    else
      new_surface.play_sound{path = "portalgun-shoot-b", position = new_position}
      build_portal(player, new_surface, new_position, "b", true)
    end
    
  elseif event.created_entity.name == "portal" then --is portal normally placed?
    local new_position = event.created_entity.position
    local new_surface = event.created_entity.surface
    local player = game.get_player(event.player_index)
    
    event.created_entity.destroy() --destroy portal which is just a placeholder entity
    if player.cursor_stack then 
      player.cursor_stack.set_stack{name="portal-gun", count = 1} --make player hold one portal gun, does not care if player already holds portal guns
    end
    new_surface.play_sound{path = "portalgun-shoot-a", position = new_position}
    build_portal(player, new_surface, new_position, "a", true)
  end
end, {{filter = "name", name = "portal"}, {filter = "ghost_name", name = "portal"}}) -- event filters for on_built_entity. Have to keep the name ifs for mods that custom raise on_built_entity (idk why you'd do that, we have a script event....)

-- we don't get a player through this event, so we can never create a proper portal from it. So instead, the portal is just destroyed.
-- @other mod authors: If you want to create a working portal in your mod, use the remote interface that is detailed lower in this file.
script.on_event(defines.events.script_raised_built, function (event)
  if not event.entity then return end -- bad mods may raise the event incorrectly
  if event.entity.type == "entity-ghost" and event.entity.ghost_name == "portal" then
    event.entity.destroy()    
  elseif event.entity.name == "portal" or event.entity.name == "portal-a" or event.entity.name == "portal-b" then  
    event.entity.destroy()
  end
end)

--destroy portal if the base entity is given
local function destroy_portal_from_base(entity)
  if not is_portal(entity) then return end
  destroy_portal(get_portals_owner(entity), get_portals_type(entity), entity)
end

--when base is mined/dies, destroy portal:
script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_entity_died, defines.events.script_raised_destroy}, function(event)
  if event.entity and event.entity.valid then 
    destroy_portal_from_base(event.entity)
  end
end) -- no filters because script_raised_destroy can't be filtered AND filters can only be used when registering single events

-- when base is cloned, remove original and make clone work
script.on_event(defines.events.on_entity_cloned, function(event)
  if not is_portal(event.source) then return end
  local index = get_portals_owner(event.source)
  if not index then -- invalid portal was cloned
    event.source.destroy()
    event.destination.destroy()
    return
  end
 
  local portal = event.destination
  local portal_type = get_portals_type(event.source)
  portal.destructible = false
  destroy_other_portal(index, portal_type)
  save_portal(index, portal_type, portal)
  if index ~= 1 or not settings.global["portals-dont-number-portal-pair-one"].value then
    local portal_colour = {}
    if portal_type == "a" then portal_colour = {r = 1, g = 0.55, b = 0.1} end --orange portals get orange number
    if portal_type == "b" then portal_colour = {r = 0.5, g = 0.5, b = 1} end --blue portals get blue number
    rendering.draw_text({ text=index, target=portal, target_offset={-0.5, -1}, surface=event.destination.surface, color=portal_colour }) --creates portal text
  end
end) -- no filters because entity_cloned can't be filtered (yet)

-- Events that run every tick/often: TELEPORTING THE PLAYER --
local function on_portal(player)
  local player_pos = player.position
  local entity = player.surface.find_entities_filtered{area={{player_pos.x-0.7,player_pos.y-0.3}, {player_pos.x+0.7,player_pos.y+0.1}}, type = "simple-entity-with-owner", force = player.force, limit = 1}[1]
  if entity and is_portal(entity) then
    return entity
  end
end
    
local function try_teleport(player, exit_portal, entrance_portal)  
  local tick = game.tick
  if exit_portal then
    if (not global.teleport_delay[player.index]) or global.teleport_delay[player.index] < tick then
      player.surface.play_sound({path="portal-enter", position=player.position})
      player.teleport({exit_portal.position.x, exit_portal.position.y-0.9}, exit_portal.surface) --teleport player to the top of the exit_portal entity
      exit_portal.surface.play_sound({path="portal-exit", position=exit_portal.position})
      global.teleport_delay[player.index] = tick + 47
      script.raise_event(on_player_teleported_event, {player_index = player.index, entrance_portal = entrance_portal, target_portal = exit_portal})
    end
  end
end

--tries to teleport when player connected, has character, not in vehicle:
script.on_nth_tick(2, function()
  for index, player in pairs(game.connected_players) do
    if player.character and not player.vehicle then
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
  local old_version = event.mod_changes["Portals"].old_version
  if not old_version then return end
  global.teleport_delay = global.teleport_delay or {}
  global.disable_long_distance_placing = global.disable_long_distance_placing or false
  --no migration from < 0.3.3
  if old_version:match("^0.1") or old_version:match("^0.2") then
    error("Migrating from versions older than 0.3.3 of the mod is not supported. Use version 0.3.3 to migrate from those version and then use this version again.")
  end
  local bad_versions = {"0.3.0", "0.3.1", "0.3.2"}
  for _, v in pairs(bad_versions) do
    if old_version == v then
      error("Migrating from versions older than 0.3.3 of the mod is not supported. Use version 0.3.3 to migrate from those version and then use this version again.")
    end
  end
  
  -- migrate old flying text numbers to script rendering
  for player_index, portals in pairs(global.portals) do
    if index ~= 1 or not settings.global["portals-dont-number-portal-pair-one"].value then
      if portals.a then
        rendering.draw_text({ text=player_index, target=portals.a, target_offset={-0.5, -1}, surface=portals.a.surface, color={r = 1, g = 0.55, b = 0.1} })
      end
      if portals.b then
        rendering.draw_text({ text=player_index, target=portals.b, target_offset={-0.5, -1}, surface=portals.b.surface, color={r = 0.5, g = 0.5, b = 1} })
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
