--sounds (explosions) for teleporting
data:extend(
{
	{
		type = "explosion",
		name = "portal-enter",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__core__/graphics/empty.png",
				priority = "low",
				width = 1,
				height = 1,
				frame_count = 1,
				line_length = 1,
				animation_speed = 1
			},
		},
		light = {intensity = 0, size = 0},
		sound =
		{
			{
				filename = "__Portals__/sounds/portal_enter.ogg",
				volume = 0.6
			}
		}
	},
	{
		type = "explosion",
		name = "portal-exit",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__core__/graphics/empty.png",
				priority = "low",
				width = 1,
				height = 1,
				frame_count = 1,
				line_length = 1,
				animation_speed = 1
			},
		},
		light = {intensity = 0, size = 0},
		sound =
		{
			{
				filename = "__Portals__/sounds/portal_exit.ogg",
				volume = 0.6
			}
		}
	},
	{
		type = "explosion",
		name = "portalgun-shoot-b",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__core__/graphics/empty.png",
				priority = "low",
				width = 1,
				height = 1,
				frame_count = 1,
				line_length = 1,
				animation_speed = 1
			},
		},
		light = {intensity = 0, size = 0},
		sound =
		{
			{
				filename = "__Portals__/sounds/portalgun_shoot_blue1.ogg",
				volume = 0.8
			}
		}
	},
	{
		type = "explosion",
		name = "portalgun-shoot-a",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__core__/graphics/empty.png",
				priority = "low",
				width = 1,
				height = 1,
				frame_count = 1,
				line_length = 1,
				animation_speed = 1
			},
		},
		light = {intensity = 0, size = 0},
		sound =
		{
			{
				filename = "__Portals__/sounds/portalgun_shoot_red1.ogg",
				volume = 0.8
			}
		}
	}
})