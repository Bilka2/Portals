--portals: portal-x are the collision + selections boxes + mining stuff; portal-animation-x are the animation/graphics in general
data:extend(
{
	{
		type = "container",
		name = "portal", --this is what gets placed by the item
		inventory_size = 0,
		icon = "__Portals__/graphics/portal-gun.png",
		flags = {"player-creation", "not-deconstructable"},
		selectable_in_game = false,
		minable = {mining_time = 5, result = nil},
		max_health = 1,
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
		drawing_box = {{0,0}, {0,0}},
		tile_width = 1,
		tile_height = 2,
	},
	
	{
		type = "electric-pole",
		name = "portal-a",
		flags = {"player-creation", "not-blueprintable", "not-deconstructable"},
		friendly_map_color = {r=1, g=1, b=0},
		selectable_in_game = true,
		minable = {mining_time = 0.7, result = "portal-drop"},
		max_health = 20,
		collision_box = {{0, -0.6}, {0, 0.6}},
		collision_mask = { "item-layer", "object-layer", "water-tile"},
		selection_box = {{-0.5, -0.9}, {0.5, 0.9}},
		resistances = {},
		maximum_wire_distance = 0,
		supply_area_distance = 0,
		pictures =
		{
			filename = "__Portals__/graphics/null.png",
			priority = "high",
			width = 1,
			height = 1,
			direction_count = 1,
		},
		working_sound =
		{
			sound = { filename = "__Portals__/sounds/portal_ambient_loop1.ogg" },
			apparent_volume = 0.1,
			audible_distance_modifier = 0.75,
			probability = 1
		},
		connection_points =
		{
			{
				wire = {},
				shadow = {}
			},
		},
		radius_visualisation_picture =
		{
			filename = "__Portals__/graphics/null.png",
			priority = "high",
			width = 1,
			height = 1,
		},
		tile_width = 1,
		tile_height = 2,
	},
	
	{
		type = "smoke",
		name = "portal-animation-a",
		flags = {"not-repairable", "not-blueprintable", "not-deconstructable", "not-on-map"},
		duration = 99999999, --hopefully long enough
		color = { r = 1, g = 1, b = 1, a = 1 },
		cyclic = true,
		affected_by_wind = false,
		show_when_smoke_off = true,
		movement_slow_down_factor = 0,
		vertical_speed_slowdown = 0,
		render_layer = "floor",
		animation =
		{
			filename = "__Portals__/graphics/entity_portal-a.png",
			priority = "high",
			width = 76,
			height = 128,
			frame_count = 32,
			line_length = 8,
			animation_speed = 0.5,
			scale = 0.5,
		},
		tile_width = 3,
		tile_height = 2,
	},
	
	{
		type = "electric-pole",
		name = "portal-b",
		flags = {"player-creation", "not-blueprintable", "not-deconstructable"},
		friendly_map_color = {r=1, g=1, b=0},
		selectable_in_game = true,
		minable = {mining_time = 0.7, result = "portal-drop"},
		max_health = 20,
		collision_box = {{0, -0.6}, {0, 0.6}},
		collision_mask = { "item-layer", "object-layer", "water-tile"},
		selection_box = {{-0.5, -0.9}, {0.5, 0.9}},
		resistances = {},
		maximum_wire_distance = 0,
		supply_area_distance = 0,
		pictures =
		{
			filename = "__Portals__/graphics/null.png",
			priority = "high",
			width = 1,
			height = 1,
			direction_count = 1,
		},
		working_sound =
		{
			sound = { filename = "__Portals__/sounds/portal_ambient_loop1.ogg" },
			apparent_volume = 0.1,
			audible_distance_modifier = 0.75,
			probability = 1
		},
		connection_points =
		{
			{
				wire = {},
				shadow = {}
			},
		},
		radius_visualisation_picture =
		{
			filename = "__Portals__/graphics/null.png",
			priority = "high",
			width = 1,
			height = 1,
		},
		tile_width = 1,
		tile_height = 2,
	},
	
	{
		type = "smoke",
		name = "portal-animation-b",
		flags = {"not-repairable", "not-blueprintable", "not-deconstructable", "not-on-map"},
		duration = 99999999, --hopefully long enough
		color = { r = 1, g = 1, b = 1, a = 1 },
		cyclic = true,
		affected_by_wind = false,
		show_when_smoke_off = true,
		movement_slow_down_factor = 0,
		vertical_speed_slowdown = 0,
		render_layer = "floor",
		animation =
		{
			filename = "__Portals__/graphics/entity_portal-b.png",
			priority = "high",
			width = 76,
			height = 128,
			frame_count = 32,
			line_length = 8,
			animation_speed = 0.5,
			scale = 0.5,
		},
		tile_width = 3,
		tile_height = 2,
	},
	
	 --just a renamed flying-text so that when my mod gets removed the text also gets removed
	{
		type = "flying-text",
		name = "portal-label",
		flags = {"not-on-map"},
		time_to_live = 150,
		speed = 0.05
	},
	
	{
		type = "lab", --old, here for migration
		name = "portal-base-a",
		flags = {"not-blueprintable", "not-deconstructable"},
		friendly_map_color = {r=1, g=1, b=0},
		selectable_in_game = true,
		minable = {mining_time = 0.7, result = "portal-drop"},
		max_health = 20,
		collision_box = {{0, -0.6}, {0, 0.6}},
		collision_mask = { "item-layer", "object-layer", "water-tile"},
		selection_box = {{-0.5, -0.9}, {0.5, 0.9}},
		energy_source= 
		{
			type = "electric",
			effectivity = 1,
			usage_priority = "primary-input",
			render_no_power_icon = false,
			render_no_network_icon = false,
		},
		off_animation =
		{
			filename = "__Portals__/graphics/null.png",
			priority = "high",
			width = 1,
			height = 1,
			frame_count = 1,
			line_length = 1,
			animation_speed = 1,
		},
		on_animation =
		{
			filename = "__Portals__/graphics/null.png",
			priority = "high",
			width = 1,
			height = 1,
			frame_count = 1,
			line_length  = 1,
			animation_speed = 1,
		},
		energy_usage = "0kW",
		inputs = {},
		module_slots = {},
		tile_width = 1,
		tile_height = 2,
	},
	
	{
		type = "lab",
		name = "portal-base-b", --old, here for migration
		flags = {"not-blueprintable", "not-deconstructable"},
		friendly_map_color = {r=1, g=1, b=0},
		selectable_in_game = true,
		minable = {mining_time = 0.7, result = "portal-drop"},
		max_health = 20,
		collision_box = {{0, -0.6}, {0, 0.6}},
		collision_mask = { "item-layer", "object-layer", "water-tile"},
		selection_box = {{-0.5, -0.9}, {0.5, 0.9}},
		energy_source= 
		{
			type = "electric",
			effectivity = 1,
			usage_priority = "primary-input",
			render_no_power_icon = false,
			render_no_network_icon = false,
		},
		off_animation =
		{
			filename = "__Portals__/graphics/null.png",
			priority = "high",
			width = 1,
			height = 1,
			frame_count = 1,
			line_length  = 1,
			animation_speed = 1,
		},
		on_animation =
		{
			filename = "__Portals__/graphics/null.png",
			priority = "high",
			width = 1,
			height = 1,
			frame_count = 1,
			line_length  = 1,
			animation_speed = 1,
		},
		energy_usage = "0kW",
		inputs = {},
		module_slots = {},
		tile_width = 1,
		tile_height = 2,
	},
	
})