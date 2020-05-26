-- portal entities
data:extend(
{
  {
    type = "simple-entity-with-owner",
    name = "portal", --this is what gets placed by the item
    flags = {"player-creation", "not-deconstructable", "not-rotatable", "not-selectable-in-game"},
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
    flags = {"player-creation", "not-blueprintable", "not-deconstructable"},
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
      filename = "__Portals__/graphics/entity_portal-a.png",
      priority = "high",
      width = 76,
      height = 128,
      frame_count = 32,
      line_length = 8,
      animation_speed = 0.5,
      scale = 0.5
    },
    working_sound =
    {
      sound = { filename = "__Portals__/sounds/portal_ambient_loop1.ogg" },
      audible_distance_modifier = 0.4
    },
    render_layer = "floor",
    tile_width = 1,
    tile_height = 2,
  },
  
  {
    type = "simple-entity-with-owner",
    name = "portal-b",
    flags = {"player-creation", "not-blueprintable", "not-deconstructable"},
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
      filename = "__Portals__/graphics/entity_portal-b.png",
      priority = "high",
      width = 76,
      height = 128,
      frame_count = 32,
      line_length = 8,
      animation_speed = 0.5,
      scale = 0.5
    },
    working_sound =
    {
      sound = { filename = "__Portals__/sounds/portal_ambient_loop1.ogg" },
      audible_distance_modifier = 0.4
    },
    render_layer = "floor",
    tile_width = 1,
    tile_height = 2,
  }
})

--projectiles for lemon grenade
data:extend(
{
  {
    type = "projectile",
    name = "lemon-fire-big",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-entity",
              entity_name = "explosion"
            },
            {
              type = "create-entity",
              entity_name = "small-scorchmark",
              check_buildability = true
            },
            {
              type = "destroy-decoratives",
              from_render_layer = "decorative",
              to_render_layer = "object",
              include_soft_decoratives = true,
              include_decals = false,
              invoke_decorative_trigger = true,
              decoratives_with_trigger_only = false,
              radius = 1.25
            }
          }
        }
      },
      {
        type = "cluster",
        cluster_count = 7,
        distance = 4,
        distance_deviation = 3,
        action_delivery =
        {
          type = "projectile",
          projectile = "lemon-fire",
          direction_deviation = 0.6,
          starting_speed = 0.2,
          starting_speed_deviation = 0.1
        }
      }
    },
    light = {intensity = 0.5, size = 4},
    animation =
    {
      filename = "__Portals__/graphics/lemon-grenade-small.png",
      frame_count = 1,
      width = 24,
      height = 24,
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/grenade/grenade-shadow.png",
      frame_count = 1,
      width = 24,
      height = 24,
      priority = "high"
    }
  },
  {
    type = "projectile",
    name = "lemon-fire",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-fire",
              entity_name = "fire-flame",
              initial_ground_flame_count = 30,
            },
            {
              type = "destroy-decoratives",
              from_render_layer = "decorative",
              to_render_layer = "object",
              include_soft_decoratives = true,
              include_decals = false,
              invoke_decorative_trigger = true,
              decoratives_with_trigger_only = false,
              radius = 2
            }
          }
        }
      },
      {
        type = "area",
        radius = 2.5,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
          {
            type = "create-sticker",
            sticker = "fire-sticker"
          },
          {
            type = "damage",
            damage = { amount = 20, type = "fire" }
          }
          }
        }
      },
    },
    light = {intensity = 0.5, size = 4},
    animation =
    {
      filename = "__Portals__/graphics/lemon-grenade-small.png",
      frame_count = 1,
      width = 24,
      height = 24,
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/grenade/grenade-shadow.png",
      frame_count = 1,
      width = 24,
      height = 24,
      priority = "high"
    }
  },
})

--sounds for teleporting
data:extend(
{
  {
    type = "sound",
    name = "portal-enter",
    filename = "__Portals__/sounds/portal_enter.ogg",
    volume = 0.42
  },
  {
    type = "sound",
    name = "portal-exit",
    filename = "__Portals__/sounds/portal_exit.ogg",
    volume = 0.42
  },
  {
    type = "sound",
    name = "portalgun-shoot-a",
    filename = "__Portals__/sounds/portalgun_shoot_red1.ogg",
    volume = 0.5
  },
  {
    type = "sound",
    name = "portalgun-shoot-b",
    filename = "__Portals__/sounds/portalgun_shoot_blue1.ogg",
    volume = 0.5
  }
})


data:extend(
{
-- recipes
  {
    type = "recipe",
    name = "portal-gun",
    enabled = "false",
    energy_required = 0.5,
    ingredients =
    {
      {"steel-plate", 5},
      {"advanced-circuit",10},
      {"iron-gear-wheel", 10},
      {"solar-panel-equipment", 1},
    },
    result = "portal-gun",
  },
  {
    type = "recipe",
    name = "lemon-grenade",
    enabled = "false",
    energy_required = 2,
    ingredients =
    {
      {"steel-plate", 5},
      {"sulfur",4},
      {"flamethrower-ammo", 1},
    },
    result = "lemon-grenade",
  },

  
-- items
  {
    type = "item",
    name = "portal-gun",
    subgroup = "transport",
    icon = "__Portals__/graphics/portal-gun.png",
    icon_size = 32,
    order = "a",
    place_result="portal",
    stack_size= 1,
  },
  {
    type = "capsule",
    name = "lemon-grenade",
    icon = "__Portals__/graphics/lemon-grenade.png",
    icon_size = 32,
    capsule_action =
    {
      type = "throw",
      attack_parameters =
      {
        type = "projectile",
        ammo_category = "grenade",
        cooldown = 20,
        projectile_creation_distance = 0.6,
        range = 20,
        ammo_type =
        {
          category = "grenade",
          target_type = "position",
          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "projectile",
              projectile = "lemon-fire-big",
              starting_speed = 0.5
            }
          }
        }
      }
    },
    subgroup = "capsule",
    order = "a[grenade]-a[lemon]",
    stack_size = 100
  },

--technologies
  {
    type = "technology",
    name = "portals",
    icon = "__Portals__/graphics/portal-tech.png",
    icon_size = 64,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "portal-gun"
      },
    },
    prerequisites = {"solar-panel-equipment",},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "k-a",
  },
  {
    type = "technology",
    name = "lemon-grenade",
    icon = "__Portals__/graphics/lemon-grenade-tech.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "lemon-grenade"
      },
    },
    prerequisites = {"military-3", "flamethrower", "sulfur-processing"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 30
    },
    order = "k-a",
  }
})