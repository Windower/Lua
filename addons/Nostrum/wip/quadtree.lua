--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER I N CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

--[[
    A library for creating quadtrees.
    Objects are tracked using a rectangular bounding box.
--]]

local _print = print

local print = function(...)
    _print('QUADTREE LIB: ', ...)
	--_print('You are overcome with dread.')
end

local quadtree = {}

local meta = {}

_libs = _libs or {}
_libs.quadtree = quadtree

_meta = _meta or {}
_meta.QuadTree = _meta.QuadTree or {__index = quadtree}
bit = require 'bit'

local object_corner_map = {} -- store the corners locally, disagreement on object method names.

local function masks(rect, rect2, bounding_box)
	return bounding_box
        and ((rect[1] < bounding_box.x1 and bounding_box.x1 or rect[1])
                == (rect2[1] < bounding_box.x1 and bounding_box.x1 or rect2[1])
            and (rect[2] > bounding_box.x2 and bounding_box.x2 or rect[2])
                == (rect2[2] > bounding_box.x2 and bounding_box.x2 or rect2[2])
            and (rect[3] < bounding_box.y1 and bounding_box.y1 or rect[3])
                == (rect2[3] < bounding_box.y1 and bounding_box.y1 or rect2[3])
            and (rect[4] > bounding_box.y2 and bounding_box.y2 or rect[4])
                == (rect2[4] > bounding_box.y2 and bounding_box.y2 or rect2[4]))
        or (rect[1] == rect2[1]
            and rect[2] == rect2[2]
            and rect[3] == rect2[3]
            and rect[4] == rect2[4])
end

function quadtree.new(w, h, x, y, depth, max, max_depth, last_node)
    local t = {}
    
    meta[t] = {
        branch = last_node,
        width = w,
        height = h,
        x1 = x,
        x2 = x + w,
        y1 = y,
        y2 = y + h,
        leaf = true,
        contents = {},
        max_depth = max_depth,
        depth = depth,
        max = max,
		n = 0,
		--proxy = newproxy(true)
    }
	--getmetatable(meta[t].proxy).__gc = function() print('GC deleted a table') end
	
    return setmetatable(t, _meta.QuadTree)
end

function quadtree.insert_object_into_records(t, object)
	local masked
	local m = meta[t]
	
	for k, b in pairs(m.contents) do
		masked = masks(object_corner_map[k], object_corner_map[object], m)
		if masked then break end
	end
	
	-- check to see if the quadtree should split
	if not masked and m.n + 1 > m.max and m.depth < m.max_depth then
		t:sprout()
		t:insert(object)
	else
		m.contents[object] = true
		m.n = m.n + 1
		
		if object._quadtrees then
			object._quadtrees[t] = true
		else
			object._quadtrees = {[t] = true}
		end
	end
end

function quadtree.gather_leaves_in_area(t, x1, x2, y1, y2, container) -- rectangle search
	--[[
	Create a local table, pass it to gather_leaves_in_area.
	Nothing is returned, but gather_leaves_in_area populates the table.
	--]]
    if meta[t].leaf then
        container[t] = true
    else
		local m = meta[t]
		for i = 1,4 do
			local tree = m[i]
            if tree:intersects(x1, x2, y1, y2) then
                tree:gather_leaves_in_area(x1, x2, y1, y2, container)
            end
		end
    end
end

function quadtree.insert(t, object)
	local bin = {}
	local corners = object_corner_map[object]

	t:gather_leaves_in_area(corners[1], corners[2], corners[3], corners[4], bin)

	for leaf,_ in pairs(bin) do
		leaf:insert_object_into_records(object)
	end	
end

function quadtree.remove_object_from_records(t, object)
	local m = meta[t]
	
	m.contents[object] = nil
	object._quadtrees[t] = nil

	local masked = false
	local corners = object_corner_map[object]

	for k, b in pairs(m.contents) do
		masked = masks(object_corner_map[k], corners, m)
		--[[if masked then 
			m.n = m.n - 1
			break
		end--]]
		
		if masked then break end
	end
	
	m.n = masked and m.n or m.n - 1
end

 -- intended to be called on m.branch, should it exist.
function quadtree.check_for_collapse(t, bin, ignore)
	local contents = {}
	local sum = 0
	local m = meta[t]
	
	-- Duplicate bin. If the branch doesn't fold, bin will be returned.
	for k,_ in pairs(bin) do
		contents[k] = true
		sum = sum + 1
	end
	
	for i = 1, 4 do
		local _m = meta[m[i]]
		
		--[[
			Break out if a branch is found. A branched tree implies the 
			current branch will not fold.
		--]]
		if not _m.leaf then
			return false, bin 
		end
		
		for k, bool in pairs(_m.contents) do
			if not contents[k] then
				contents[k] = true
				sum = sum + 1
			end
		end
	end
	
	-- Check for overlaps and decrease sum if necessary.
	local _ = {}
	local __ = 0
	
	for k, bool in pairs(contents) do             
		for i = 1, __ do
			if masks(object_corner_map[k], object_corner_map[_[i]], m) then
				sum = sum - 1
				break
			end
		end

		__ = __ + 1
		_[__] = k
	end
	
	if sum <= m.max then
		return true, contents, sum
	else
		return false, bin, nil
	end
end

function quadtree.contains(t, object)
	return object_corner_map[object] and true or false
end

function quadtree.intersects(tree, x1, x2, y1, y2)
    local rect = meta[tree]
    return  rect.x2 >= x1
        and rect.x1 <= x2
        and rect.y2 >= y1
        and rect.y1 <= y2
end

do
	local floor = math.floor	
	
	function quadtree.get_point_collision(t, x, y)
		local m = meta[t]
		local resolution = 2^(m.max_depth-1)
		
		x = floor(x * resolution/m.width)
		y = floor(y * resolution/m.height)
				
		local potential_hits = meta[t:traverse(x, y)].contents
	
		-- don't return m.contents: someone could modify it
		return function()
			local object = nil
			return function()
				object = next(potential_hits, object)
				return object
			end
		end
	end
end

function quadtree.get_region_collision(t, object, x, y)
    -- I don't need this function
end

function quadtree.sprout(t)
    local m = meta[t]
    
    m.leaf = false
    m.n = 0
    
    local w, h, d = m.width/2, m.height/2, m.depth+1
	local max, max_depth = m.max, m.max_depth
	local x1, y1 = m.x1, m.y1
	
    m[1] = quadtree.new(w, h, x1, y1, d, max, max_depth, t)
    m[2] = quadtree.new(w, h, x1+w, y1, d, max, max_depth, t)
    m[3] = quadtree.new(w, h, x1, y1+h, d, max, max_depth, t)
    m[4] = quadtree.new(w, h, x1+w, y1+h, d, max, max_depth, t)
    
    for k, bool in pairs(m.contents) do
        k._quadtrees[t] = nil -- t is a branch now
        t:insert(k)
    end
    
    m.contents = nil
end

function quadtree.defoliate(t)
    local bin = {}
    local m = meta[t]

    m.n = 0
    m.leaf = true
	m.contents = {}
	
	for i = 1,4 do
		local tree = m[i]
		local _m = meta[tree]

		for object in pairs(_m.contents) do
			object._quadtrees[tree] = nil
		end
		
		meta[tree] = nil -- forget this line for a wicked memory leak!
		m[i] = nil
	end
end

do
	local rshift = bit.rshift

	function quadtree.traverse(t, x_code, y_code)
		local m = meta[t]
		
		local level = m.max_depth - 2 -- given level, rshift code by level-1
									  --> depth-2 and shift by level
		while not m.leaf do
			local x = rshift(x_code, level)%2
			local y = rshift(y_code, level)%2
			
			t = m[x+2*y+1]
			m = meta[t]
			level = level - 1
		end

		return t
	end
end

local function remove(object, trees)
	local folding_branches = {}
	local steady_branches = {}
	
	for i = 1, trees.n do
		local tree = trees[i]
		local m = meta[tree]
		
		m.contents[object] = nil
		object._quadtrees[tree] = nil
	end
	
	for i = 1, trees.n do
		local tree = trees[i]
		local m = meta[tree]
		
		local branch = m.branch
		
		if branch then
			if steady_branches[branch] then
				-- adjust n
				tree:remove(object)			
			elseif not folding_branches[branch] then
				local collapse_condition, bin, sum = branch:check_for_collapse({})
				
				if collapse_condition then
					-- no need to adjust n, the leaf will be deleted
					folding_branches[branch] = bin
					bin.n = sum
				else
					steady_branches[branch] = true
					tree:remove(object)
				end
			end
		else
			-- This only happens if the object was in the root level (dragged off-screen).
			tree:remove(object)
		end
	end
	
	for old_branch, bin in pairs(folding_branches) do
		local collapse_condition = true
		local branch = meta[old_branch].branch -- we already know old_branch will fold
		local sum = bin.n
		bin.n = nil

		old_branch:defoliate()
		
		local leaf = old_branch

		while branch and collapse_condition do
			local _sum
			
			collapse_condition, bin, _sum = branch:check_for_collapse(bin)
			
			if collapse_condition then
				branch:defoliate()
				
				--[[
					collapse can travel up the tree, cutting off 
					branches that will error if they aren't removed.
				--]]
				folding_branches[branch] = nil
				
				sum = _sum
				leaf = branch
				branch = meta[leaf].branch -- this can be nil (root)
			end
		end
		
		-- We removed object, but didn't adjust the sum (to skip the mask process).
		local m = meta[leaf]
		
		for object,bool in pairs(bin) do			
			m.contents[object] = true
			object._quadtrees[leaf] = true
		end
		
		m.n = sum -- check_for_collapse performed mask checks and count
		
		folding_branches[old_branch] = nil
		--[[ 
			INVALID KEY TO NEXT if above line appears directly after the
			first defoliate call. I do not understand why.
		--]]
	end
end

function quadtree.update(t, object, x1, x2, y1, y2)
    local map = object_corner_map[object]
    map[1], map[2], map[3], map[4] = x1, x2, y1, y2
    
	local new_trees = {}
    t:gather_leaves_in_area(x1, x2, y1, y2, new_trees)
    local old_trees = object._quadtrees
    
    local add, subtract = {}, {}
	local m, n = 0, 0
    
    for leaf, bool in pairs(new_trees) do
        if not old_trees[leaf] then
            n = n + 1
            add[n] = leaf
        end
    end
	
	for leaf, bool in pairs(old_trees) do
        if not new_trees[leaf] then
			m = m + 1
			subtract[m] = leaf
		end
	end
	
	subtract.n = m
				
    for i = 1, n do
        add[i]:insert_object_into_records(object)
    end
    
	remove(object, subtract)
end

function quadtree.remove(t, object)
	local m = meta[t]
	local masked = false

	for k, b in pairs(m.contents) do
		masked = masks(object_corner_map[k], object_corner_map[object], _m)
		if masked then break end
	end
	
	if not masked then 
		m.n = m.n - 1
	end
end

function quadtree.track(t, object, x1, x2, y1, y2)
    object_corner_map[object] = {x1, x2, y1, y2}
    t:insert(object)
end

function quadtree.do_not_track(t, object)
	local l = {}
	local n = 0
	
	for tree in pairs(object._quadtrees) do
		n = n + 1
		l[n] = tree
	end
	
	l.n = n
	
	remove(object, l)
	object_corner_map[object] = nil
end

--[[function quadtree.visualize(t)
	local pixel_array = {}
	
	local m = meta[t]
	local black = '\0\0\0'
	
	
		Trying to split pixels, etc. would be a headache. Round the
		width and height dimensions so that they're powers of two
		(as a result, all of the trees will land nicely on full pixels).
	
	
	local rounded_w = 2^(math.ceil(math.log(m.w)/math.log(2)))
	local rounded_h = 2^(math.ceil(math.log(m.h)/math.log(2)))
	
	for j = m.y1, m.y2 do
		local row = {}
		pixel_array[j] = row
		
		for i = m.x1, m.x2 do
			row[i] = black
		end			
	end
	
	pixel_array.x_start = m.x1
	pixel_array.y_start = m.y1
	pixel_array.x_end = m.y2
	pixel_array.y_end = m.y2

	quadtree.make_graphic(t, pixel_array, 0)
	
	return pixel_array
end
	
function quadtree.make_graphic(t, image, corner)
	local white = '\255\255\255'
	local red = '\255\0\0'
	local m = meta[t]
	
	if m.leaf then
		for	i = m.y1, m.y2 do
			local row = image[i]
			
			for j = m.x1, m.x2 do
				row[j] = corner % 3 == 1 and red or white
			end
		end
	else
		for i = 1, 4 do
			quadtree.make_graphic(m[i], image, i)
		end
	end
end

function quadtree.add_object_to_graphic(t, image, object)
	local trees = object._quadtrees
	
	if not trees then print('That object is not in any of the quadtree\'s leaves') return end

	local blue = '\0\0\255'
	local purple = '\255\0\255'
	
	for k, b in pairs(trees) do
		local m = meta[k]
		
		if not m.leaf then
			print('The object is in a branch!')
		end
		
		for i = m.y1, m.y1 do
			local row = image[i]
			
			for j = m.x1, m.x2 do
				row[j] = corner % 3 == 1 and purple or blue
			end
		end
	end
	
	return image
end

function quadtree.draw(t, image)
	local header = 'P6 width height 255\n'
end--]]

quadtree.debug = {}

function quadtree.debug.getn(t)
    return meta[t].n
end

function quadtree.debug.get_position(t)
    local m = meta[t]
    
    return m.x1, m.x2, m.y1, m.y2
end

function quadtree.debug.is_leaf(t)
    return meta[t].leaf
end

function quadtree.debug.get_quadrant(t, quadrant)
    return meta[t][quadrant]
end

function quadtree.debug.get_contents(t)
    if not meta[t].leaf then return end

    local bin = {}
    
    for k, v in pairs(meta[t].contents) do
        bin[k] = v
    end
    
    return bin
end
    
return quadtree
