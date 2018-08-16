require("prototypes.entities.portals")
require("prototypes.entities.grenade")
require("prototypes.sounds")

data:extend(
{
--recipe
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

	
--item
	{
		type = "item",
		name = "portal-gun",
		subgroup = "transport",
		icon = "__Portals__/graphics/portal-gun.png",
		icon_size = 32,
		flags = { "goes-to-quickbar" },
		order = "a",
		place_result="portal",
		stack_size= 1,
	},
	{
		type = "capsule",
		name = "lemon-grenade",
		icon = "__Portals__/graphics/lemon-grenade.png",
		icon_size = 32,
		flags = {"goes-to-quickbar"},
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

--technology
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
      unit = {
        count = 200,
        ingredients =
		{
			{"science-pack-1", 1},
			{"science-pack-2", 1},
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
      prerequisites = {"military-3",},
      unit = {
        count = 200,
        ingredients =
		{
			{"science-pack-1", 1},
			{"science-pack-2", 1},
			{"science-pack-3", 1},
			{"military-science-pack", 1},
		},
		time = 30
      },
      order = "k-a",
    },
	
})