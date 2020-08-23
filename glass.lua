-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function near(pos, crit)
	return #nodecore.find_nodes_around(pos, crit, {1, 1, 1}, {1, 0, 1}) > 0
end

--------------------Node Registry--------------------

minetest.register_node(modname .. ":glass_hard", {
		description = "Tempered Glass",
		drawtype = "glasslike_framed_optional",
		use_texture_alpha = true,
		tiles = {
			modname .. "_glass_mesh.png^nc_optics_glass_edges.png",
			modname .. "_glass_mesh.png"
		},
		groups = {
			silica = 1,
			silica_clear = 1,
			cracky = 5,
			scaling_time = 200
		},
		sunlight_propagates = true,
		paramtype = "light",
		sounds = nodecore.sounds("nc_optics_glassy")
	})

minetest.register_node(modname .. ":glass_warm", {
		description = "Hot Float Glass",
		drawtype = "glasslike_framed_optional",
		tiles = {
			"nc_optics_glass_edges.png",
			"[combine:16x16"
		},
		sunlight_propagates = true,
		paramtype = "light",
		groups = {
			silica = 1,
			silica_clear = 1,
			cracky = 3,
			scaling_time = 300
		},
		sounds = nodecore.sounds("nc_optics_glassy")
	})

--------------------Heating--------------------

nodecore.register_craft({
		label = "Heat Float Glass",
		action = "cook",
		touchgroups = {
			coolant = 0,
			flame = 3
		},
		duration = 20,
		cookfx = true,
		indexkeys = {"nc_optics:glass_float"},
		nodes = {
			{
				match = {"nc_optics:glass_float"},
				replace = {modname .. ":glass_warm"}
			}
		}
	})

nodecore.register_cook_abm({
		nodenames = {"nc_optics:glass_float"},
		neighbors = {"group:flame"}
     })

--------------------Cooling--------------------

nodecore.register_craft({
		label = "quench tempered glass",
		action = "cook",
		cookfx = true,
		check = function(pos)
			return (not near(pos, {flow}))
			and nodecore.quenched(pos)
		end,
		indexkeys = {modname .. ":glass_warm"},
		nodes = {
			{
				match = modname .. ":glass_warm",
				replace = modname .. ":glass_hard"
			}
		}
	})
