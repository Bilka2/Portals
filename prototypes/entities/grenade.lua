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
          }
        }
      },
      {
        type = "area",
        radius = 3,
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