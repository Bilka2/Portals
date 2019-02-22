--portals
data:extend(
{
  {
    type = "simple-entity-with-owner",
    name = "portal", --this is what gets placed by the item
    flags = {"player-creation", "not-deconstructable", "not-rotatable"},
    selectable_in_game = false,
    minable = {mining_time = 5, result = nil},
    picture =
    {
      filename = "__Portals__/graphics/entity_portal.png",
      priority = "high",
      width = 76,
      height = 128,
      scale = 0.5,
    },
    collision_box = {{0, -0.6}, {0, 0.6}},
    collision_mask = { "item-layer", "object-layer", "water-tile"},
    selection_box = {{-0.5, -0.9}, {0.5, 0.9}},
    tile_width = 1,
    tile_height = 2,
  },
  
  {
    type = "simple-entity-with-owner",
    name = "portal-a",
    flags = {"player-creation", "not-blueprintable", "not-deconstructable", "not-rotatable"},
    map_color = {r=1, g=0.5, b=0},
    placeable_by = {item="portal-gun", count= 1},
    minable = {mining_time = 0.7, result = nil},
    max_health = 20,
    collision_box = {{0, -0.6}, {0, 0.6}},
    collision_mask = { "item-layer", "object-layer", "water-tile"},
    selection_box = {{-0.5, -0.9}, {0.5, 0.9}},
    random_animation_offset = false,
    animations =
    {
    {
      filename = "__Portals__/graphics/entity_portal-a.png",
      priority = "high",
      width = 76,
      height = 128,
      frame_count = 32,
      line_length = 8,
      animation_speed = 0.5,
      scale = 0.5,
    }
    },
    working_sound =
    {
      sound = { filename = "__Portals__/sounds/portal_ambient_loop1.ogg" },
      volume = 0.1,
      audible_distance_modifier = 0.4,
      probability = 1
    },
    render_layer = "floor",
    tile_width = 1,
    tile_height = 2,
  },
  
  {
    type = "simple-entity-with-owner",
    name = "portal-b",
    flags = {"player-creation", "not-blueprintable", "not-deconstructable", "not-rotatable"},
    map_color = {r=0.5, g=0.5, b=1},
    placeable_by = {item="portal-gun", count= 1},
    minable = {mining_time = 0.7, result = nil},
    max_health = 20,
    collision_box = {{0, -0.6}, {0, 0.6}},
    collision_mask = { "item-layer", "object-layer", "water-tile"},
    selection_box = {{-0.5, -0.9}, {0.5, 0.9}},
    random_animation_offset = false,
    animations =
    {
    {
      filename = "__Portals__/graphics/entity_portal-b.png",
      priority = "high",
      width = 76,
      height = 128,
      frame_count = 32,
      line_length = 8,
      animation_speed = 0.5,
      scale = 0.5,
    }
    },
    working_sound =
    {
      sound = { filename = "__Portals__/sounds/portal_ambient_loop1.ogg" },
      volume = 0.1,
      audible_distance_modifier = 0.4,
      probability = 1
    },
    render_layer = "floor",
    tile_width = 1,
    tile_height = 2,
  }
})
