require("prototypes.entities")

data:extend(
{
--recipe
	{
		type = "recipe",
		name = "portal-gun",
		enabled = "false",
		ingredients =
		{
			{"steel-plate", 5},
			{"advanced-circuit",10},
			{"iron-gear-wheel", 10},
			{"solar-panel-equipment", 1},
		},
		result = "portal-gun",
	},

	
--item
	{
		type = "item",
		name = "portal-gun",
		subgroup = "transport",
		icon = "__Portals__/graphics/portal-gun.png",
		flags = { "goes-to-quickbar" },
		order = "a[items]",
		place_result="portal",
		stack_size= 1,
	},
	{
		type = "item",
		name = "portal-drop",
		icon = "__Portals__/graphics/null.png",
		flags = { "hidden" },
		order = "a[items]",
		stack_size= 1,
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
	
})