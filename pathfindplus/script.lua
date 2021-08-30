-- SPDX-License-Identifier: Unlicense

g_cmd = "?pathfind"
g_announce_name = "[PathfindPlus]"
g_pf = nil

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, cmd, ...)
    if cmd ~= g_cmd then
        return
    end

    local player_name, is_success = server.getPlayerName(user_peer_id)
    if not is_success then
        player_name = "<player>"
    end
    server.announce(player_name, table.concat({g_cmd, ...}, " "), user_peer_id)

    local args = {}
    for _, s in ipairs({...}) do
        if s ~= "" then
            table.insert(args, s)
        end
    end

    local start_x = nil
    local start_z = nil
    local end_x = nil
    local end_z = nil
    local i = 1
    while args[i] ~= nil do
        if args[i] == "-start" then
            start_x = tonumber(args[i + 1])
            start_z = tonumber(args[i + 2])
            if start_x == nil or start_z == nil then
                server.announce(g_announce_name, "error: invalid parameter for -start", user_peer_id)
                return
            end
            i = i + 3
        elseif args[i] == "-end" then
            end_x = tonumber(args[i + 1])
            end_z = tonumber(args[i + 2])
            if end_x == nil or end_z == nil then
                server.announce(g_announce_name, "error: invalid parameter for -end", user_peer_id)
                return
            end
            i = i + 3
        else
            server.announce(g_announce_name, string.format('error: invalid argument "%s"', args[i]), user_peer_id)
            return
        end
    end

    if start_x == nil or start_z == nil then
        local player_pos, is_success = server.getPlayerPos(user_peer_id)
        if not is_success then
            server.announce(g_announce_name, "error: failed to get player position", user_peer_id)
            return
        end
        local player_x, _, player_z = matrix.position(player_pos)
        start_x = player_x
        start_z = player_z
    end
    if end_x == nil or end_z == nil then
        end_x = math.random(-96000, 82000)
        end_z = math.random(-82000, 144000)
    end

    local matrix_start = matrix.translation(start_x, 0, start_z)
    local matrix_end = matrix.translation(end_x, 0, end_z)

    local ocean_time_start = server.getTimeMillisec()
    local ocean_path_list = server.pathfindOcean(matrix_start, matrix_end)
    local ocean_time_end = server.getTimeMillisec()
    local ocean_bench = ocean_time_end - ocean_time_start

    local plus_time_start = server.getTimeMillisec()
    local plus_path_list = g_pf:pathfindOcean(matrix_start, matrix_end)
    local plus_time_end = server.getTimeMillisec()
    local plus_bench = plus_time_end - plus_time_start
    local plus_reachable = g_pf:getOceanReachable(matrix_start, matrix_end)

    server.removeMapObject(user_peer_id, g_savedata["ui_id"])
    server.removeMapLine(user_peer_id, g_savedata["ui_id"])
    server.addMapObject(user_peer_id, g_savedata["ui_id"], 0, 1, start_x, start_z, 0, 0, 0, 0, "start", 0, "PathfindPlus")
    server.addMapObject(user_peer_id, g_savedata["ui_id"], 0, 0, end_x, end_z, 0, 0, 0, 0, "end", 0, "PathfindPlus")

    local ocean_dist = 0
    local ocean_prev_x = start_x
    local ocean_prev_z = start_z
    for _, ocean_path in ipairs(ocean_path_list) do
        local ocean_next_x = ocean_path["x"]
        local ocean_next_z = ocean_path["z"]
        server.addMapLine(
            user_peer_id,
            g_savedata["ui_id"],
            matrix.translation(ocean_prev_x, 0, ocean_prev_z),
            matrix.translation(ocean_prev_x*0.75 + ocean_next_x*0.25, 0, ocean_prev_z*0.75 + ocean_next_z*0.25),
            1
        )
        server.addMapLine(
            user_peer_id,
            g_savedata["ui_id"],
            matrix.translation(ocean_prev_x*0.25 + ocean_next_x*0.75, 0, ocean_prev_z*0.25 + ocean_next_z*0.75),
            matrix.translation(ocean_next_x, 0, ocean_next_z),
            1
        )
        ocean_dist = ocean_dist + ((ocean_next_x - ocean_prev_x)^2 + (ocean_next_z - ocean_prev_z)^2)^0.5
        ocean_prev_x = ocean_next_x
        ocean_prev_z = ocean_next_z
    end

    local plus_dist = 0
    local plus_prev_x = start_x
    local plus_prev_z = start_z
    for _, plus_path in ipairs(plus_path_list) do
        local plus_next_x = plus_path["x"]
        local plus_next_z = plus_path["z"]
        server.addMapLine(
            user_peer_id,
            g_savedata["ui_id"],
            matrix.translation(plus_prev_x, 0, plus_prev_z),
            matrix.translation(plus_next_x, 0, plus_next_z),
            1
        )
        plus_dist = plus_dist + ((plus_next_x - plus_prev_x)^2 + (plus_next_z - plus_prev_z)^2)^0.5
        plus_prev_x = plus_next_x
        plus_prev_z = plus_next_z
    end

    local msg = {}
    table.insert(msg, string.format("PathfindOcean: %dms, %.1fkm", ocean_bench, ocean_dist/1000))
    table.insert(msg, string.format("PathfindPlus: %dms, %.1fkm%s", plus_bench, plus_dist/1000, plus_reachable and "" or " [unreachable]"))
    server.announce(g_announce_name, table.concat(msg, "\n"))
end

function onCreate(is_world_create)
    local version = 0
    if type(g_savedata) ~= "table" or g_savedata["version"] ~= version then
        g_savedata = {
            ["version"] = version,
            ["ui_id"] = server.getMapID(),
        }
    end

    g_pf = buildPathfinder()
    math.randomseed(server.getTimeMillisec())
end

function buildPathfinder()
    local pf = {
        _world_x1 = -76000,
        _world_z1 = -64000,
        _world_x2 = 64000,
        _world_z2 = 130000,
        _tile_size = 1000,
        _node_tbl = {},
        _temp_node_grp = {},
        _start_node_key = nil,
        _end_node_key = nil,
        _calc_tbl = {},
    }

    function pf:pathfindOcean(matrix_start, matrix_end)
        local start_x, _, start_z = matrix.position(matrix_start)
        local end_x, _, end_z = matrix.position(matrix_end)

        self:_reset()
        self._start_node_key = self:_setNode(start_x, start_z)
        self._end_node_key = self:_setNode(end_x, end_z)
        self:_calcPath()
        local path_list = self:_getPathList()
        self:_reset()
        return path_list
    end

    function pf:getOceanReachable(matrix_start, matrix_end)
        self:_reset()
        local world_area_key = self:_getNodeKey(-1/0, -1/0)

        local start_area_key = world_area_key
        local start_x, _, start_z = matrix.position(matrix_start)
        local start_tile_node = self:_getTileNode(start_x, start_z)
        if start_tile_node ~= nil then
            start_area_key = start_tile_node.area_key
        end

        local end_area_key = world_area_key
        local end_x, _, end_z = matrix.position(matrix_end)
        local end_tile_node = self:_getTileNode(end_x, end_z)
        if end_tile_node ~= nil then
            end_area_key = end_tile_node.area_key
        end

        return start_area_key ~= nil and start_area_key == end_area_key
    end

    function pf:_init()
        self:_initNode()
        self:_initEdge()
        self:_initArea()
    end

    function pf:_initNode()
        self._node_tbl = {}
        self._temp_node_grp = {}
        self._start_node_key = nil
        self._end_node_key = nil
        self._calc_tbl = {}

        for tile_x = self._world_x1 - self._tile_size, self._world_x2 + self._tile_size, self._tile_size do
            for tile_z = self._world_z1 - self._tile_size, self._world_z2 + self._tile_size, self._tile_size do
                local _, is_success = server.getOceanTransform(matrix.translation(tile_x, 0, tile_z), 0, 1)
                local node_key = self:_getNodeKey(tile_x, tile_z)
                self._node_tbl[node_key] = {
                    x = tile_x,
                    z = tile_z,
                    is_ocean = is_success,
                    edge_tbl = {},
                    area_key = nil,
                }
            end
        end
    end

    function pf:_initEdge()
        self:_reset()
        for _, node in pairs(self._node_tbl) do
            node.edge_tbl = {}
            node.area_key = nil
        end

        for _, this_node in pairs(self._node_tbl) do
            local next_node_tbl = {}
            local next_node_ocean_tbl = {}
            for _, dir in pairs({1, 2, 3, 4, 6, 7, 8, 9}) do
                local next_node_x = this_node.x + self._tile_size*((dir - 1)%3 - 1)
                local next_node_z = this_node.z + self._tile_size*((dir - 1)//3 - 1)
                local next_node_key = self:_getNodeKey(next_node_x, next_node_z)
                local next_node = self._node_tbl[next_node_key]

                next_node_ocean_tbl[dir] = true
                if next_node ~= nil then
                    next_node_tbl[dir] = next_node_key
                    next_node_ocean_tbl[dir] = next_node.is_ocean
                end
            end

            for dir, next_node_key in pairs(next_node_tbl) do
                local next_node = self._node_tbl[next_node_key]
                local dist = ((next_node.x - this_node.x)^2 + (next_node.z - this_node.z)^2)^0.5

                local cost = {ocean_dist = dist, risky_dist = 0}
                if (not this_node.is_ocean) or (not next_node.is_ocean) or (dir%2 == 1 and (not next_node_ocean_tbl[((dir - 1)//3)*3 + 2] or not next_node_ocean_tbl[(dir - 1)%3 + 4])) then
                    cost = {ocean_dist = 0, risky_dist = dist}
                end
                this_node.edge_tbl[next_node_key] = cost
            end
        end
    end

    function pf:_initArea()
        self:_reset()
        for _, node in pairs(self._node_tbl) do
            node.area_key = nil
        end

        for area_node_key, area_node in pairs(self._node_tbl) do
            if area_node.area_key ~= nil or not area_node.is_ocean then
                goto continue
            end

            local queue = {[area_node_key] = true}
            while true do
                local this_node_key = next(queue)
                if this_node_key == nil then
                    break
                end
                queue[this_node_key] = nil

                local this_node = self._node_tbl[this_node_key]
                this_node.area_key = area_node_key

                for next_node_key, cost in pairs(this_node.edge_tbl) do
                    local next_node = self._node_tbl[next_node_key]
                    if next_node.area_key == nil and cost.risky_dist <= 0 then
                        queue[next_node_key] = true
                    end
                end
            end

            ::continue::
        end

        local area_node_key = self:_getNodeKey(self._world_x1 - self._tile_size, self._world_z1 - self._tile_size)
        local area_node = self._node_tbl[area_node_key]
        if area_node ~= nil then
            local old_world_area_key = area_node.area_key
            local new_world_area_key = self:_getNodeKey(-1/0, -1/0)
            for _, this_node in pairs(self._node_tbl) do
                if this_node.area_key == old_world_area_key then
                    this_node.area_key = new_world_area_key
                end
            end
        end
    end

    function pf:_setNode(x, z)
        self._calc_tbl = {}

        local this_node_key = self:_getNodeKey(x, z)
        if self._node_tbl[this_node_key] ~= nil then
            return this_node_key
        end

        local this_node = {
            x = x,
            z = z,
            is_ocean = true,
            edge_tbl = {},
            area_key = self:_getNodeKey(-1/0, -1/0),
        }
        self._node_tbl[this_node_key] = this_node
        self._temp_node_grp[this_node_key] = true

        local tile_node = self:_getTileNode(x, z)
        if tile_node ~= nil and (tile_node.x ~= this_node.x or tile_node.z ~= this_node.z) then
            local tile_node_key = self:_getNodeKey(tile_node.x, tile_node.z)
            this_node.is_ocean = tile_node.is_ocean
            this_node.area_key = tile_node.area_key

            for next_node_key, tile_cost in pairs(tile_node.edge_tbl) do
                local next_node = self._node_tbl[next_node_key]
                local dist = ((next_node.x - this_node.x)^2 + (next_node.z - this_node.z)^2)^0.5
                local cost = {ocean_dist = dist, risky_dist = 0}
                if tile_cost.risky_dist > 0 then
                    cost = {ocean_dist = 0, risky_dist = dist}
                end
                this_node.edge_tbl[next_node_key] = cost
                next_node.edge_tbl[this_node_key] = cost
            end

            local dist = ((tile_node.x - this_node.x)^2 + (tile_node.z - this_node.z)^2)^0.5
            local cost = {ocean_dist = dist, risky_dist = 0}
            if not tile_node.is_ocean then
                cost = {ocean_dist = 0, risky_dist = dist}
            end
            this_node.edge_tbl[tile_node_key] = cost
            tile_node.edge_tbl[this_node_key] = cost
        end

        local rect_x1 = self._world_x1 - self._tile_size/2
        local rect_z1 = self._world_z1 - self._tile_size/2
        local rect_x2 = self._world_x2 + self._tile_size/2
        local rect_z2 = self._world_z2 + self._tile_size/2
        if this_node.x <= rect_x1 or rect_x2 <= this_node.x or this_node.z <= rect_z1 or rect_z2 <= this_node.z then
            for next_node_key, next_node in pairs(self._node_tbl) do
                if next_node_key ~= this_node_key and not self:_testRectAndLineCollision(rect_x1, rect_z1, rect_x2, rect_z2, this_node.x, this_node.z, next_node.x, next_node.z) then
                    local cost = {
                        ocean_dist = ((next_node.x - this_node.x)^2 + (next_node.z - this_node.z)^2)^0.5,
                        risky_dist = 0,
                    }
                    this_node.edge_tbl[next_node_key] = cost
                    next_node.edge_tbl[this_node_key] = cost
                end
            end
        end
        return this_node_key
    end

    function pf:_calcPath()
        self._calc_tbl = {}

        if self._start_node_key == nil then
            return
        end
        self._calc_tbl[self._start_node_key] = {
            visited = false,
            cost = {ocean_dist = 0, risky_dist = 0},
            prev_key = nil,
        }

        local end_node = self._node_tbl[self._end_node_key]

        local heap = {}
        self:_heapPush(heap, 0, 0, self._start_node_key)
        while true do
            local this_node_key = self:_heapPop(heap)
            if this_node_key == nil then
                break
            end

            local this_calc = self._calc_tbl[this_node_key]
            if this_calc.visited then
                goto continue
            end
            this_calc.visited = true
            if this_node_key == self._end_node_key then
                break
            end

            local this_node = self._node_tbl[this_node_key]
            for next_node_key, edge_cost in pairs(this_node.edge_tbl) do
                local next_calc = self._calc_tbl[next_node_key]
                if next_calc == nil then
                    next_calc = {
                        visited = false,
                        cost = nil,
                        prev_key = nil,
                    }
                    self._calc_tbl[next_node_key] = next_calc
                end

                local next_cost = {
                    ocean_dist = this_calc.cost.ocean_dist + edge_cost.ocean_dist,
                    risky_dist = this_calc.cost.risky_dist + edge_cost.risky_dist,
                }
                if next_calc.cost == nil or next_cost.risky_dist < next_calc.cost.risky_dist or (next_cost.risky_dist == next_calc.cost.risky_dist and next_cost.ocean_dist < next_calc.cost.ocean_dist) then
                    local astar_dist = 0
                    if end_node ~= nil then
                        local next_node = self._node_tbl[next_node_key]
                        astar_dist = ((next_node.x - end_node.x)^2 + (next_node.z - end_node.z)^2)^0.5
                    end

                    next_calc.cost = next_cost
                    next_calc.prev_key = this_node_key
                    self:_heapPush(heap, next_calc.cost.risky_dist, next_calc.cost.ocean_dist + astar_dist, next_node_key)
                end
            end

            ::continue::
        end
    end

    function pf:_getPathList()
        local path_list = {}
        local node_key = self._end_node_key
        while node_key ~= nil and node_key ~= self._start_node_key do
            local node = self._node_tbl[node_key]
            local calc = self._calc_tbl[node_key]
            table.insert(path_list, 1, {x = node.x, z = node.z})
            node_key = calc.prev_key
        end
        return path_list
    end

    function pf:_reset()
        self._start_node_key = nil
        self._end_node_key = nil
        self._calc_tbl = {}

        for temp_node_key, _ in pairs(self._temp_node_grp) do
            local temp_node = self._node_tbl[temp_node_key]
            for node_key, _ in pairs(temp_node.edge_tbl) do
                local node = self._node_tbl[node_key]
                node.edge_tbl[temp_node_key] = nil
            end
            self._node_tbl[temp_node_key] = nil
        end
        self._temp_node_grp = {}
    end

    function pf:_getTileNode(x, z)
        local tile_x = math.floor(x/(self._tile_size) + 0.5)*self._tile_size
        local tile_z = math.floor(z/(self._tile_size) + 0.5)*self._tile_size
        local tile_node_key = self:_getNodeKey(tile_x, tile_z)
        return self._node_tbl[tile_node_key]
    end

    function pf:_getNodeKey(x, z)
        local idx_s = 1024
        if (
            x%self._tile_size == 0 and -idx_s*self._tile_size <= x and x <= (idx_s - 1)*self._tile_size and
            z%self._tile_size == 0 and -idx_s*self._tile_size <= z and z <= (idx_s - 1)*self._tile_size
        ) then
            local idx_x = x//self._tile_size + idx_s
            local idx_z = z//self._tile_size + idx_s
            return idx_x*idx_s*2 + idx_z
        end

        return string.pack("ff", x, z)
    end

    function pf:_testRectAndLineCollision(rect_x1, rect_y1, rect_x2, rect_y2, line_x1, line_y1, line_x2, line_y2)
        return (
            (rect_x1 < line_x1 and line_x1 < rect_x2 and rect_y1 < line_y1 and line_y1 < rect_y2) or
            (rect_x1 < line_x2 and line_x2 < rect_x2 and rect_y1 < line_y2 and line_y2 < rect_y2) or
            self:_testLineAndLineCollision(rect_x1, rect_y1, rect_x1, rect_y2, line_x1, line_y1, line_x2, line_y2) or
            self:_testLineAndLineCollision(rect_x1, rect_y2, rect_x2, rect_y2, line_x1, line_y1, line_x2, line_y2) or
            self:_testLineAndLineCollision(rect_x2, rect_y2, rect_x2, rect_y1, line_x1, line_y1, line_x2, line_y2) or
            self:_testLineAndLineCollision(rect_x2, rect_y1, rect_x1, rect_y1, line_x1, line_y1, line_x2, line_y2)
        )
    end

    function pf:_testLineAndLineCollision(x11, y11, x12, y12, x21, y21, x22, y22)
        local x1211 = x12 - x11
        local y1211 = y12 - y11
        local x2111 = x21 - x11
        local y2111 = y21 - y11
        local x2211 = x22 - x11
        local y2211 = y22 - y11
        local x2221 = x22 - x21
        local y2221 = y22 - y21
        local x1121 = x11 - x21
        local y1121 = y11 - y21
        local x1221 = x12 - x21
        local y1221 = y12 - y21
        return (
            (((x1211*y2111 - x2111*y1211) * (x1211*y2211 - x2211*y1211)) < 0) and
            (((x2221*y1121 - x1121*y2221) * (x2221*y1221 - x1221*y2221)) < 0)
        )
    end

    function pf:_heapPush(heap, cost1, cost2, key)
        heap[#heap + 1] = {
            cost1 = cost1,
            cost2 = cost2,
            key = key,
        }

        local idx = #heap
        while idx > 1 do
            local item = heap[idx]
            local parent_idx = idx//2
            local parent_item = heap[parent_idx]
            if parent_item.cost1 < item.cost1 or (parent_item.cost1 == item.cost1 and parent_item.cost2 <= item.cost2) then
                break
            end

            heap[parent_idx] = item
            heap[idx] = parent_item
            idx = parent_idx
        end
    end

    function pf:_heapPop(heap)
        if heap[1] == nil then
            return nil
        end
        local key = heap[1].key

        heap[1] = heap[#heap]
        heap[#heap] = nil

        local idx = 1
        while true do
            local item = heap[idx]

            local child_idx = idx*2
            local child_item = heap[child_idx]
            if child_item == nil then
                break
            end

            local brother_idx = child_idx + 1
            local brother_item = heap[brother_idx]
            if brother_item ~= nil and (brother_item.cost1 < child_item.cost1 or (brother_item.cost1 == child_item.cost1 and brother_item.cost2 < child_item.cost2)) then
                child_idx = brother_idx
                child_item = brother_item
            end

            if item.cost1 < child_item.cost1 or (item.cost1 == child_item.cost1 and item.cost2 <= child_item.cost2) then
                break
            end
            heap[child_idx] = item
            heap[idx] = child_item
            idx = child_idx
        end
        return key
    end

    if server.isDev ~= nil then
        pf:_init()
    end
    return pf
end
