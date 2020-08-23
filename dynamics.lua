-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, ipairs
    = minetest, nodecore, pairs, ipairs
-- LUALOCALS > ---------------------------------------------------------
local get_node = minetest.get_node
local set_node = minetest.swap_node

local all_direction_permutations = {              -- table of all possible permutations of horizontal direction to avoid lots of redundant calculations.
	{{x=0,z=1},{x=0,z=-1},{x=1,z=0},{x=-1,z=0}},
	{{x=0,z=1},{x=0,z=-1},{x=-1,z=0},{x=1,z=0}},
	{{x=0,z=1},{x=1,z=0},{x=0,z=-1},{x=-1,z=0}},
	{{x=0,z=1},{x=1,z=0},{x=-1,z=0},{x=0,z=-1}},
	{{x=0,z=1},{x=-1,z=0},{x=0,z=-1},{x=1,z=0}},
	{{x=0,z=1},{x=-1,z=0},{x=1,z=0},{x=0,z=-1}},
	{{x=0,z=-1},{x=0,z=1},{x=-1,z=0},{x=1,z=0}},
	{{x=0,z=-1},{x=0,z=1},{x=1,z=0},{x=-1,z=0}},
	{{x=0,z=-1},{x=1,z=0},{x=-1,z=0},{x=0,z=1}},
	{{x=0,z=-1},{x=1,z=0},{x=0,z=1},{x=-1,z=0}},
	{{x=0,z=-1},{x=-1,z=0},{x=1,z=0},{x=0,z=1}},
	{{x=0,z=-1},{x=-1,z=0},{x=0,z=1},{x=1,z=0}},
	{{x=1,z=0},{x=0,z=1},{x=0,z=-1},{x=-1,z=0}},
	{{x=1,z=0},{x=0,z=1},{x=-1,z=0},{x=0,z=-1}},
	{{x=1,z=0},{x=0,z=-1},{x=0,z=1},{x=-1,z=0}},
	{{x=1,z=0},{x=0,z=-1},{x=-1,z=0},{x=0,z=1}},
	{{x=1,z=0},{x=-1,z=0},{x=0,z=1},{x=0,z=-1}},
	{{x=1,z=0},{x=-1,z=0},{x=0,z=-1},{x=0,z=1}},
	{{x=-1,z=0},{x=0,z=1},{x=1,z=0},{x=0,z=-1}},
	{{x=-1,z=0},{x=0,z=1},{x=0,z=-1},{x=1,z=0}},
	{{x=-1,z=0},{x=0,z=-1},{x=1,z=0},{x=0,z=1}},
	{{x=-1,z=0},{x=0,z=-1},{x=0,z=1},{x=1,z=0}},
	{{x=-1,z=0},{x=1,z=0},{x=0,z=-1},{x=0,z=1}},
	{{x=-1,z=0},{x=1,z=0},{x=0,z=1},{x=0,z=-1}},
}

--------------------Steam Particles--------------------
local particles = minetest.setting_getbool("enable_particles")
particles = particles or particles == nil -- default true

local steam = function(pos)
	if particles then
	minetest.add_particlespawner({
		amount = 6,
		time = 1,
		minpos = pos,
		maxpos = pos,
		minvel = {x=-2, y=0, z=-2},
		maxvel = {x=2, y=1, z=2},
		minacc = {x=0, y=2, z=0},
		maxacc = {x=0, y=2, z=0},
		minexptime = 1,
		maxexptime = 4,
		minsize = 16,
		maxsize = 16,
		collisiondetection = true,
		vertical = false,
		texture = "smoke_puff.png",
	})
	end
end

--------------------Making Water Finite--------------------
local override_def = {liquid_renewable = false}
	minetest.override_item("nc_terrain:water_source", override_def)
	minetest.override_item("nc_terrain:water_flowing", override_def)

--------------------Making Water Dynamic--------------------
nodecore.register_limited_abm({
		label = "hydrodynamics",
		nodenames = {"nc_terrain:water_source"},
		neighbors = {"nc_terrain:water_flowing"},
		interval = 1,
		chance = 1,
		action = function(pos,node) -- Do everything possible to optimize this method
				local check_pos = {x=pos.x, y=pos.y-1, z=pos.z}
				local check_node = get_node(check_pos)
				local check_node_name = check_node.name
				if check_node_name == "nc_terrain:water_flowing" or check_node_name == "air" then
					set_node(pos, check_node)
					set_node(check_pos, node)
					return
				end
				local perm = all_direction_permutations[math.random(24)]
				local dirs -- declare outside of loop so it won't keep entering/exiting scope
				for i=1,4 do
					dirs = perm[i]
					-- reuse check_pos to avoid allocating a new table
					check_pos.x = pos.x + dirs.x 
					check_pos.y = pos.y
					check_pos.z = pos.z + dirs.z
					check_node = get_node(check_pos)
					check_node_name = check_node.name
					if check_node_name == "nc_terrain:water_flowing" or check_node_name == "air" then
						set_node(pos, check_node)
						set_node(check_pos, node)
						return
					end
				end
			end
		})

--------------------Making Lava Dynamic--------------------
nodecore.register_limited_abm({
		label = "lavadynamics",
		nodenames = {"nc_terrain:lava_source"},
		neighbors = {"nc_terrain:lava_flowing"},
		interval = 1,
		chance = 1,
		action = function(pos,node) -- Do everything possible to optimize this method
				local check_pos = {x=pos.x, y=pos.y-1, z=pos.z}
				local check_node = get_node(check_pos)
				local check_node_name = check_node.name
				if check_node_name == "nc_terrain:lava_flowing" or check_node_name == "air" then
					set_node(pos, check_node)
					set_node(check_pos, node)
					return
				end
				local perm = all_direction_permutations[math.random(24)]
				local dirs -- declare outside of loop so it won't keep entering/exiting scope
				for i=1,4 do
					dirs = perm[i]
					-- reuse check_pos to avoid allocating a new table
					check_pos.x = pos.x + dirs.x 
					check_pos.y = pos.y
					check_pos.z = pos.z + dirs.z
					check_node = get_node(check_pos)
					check_node_name = check_node.name
					if check_node_name == "nc_terrain:lava_flowing" or check_node_name == "air" then
						set_node(pos, check_node)
						set_node(check_pos, node)
						return
					end
				end
			end
		})

--------------------Liquid Displacement--------------------
	local cardinal_dirs = {
		{x= 0, y=0,  z= 1},
		{x= 1, y=0,  z= 0},
		{x= 0, y=0,  z=-1},
		{x=-1, y=0,  z= 0},
		{x= 0, y=-1, z= 0},
		{x= 0, y=1,  z= 0},
	}
	-- breadth-first search passing through liquid searching for air or flowing liquid.
	local flood_search_outlet = function(start_pos, source, flowing)
		local start_node =  minetest.get_node(start_pos)
		local start_node_name = start_node.name
		if start_node_name == "air" or start_node_name == "nc_terrain:water_flowing" then
			return start_pos
		end
	
		local visited = {}
		visited[minetest.hash_node_position(start_pos)] = true
		local queue = {start_pos}
		local queue_pointer = 1
		
		while #queue >= queue_pointer do
			local current_pos = queue[queue_pointer]		
			queue_pointer = queue_pointer + 1
			for _, cardinal_dir in ipairs(cardinal_dirs) do
				local new_pos = vector.add(current_pos, cardinal_dir)
				local new_hash = minetest.hash_node_position(new_pos)
				if visited[new_hash] == nil then
					local new_node = minetest.get_node(new_pos)
					local new_node_name = new_node.name
					if new_node_name == "air" or new_node_name == "nc_terrain:water_flowing" then
						return new_pos
					end
					visited[new_hash] = true
					if new_node_name == source then
						table.insert(queue, new_pos)
					end
				end
			end		
		end
		return nil
	end

	-- Conserve liquids, when placing nodes in liquids try to find a place to displace the liquid to.
	minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
		local flowing = "nc_terrain:water_flowing"
		if flowing ~= nil then
			local dest = flood_search_outlet(pos, oldnode.name, flowing)
			if dest ~= nil then
				minetest.swap_node(dest, oldnode)
			end
		end
	end
	)
