-- SPDX-License-Identifier: Unlicense

function test()
    local test_tbl = {
        {name = "testPathfindOcean", fn = testPathfindOcean},
        {name = "testGetOceanReachable", fn = testGetOceanReachable},
        {name = "testInitNode", fn = testInitNode},
        {name = "testInitEdge", fn = testInitEdge},
        {name = "testInitArea", fn = testInitArea},
        {name = "testSetNode", fn = testSetNode},
        {name = "testCalcPath", fn = testCalcPath},
        {name = "testGetPathList", fn = testGetPathList},
        {name = "testReset", fn = testReset},
        {name = "testGetTileNode", fn = testGetTileNode},
        {name = "testGetNodeKey", fn = testGetNodeKey},
        {name = "testTestRectAndLineCollision", fn = testTestRectAndLineCollision},
        {name = "testTestLineAndLineCollision", fn = testTestLineAndLineCollision},
        {name = "testHeap", fn = testHeap},
        {name = "testHeapPush", fn = testHeapPush},
        {name = "testHeapPop", fn = testHeapPop},
    }

    for _, test in ipairs(test_tbl) do
        local t = buildT()
        local is_success, err = pcall(test.fn, t)
        if not is_success then
            io.write(string.format("FAIL %s\n", test.name))
            io.write(string.format("     %s\n", err))
        else
            io.write(string.format("PASS %s\n", test.name))
        end
    end
end

function testPathfindOcean(t)
    local case_tbl = {
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_temp_node_grp = {
                [t.pf:_getNodeKey(0, -1000)] = true,
            },
            input_calc_tbl = {
                [t.pf:_getNodeKey(0, -1000)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
            },
            input_matrix_start = t.env.matrix.translation(-1, 0, -1),
            input_matrix_end = t.env.matrix.translation(1, 0, 1),
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_path_list = {
                {x = 1, z = 1},
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.pf._world_x1 = case.input_world_x1
        t.pf._world_z1 = case.input_world_z1
        t.pf._world_x2 = case.input_world_x2
        t.pf._world_z2 = case.input_world_z2
        t.pf._node_tbl = deepCopy(case.input_node_tbl)
        t.pf._temp_node_grp = deepCopy(case.input_temp_node_grp)
        t.pf._start_node_key = "dummy"
        t.pf._end_node_key = "dummy"
        t.pf._calc_tbl = deepCopy(case.input_calc_tbl)
        local actual_path_list = t.pf:pathfindOcean(case.input_matrix_start, case.input_matrix_end)
        if not deepEqual(case.expected_node_tbl, t.pf._node_tbl) then
            error(string.format("case #%d: wrong node_tbl", case_idx))
        end
        if not deepEqual({}, t.pf._temp_node_grp) then
            error(string.format("case #%d: temp_node_grp not empty", case_idx))
        end
        if t.pf._start_node_key ~= nil then
            error(string.format("case #%d: wrong start_node_key (expected nil, got %s)", case_idx, t.pf._start_node_key))
        end
        if t.pf._end_node_key ~= nil then
            error(string.format("case #%d: wrong end_node_key (expected nil, got %s)", case_idx, t.pf._end_node_key))
        end
        if not deepEqual({}, t.pf._calc_tbl) then
            error(string.format("case #%d: calc_tbl not empty", case_idx))
        end
        if not deepEqual(case.expected_path_list, actual_path_list) then
            error(string.format("case #%d: wrong path_list", case_idx))
        end
    end
end

function testGetOceanReachable(t)
    local case_tbl = {
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_matrix_start = t.env.matrix.translation(0, 0, 0),
            input_matrix_end = t.env.matrix.translation(0, 0, 1000),
            expected_ret = true,
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 1000),
                },
            },
            input_matrix_start = t.env.matrix.translation(0, 0, 0),
            input_matrix_end = t.env.matrix.translation(0, 0, 1000),
            expected_ret = false,
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            input_matrix_start = t.env.matrix.translation(0, 0, 0),
            input_matrix_end = t.env.matrix.translation(0, 0, 1000),
            expected_ret = false,
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
            },
            input_matrix_start = t.env.matrix.translation(0, 0, 0),
            input_matrix_end = t.env.matrix.translation(0, 0, 2000),
            expected_ret = true,
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
            },
            input_matrix_start = t.env.matrix.translation(0, 0, 2000),
            input_matrix_end = t.env.matrix.translation(0, 0, 0),
            expected_ret = true,
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.pf._node_tbl = deepCopy(case.input_node_tbl)
        t.pf._start_node_key = nil
        t.pf._end_node_key = "dummy"
        local actual_ret = t.pf:getOceanReachable(case.input_matrix_start, case.input_matrix_end)
        if not deepEqual(case.input_node_tbl, t.pf._node_tbl) then
            error(string.format("case #%d: wrong node_tbl", case_idx))
        end
        if t.pf._start_node_key ~= nil then
            error(string.format("case #%d: start_node_key not nil", case_idx))
        end
        if t.pf._end_node_key ~= nil then
            error(string.format("case #%d: end_node_key not nil", case_idx))
        end
        if actual_ret ~= case.expected_ret then
            error(string.format("case #%d: wrong return value (expected %s, got %s)", case_idx, case.expected_ret, actual_ret))
        end
    end
end

function testInitNode(t)
    local case_tbl = {
        {
            input_tile_tbl = {},
            input_world_x1 = -1000,
            input_world_z1 = 0,
            input_world_x2 = 1000,
            input_world_z2 = 0,
            expected_node_tbl = {
                [t.pf:_getNodeKey(-2000, -1000)] = {
                    x = -2000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-2000, -0)] = {
                    x = -2000,
                    z = -0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-2000, 1000)] = {
                    x = -2000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, -1000)] = {
                    x = -1000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, -0)] = {
                    x = -1000,
                    z = -0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, 1000)] = {
                    x = -1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, -0)] = {
                    x = 0,
                    z = -0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, -1000)] = {
                    x = 1000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, -0)] = {
                    x = 1000,
                    z = -0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(2000, -1000)] = {
                    x = 2000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(2000, -0)] = {
                    x = 2000,
                    z = -0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(2000, 1000)] = {
                    x = 2000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
        },
        {
            input_tile_tbl = {},
            input_world_x1 = 0,
            input_world_z1 = -1000,
            input_world_x2 = 0,
            input_world_z2 = 1000,
            expected_node_tbl = {
                [t.pf:_getNodeKey(-1000, -2000)] = {
                    x = -1000,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, -2000)] = {
                    x = 0,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, -2000)] = {
                    x = 1000,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, -1000)] = {
                    x = -1000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, -1000)] = {
                    x = 1000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, 0)] = {
                    x = -1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, 1000)] = {
                    x = -1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, 2000)] = {
                    x = -1000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 2000)] = {
                    x = 0,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 2000)] = {
                    x = 1000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
        },
        {
            input_tile_tbl = {
                [0] = {
                    [0] = {
                        ["name"] = "island",
                        ["sea_floor"] = -30,
                        ["cost"] = 0,
                        ["purchased"] = false,
                    },
                },
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            expected_node_tbl = {
                [t.pf:_getNodeKey(-1000, -1000)] = {
                    x = -1000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, 0)] = {
                    x = -1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, 1000)] = {
                    x = -1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, -1000)] = {
                    x = 1000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.cfg.tile_tbl = case.input_tile_tbl
        t.pf._world_x1 = case.input_world_x1
        t.pf._world_z1 = case.input_world_z1
        t.pf._world_x2 = case.input_world_x2
        t.pf._world_z2 = case.input_world_z2
        t.pf._node_tbl = "dummy"
        t.pf._temp_node_grp = "dummy"
        t.pf._start_node_key = "dummy"
        t.pf._end_node_key = "dummy"
        t.pf._calc_tbl = "dummy"
        t.pf:_initNode()
        if not deepEqual(case.expected_node_tbl, t.pf._node_tbl) then
            error(string.format("case #%d: wrong node_tbl", case_idx))
        end
        if not deepEqual({}, t.pf._temp_node_grp) then
            error(string.format("case #%d: temp_node_grp not empty", case_idx))
        end
        if t.pf._start_node_key ~= nil then
            error(string.format("case #%d: start_node_key not nil", case_idx))
        end
        if t.pf._end_node_key ~= nil then
            error(string.format("case #5d: end_node_key not nil", case_idx))
        end
        if not deepEqual({}, t.pf._calc_tbl) then
            error(string.format("case #%d: calc_tbl not empty", case_idx))
        end
    end
end

function testInitEdge(t)
    local case_tbl = {
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = math.sqrt(2000000), risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = math.sqrt(2000000), risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = math.sqrt(2000000), risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = math.sqrt(2000000), risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.pf._node_tbl = deepCopy(case.input_node_tbl)
        t.pf._start_node_key = nil
        t.pf._end_node_key = "dummy"
        t.pf:_initEdge()
        if not deepEqual(case.expected_node_tbl, t.pf._node_tbl) then
            error(string.format("case #%d: wrong node_tbl", case_idx))
        end
        if t.pf._start_node_key ~= nil then
            error(string.format("case #%d: start_node_key not nil", case_idx))
        end
        if t.pf._end_node_key ~= nil then
            error(string.format("case #%d: end_node_key not nil", case_idx))
        end
    end
end

function testInitArea(t)
    local case_tbl = {
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
        },
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
        },
        {
            input_world_x1 = -2000,
            input_world_z1 = -2000,
            input_world_x2 = 2000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, -1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
            },
            expected_area_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {t.pf:_getNodeKey(0, 0), t.pf:_getNodeKey(0, 1000)},
            },
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, -1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = t.pf:_getNodeKey(0, -1000),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
            },
        },
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [t.pf:_getNodeKey(-1000, -1000)] = {
                    x = -1000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(-1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(-1000, 0)] = {
                    x = -1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(-1000, -1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [t.pf:_getNodeKey(-1000, -1000)] = {
                    x = -1000,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(-1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
                [t.pf:_getNodeKey(-1000, 0)] = {
                    x = -1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(-1000, -1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.pf._world_x1 = case.input_world_x1
        t.pf._world_z1 = case.input_world_z1
        t.pf._world_x2 = case.input_world_x2
        t.pf._world_z2 = case.input_world_z2
        t.pf._node_tbl = deepCopy(case.input_node_tbl)
        t.pf._start_node_key = nil
        t.pf._end_node_key = "dummy"
        t.pf:_initArea()

        local expected_node_tbl = deepCopy(case.expected_node_tbl)
        for area_key, node_key_list in pairs(case.expected_area_tbl) do
            for _, node_key in pairs(node_key_list) do
                expected_node_tbl[node_key].area_key = t.pf._node_tbl[area_key].area_key
            end
        end

        if not deepEqual(expected_node_tbl, t.pf._node_tbl) then
            error(string.format("case #%d: wrong node_tbl", case_idx))
        end
        if t.pf._start_node_key ~= nil then
            error(string.format("case #%d: start_node_key not nil", case_idx))
        end
        if t.pf._end_node_key ~= nil then
            error(string.format("case #%d: end_node_key not nil", case_idx))
        end
    end
end

function testSetNode(t)
    local case_tbl = {
        {
            input_world_x1 = -1000,
            input_world_z1 = -1000,
            input_world_x2 = 1000,
            input_world_z2 = 1000,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_x = 0,
            input_z = 0,
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_temp_node_grp = {},
            expected_node_key = t.pf:_getNodeKey(0, 0),
        },
        {
            input_world_x1 = -2000,
            input_world_z1 = -2000,
            input_world_x2 = 2000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_x = 0,
            input_z = 1,
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 999, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 999, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_temp_node_grp = {
                [t.pf:_getNodeKey(0, 1)] = true,
            },
            expected_node_key = t.pf:_getNodeKey(0, 1),
        },
        {
            input_world_x1 = -2000,
            input_world_z1 = -2000,
            input_world_x2 = 2000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = t.pf:_getNodeKey(0, 1000),
                },
            },
            input_x = 0,
            input_z = 1,
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 999},
                    },
                    area_key = t.pf:_getNodeKey(0, 1000),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = false,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 999},
                    },
                    area_key = nil,
                },
            },
            expected_temp_node_grp = {
                [t.pf:_getNodeKey(0, 1)] = true,
            },
            expected_node_key = t.pf:_getNodeKey(0, 1),
        },
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_x = -1000,
            input_z = 0,
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(-1000, 0)] = {
                    x = -1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
            },
            expected_temp_node_grp = {
                [t.pf:_getNodeKey(-1000, 0)] = true,
            },
            expected_node_key = t.pf:_getNodeKey(-1000, 0),
        },
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_x = 0,
            input_z = -1000,
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
            },
            expected_temp_node_grp = {
                [t.pf:_getNodeKey(0, -1000)] = true,
            },
            expected_node_key = t.pf:_getNodeKey(0, -1000),
        },
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_x = 1000,
            input_z = 0,
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
            },
            expected_temp_node_grp = {
                [t.pf:_getNodeKey(1000, 0)] = true,
            },
            expected_node_key = t.pf:_getNodeKey(1000, 0),
        },
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_x = 0,
            input_z = 1000,
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
            },
            expected_temp_node_grp = {
                [t.pf:_getNodeKey(0, 1000)] = true,
            },
            expected_node_key = t.pf:_getNodeKey(0, 1000),
        },
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [t.pf:_getNodeKey(-2000, -2000)] = {
                    x = -2000,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
            },
            input_x = -2000,
            input_z = 2000,
            expected_node_tbl = {
                [t.pf:_getNodeKey(-2000, -2000)] = {
                    x = -2000,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(-2000, 2000)] = {ocean_dist = 4000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
                [t.pf:_getNodeKey(-2000, 2000)] = {
                    x = -2000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(-2000, -2000)] = {ocean_dist = 4000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(-1/0, -1/0),
                },
            },
            expected_temp_node_grp = {
                [t.pf:_getNodeKey(-2000, 2000)] = true,
            },
            expected_node_key = t.pf:_getNodeKey(-2000, 2000),
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.pf._world_x1 = case.input_world_x1
        t.pf._world_z1 = case.input_world_z1
        t.pf._world_x2 = case.input_world_x2
        t.pf._world_z2 = case.input_world_z2
        t.pf._node_tbl = deepCopy(case.input_node_tbl)
        t.pf._temp_node_grp = {}
        t.pf._calc_tbl = "dummy"
        local actual_node_key = t.pf:_setNode(case.input_x, case.input_z)
        if not deepEqual(case.expected_node_tbl, t.pf._node_tbl) then
            error(string.format("case #%d: wrong node_tbl", case_idx))
        end
        if not deepEqual(case.expected_temp_node_grp, t.pf._temp_node_grp) then
            error(string.format("case #%d: wrong temp_node_grp", case_idx))
        end
        if not deepEqual({}, t.pf._calc_tbl) then
            error(string.format("case #%d: calc_tbl not empty", case_idx))
        end
        if actual_node_key ~= case.expected_node_key then
            error(string.format("case #%d: wrong node_key", case_idx))
        end
    end
end

function testCalcPath(t)
    local case_tbl = {
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = t.pf:_getNodeKey(0, 0),
            input_end_node_key = nil,
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = t.pf:_getNodeKey(0, 0),
            input_end_node_key = t.pf:_getNodeKey(0, 0),
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 3)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = t.pf:_getNodeKey(0, 0),
            input_end_node_key = t.pf:_getNodeKey(0, 3),
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 3)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    visited = true,
                    cost = {ocean_dist = 3, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 2),
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 3, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 3, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 3)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = t.pf:_getNodeKey(0, 0),
            input_end_node_key = t.pf:_getNodeKey(0, 3),
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 3, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 3, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 3)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 1),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    visited = true,
                    cost = {ocean_dist = 4, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 2),
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 3, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 3, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                        [t.pf:_getNodeKey(0, 3)] = {ocean_dist = 0, risky_dist = 3},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 3},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = t.pf:_getNodeKey(0, 0),
            input_end_node_key = t.pf:_getNodeKey(0, 3),
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 3, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 3, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                        [t.pf:_getNodeKey(0, 3)] = {ocean_dist = 0, risky_dist = 3},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 3},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 1},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    visited = true,
                    cost = {ocean_dist = 3, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    visited = true,
                    cost = {ocean_dist = 3, risky_dist = 3},
                    prev_key = t.pf:_getNodeKey(0, 2),
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 3)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = t.pf:_getNodeKey(0, 0),
            input_end_node_key = t.pf:_getNodeKey(0, 3),
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 3)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 1),
                },
                [t.pf:_getNodeKey(0, 3)] = {
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 1},
                    prev_key = t.pf:_getNodeKey(0, 2),
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(2000, 2000)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(2000, 2000)] = {
                    x = 2000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = t.pf:_getNodeKey(0, 0),
            input_end_node_key = t.pf:_getNodeKey(2000, 2000),
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(2000, 2000)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(2000, 2000)] = {
                    x = 2000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    visited = false,
                    cost = {ocean_dist = 1000, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    visited = true,
                    cost = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(2000, 2000)] = {
                    visited = true,
                    cost = {ocean_dist = 8000000^0.5, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(1000, 1000),
                },
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(2000, 2000)] = {ocean_dist = 0, risky_dist = 2000000^0.5},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(2000, 2000)] = {
                    x = 2000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 2000000^0.5},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = t.pf:_getNodeKey(0, 0),
            input_end_node_key = t.pf:_getNodeKey(2000, 2000),
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 2000000^0.5, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [t.pf:_getNodeKey(2000, 2000)] = {ocean_dist = 0, risky_dist = 2000000^0.5},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(2000, 2000)] = {
                    x = 2000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 2000000^0.5},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            expected_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [t.pf:_getNodeKey(0, 1000)] = {
                    visited = true,
                    cost = {ocean_dist = 1000, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(1000, 1000)] = {
                    visited = true,
                    cost = {ocean_dist = 2000000^0.5, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(2000, 2000)] = {
                    visited = true,
                    cost = {ocean_dist = 2000000^0.5, risky_dist = 2000000^0.5},
                    prev_key = t.pf:_getNodeKey(1000, 1000),
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.pf._node_tbl = deepCopy(case.input_node_tbl)
        t.pf._start_node_key = case.input_start_node_key
        t.pf._end_node_key = case.input_end_node_key
        t.pf._calc_tbl = "dummy"
        t.pf:_calcPath()
        if not deepEqual(case.expected_node_tbl, t.pf._node_tbl) then
            error(string.format("case #%d: wrong node_tbl", case_idx))
        end
        if not deepEqual(case.expected_calc_tbl, t.pf._calc_tbl) then
            error(string.format("case #%d: wrong calc_tbl", case_idx))
        end
    end
end

function testGetPathList(t)
    local case_tbl = {
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 2,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = t.pf:_getNodeKey(0, 0),
            input_end_node_key = t.pf:_getNodeKey(0, 2),
            input_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 1),
                },
            },
            expected = {
                {x = 0, z = 1},
                {x = 0, z = 2},
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 2,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = nil,
            input_end_node_key = t.pf:_getNodeKey(0, 2),
            input_calc_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 2)] = {
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 0},
                    prev_key = t.pf:_getNodeKey(0, 1),
                },
            },
            expected = {
                {x = 0, z = 0},
                {x = 0, z = 1},
                {x = 0, z = 2},
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.pf._node_tbl = deepCopy(case.input_node_tbl)
        t.pf._start_node_key = case.input_start_node_key
        t.pf._end_node_key = case.input_end_node_key
        t.pf._calc_tbl = deepCopy(case.input_calc_tbl)
        local actual = t.pf:_getPathList()
        if not deepEqual(case.expected, actual) then
            error(string.format("case #%d: wrong path_list", case_idx))
        end
    end
end

function testReset(t)
    local case_tbl = {
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, -1)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, -1)] = {
                    x = 0,
                    z = -1,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, 1)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [t.pf:_getNodeKey(0, -1)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
            input_temp_node_grp = {
                [t.pf:_getNodeKey(0, 1)] = true,
            },
            expected_node_tbl = {
                [t.pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, -1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
                [t.pf:_getNodeKey(0, -1)] = {
                    x = 0,
                    z = -1,
                    is_ocean = true,
                    edge_tbl = {
                        [t.pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = t.pf:_getNodeKey(0, 0),
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.pf._node_tbl = deepCopy(case.input_node_tbl)
        t.pf._temp_node_grp = deepCopy(case.input_temp_node_grp)
        t.pf._start_node_key = "dummy"
        t.pf._end_node_key = "dummy"
        t.pf._calc_tbl = "dummy"
        t.pf:_reset()
        if not deepEqual(case.expected_node_tbl, t.pf._node_tbl) then
            error(string.format("case #%d: wrong node_tbl", case_idx))
        end
        if not deepEqual({}, t.pf._temp_node_grp) then
            error(string.format("case #%d: temp_node_grp not empty", case_idx))
        end
        if t.pf._start_node_key ~= nil then
            error(string.format("case #%d: wrong start_node_key (expected nil, got %s)", case_idx, t.pf._start_node_key))
        end
        if t.pf._end_node_key ~= nil then
            error(string.format("case #%d: wrong end_node_key (expected nil, got %s)", case_idx, t.pf._end_node_key))
        end
        if not deepEqual({}, t.pf._calc_tbl) then
            error(string.format("case #%d: calc_tbl not empty", case_idx))
        end
    end
end

function testGetTileNode(t)
    local case_tbl = {
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(1000, 2000)] = {
                    x = 1000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            input_x = 0,
            input_z = 0,
            expected = nil,
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(1000, 2000)] = {
                    x = 1000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            input_x = 500,
            input_z = 2499,
            expected = {
                x = 1000,
                z = 2000,
                is_ocean = true,
                edge_tbl = {},
                area_key = nil,
            },
        },
        {
            input_node_tbl = {
                [t.pf:_getNodeKey(1000, 2000)] = {
                    x = 1000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                },
            },
            input_x = 1499,
            input_z = 1500,
            expected = {
                x = 1000,
                z = 2000,
                is_ocean = true,
                edge_tbl = {},
                area_key = nil,
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        t.pf._node_tbl = deepCopy(case.input_node_tbl)
        local actual = t.pf:_getTileNode(case.input_x, case.input_z)
        if not deepEqual(case.expected, actual) then
            error(string.format("case #%d: wrong node", case_idx))
        end
    end
end

function testGetNodeKey(t)
    local case_tbl = {
        {input_x = 0, input_z = 0, expected = 2098176},
        {input_x = 1, input_z = 0, expected = string.pack("ff", 1, 0)},
        {input_x = -1025000, input_z = 0, expected = string.pack("ff", -1025000, 0)},
        {input_x = 1024000, input_z = 0, expected = string.pack("ff", 1024000, 0)},
        {input_x = 0, input_z = 1, expected = string.pack("ff", 0, 1)},
        {input_x = 0, input_z = -1025000, expected = string.pack("ff", 0, -1025000)},
        {input_x = 0, input_z = 1024000, expected = string.pack("ff", 0, 1024000)},
        {input_x = -1024000, input_z = -1024000, expected = 0},
        {input_x = 1023000, input_z = 1023000, expected = 4194303},
        {input_x = -1024000, input_z = 1023000, expected = 2047},
        {input_x = -1023000, input_z = -1024000, expected = 2048},
    }

    for case_idx, case in ipairs(case_tbl) do
        local actual = t.pf:_getNodeKey(case.input_x, case.input_z)
        if case.expected ~= actual then
            error(string.format("case #%d: wrong key", case_idx))
        end
    end
end

function testTestRectAndLineCollision(t)
    local case_tbl = {
        {input_list = {-1, -1, 1, 1, 0, 0, 0, 0}, expected = true},
        {input_list = {-1, -1, 1, 1, -3, 0, 0, 3}, expected = false},
        {input_list = {-1, -1, 1, 1, -2, 0, 0, 0}, expected = true},
        {input_list = {-1, -1, 1, 1, 0, 0, 2, 0}, expected = true},
        {input_list = {-1, -1, 1, 1, 0, -2, 0, 0}, expected = true},
        {input_list = {-1, -1, 1, 1, 0, 0, 0, 2}, expected = true},
    }

    for case_idx, case in ipairs(case_tbl) do
        local actual = t.pf:_testRectAndLineCollision(table.unpack(case.input_list))
        if case.expected ~= actual then
            error(string.format("case #%d: expected %s, got %s", case_idx, case.expected, actual))
        end
    end
end

function testTestLineAndLineCollision(t)
    local case_tbl = {
        {input_list = {0, 0, 0, 1, 0.5, 0.5, 0.5, 0.5}, expected = false},
        {input_list = {0.5, 0.5, 0.5, 0.5, 0, 0, 1, 0}, expected = false},
        {input_list = {0, 0, 1, 0, 0.5, -1.5, 0.5, -0.5}, expected = false},
        {input_list = {0, 0, 1, 0, 0.5, -0.5, 0.5, 0.5}, expected = true},
        {input_list = {0, 0, 1, 0, 0.5, 0.5, 0.5, 1.5}, expected = false},
        {input_list = {-1.5, 0.5, -0.5, 0.5, 0, 0, 0, 1}, expected = false},
        {input_list = {-0.5, 0.5, 0.5, 0.5, 0, 0, 0, 1}, expected = true},
        {input_list = {0.5, 0.5, 1.5, 0.5, 0, 0, 0, 1}, expected = false},
    }

    for case_idx, case in ipairs(case_tbl) do
        local actual = t.pf:_testLineAndLineCollision(table.unpack(case.input_list))
        if case.expected ~= actual then
            error(string.format("case #%d: expected %s, got %s", case_idx, case.expected, actual))
        end
    end
end

function testHeap(t)
    local input_list = {43, 10, 41, 24, 23, 12, 53, 31, 96, 33, 22, 49, 27, 74, 72, 19, 16, 56, 52, 59, 93, 15, 17, 64, 32, 75, 14, 20, 98, 3, 90, 63, 94, 81, 0, 8, 80, 87, 76, 5, 39, 7, 83, 89, 51, 42, 60, 69, 4, 67, 11, 26, 71, 40, 61, 30, 38, 18, 77, 92, 97, 25, 36, 48, 47, 34, 73, 1, 9, 21, 82, 84, 28, 2, 68, 95, 50, 65, 91, 70, 29, 99, 55, 58, 88, 86, 37, 85, 35, 66, 62, 45, 46, 54, 79, 6, 57, 78, 13, 44}
    local expected_list = deepCopy(input_list)
    table.sort(expected_list)

    local actual_list = {}
    local heap = {}
    for _, input in ipairs(input_list) do
        t.pf:_heapPush(heap, input//10, input%10, input)
    end
    while true do
        local actual = t.pf:_heapPop(heap)
        if actual == nil then
            break
        end
        table.insert(actual_list, actual)
    end

    if not deepEqual(expected_list, actual_list) then
        error("failed")
    end
end

function testHeapPush(t)
    local case_tbl = {
        {
            input_heap = {},
            input_cost1 = 1,
            input_cost2 = 2,
            input_key = 3,
            expected_heap = {
                [1] = {cost1 = 1, cost2 = 2, key = 3},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = -1, cost2 = -1, key = 1},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 2,
            expected_heap = {
                [1] = {cost1 = -1, cost2 = -1, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = -1, cost2 = 0, key = 1},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 2,
            expected_heap = {
                [1] = {cost1 = -1, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = -1, cost2 = 1, key = 1},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 2,
            expected_heap = {
                [1] = {cost1 = -1, cost2 = 1, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = -1, key = 1},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 2,
            expected_heap = {
                [1] = {cost1 = 0, cost2 = -1, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 2,
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 1, key = 1},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 2,
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 0, cost2 = 1, key = 1},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = 1, cost2 = -1, key = 1},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 2,
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 1, cost2 = -1, key = 1},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = 1, cost2 = 0, key = 1},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 2,
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 1, cost2 = 0, key = 1},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = 1, cost2 = 1, key = 1},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 2,
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 1, cost2 = 1, key = 1},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 1, key = 1},
                [2] = {cost1 = 0, cost2 = 3, key = 2},
                [3] = {cost1 = 0, cost2 = 5, key = 3},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
                [5] = {cost1 = 0, cost2 = 9, key = 5},
            },
            input_cost1 = 0,
            input_cost2 = 6,
            input_key = 6,
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 1, key = 1},
                [2] = {cost1 = 0, cost2 = 3, key = 2},
                [3] = {cost1 = 0, cost2 = 5, key = 3},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
                [5] = {cost1 = 0, cost2 = 9, key = 5},
                [6] = {cost1 = 0, cost2 = 6, key = 6},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 1, key = 1},
                [2] = {cost1 = 0, cost2 = 3, key = 2},
                [3] = {cost1 = 0, cost2 = 5, key = 3},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
                [5] = {cost1 = 0, cost2 = 9, key = 5},
            },
            input_cost1 = 0,
            input_cost2 = 4,
            input_key = 6,
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 1, key = 1},
                [2] = {cost1 = 0, cost2 = 3, key = 2},
                [3] = {cost1 = 0, cost2 = 4, key = 6},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
                [5] = {cost1 = 0, cost2 = 9, key = 5},
                [6] = {cost1 = 0, cost2 = 5, key = 3},
            },
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 1, key = 1},
                [2] = {cost1 = 0, cost2 = 3, key = 2},
                [3] = {cost1 = 0, cost2 = 5, key = 3},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
                [5] = {cost1 = 0, cost2 = 9, key = 5},
            },
            input_cost1 = 0,
            input_cost2 = 0,
            input_key = 6,
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 6},
                [2] = {cost1 = 0, cost2 = 3, key = 2},
                [3] = {cost1 = 0, cost2 = 1, key = 1},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
                [5] = {cost1 = 0, cost2 = 9, key = 5},
                [6] = {cost1 = 0, cost2 = 5, key = 3},
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        local heap = deepCopy(case.input_heap)
        t.pf:_heapPush(heap, case.input_cost1, case.input_cost2, case.input_key)
        if not deepEqual(case.expected_heap, heap) then
            error(string.format("case #%d: wrong heap", case_idx))
        end
    end
end

function testHeapPop(t)
    local case_tbl = {
        {
            input_heap = {},
            expected_heap = {},
            expected_key = nil,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
            },
            expected_heap = {},
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = -1, cost2 = -1, key = 3},
                [4] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_heap = {
                [1] = {cost1 = -1, cost2 = -1, key = 3},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = -1, cost2 = 0, key = 3},
                [4] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_heap = {
                [1] = {cost1 = -1, cost2 = 0, key = 3},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = -1, cost2 = 1, key = 3},
                [4] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_heap = {
                [1] = {cost1 = -1, cost2 = 1, key = 3},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 0, cost2 = -1, key = 3},
                [4] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = -1, key = 3},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 0, cost2 = 0, key = 3},
                [4] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 2, cost2 = 0, key = 4},
                [3] = {cost1 = 0, cost2 = 0, key = 3},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 0, cost2 = 1, key = 3},
                [4] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 2, cost2 = 0, key = 4},
                [3] = {cost1 = 0, cost2 = 1, key = 3},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 1, cost2 = -1, key = 3},
                [4] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 2, cost2 = 0, key = 4},
                [3] = {cost1 = 1, cost2 = -1, key = 3},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 1, cost2 = 0, key = 3},
                [4] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 2, cost2 = 0, key = 4},
                [3] = {cost1 = 1, cost2 = 0, key = 3},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 1, cost2 = 1, key = 3},
                [4] = {cost1 = 2, cost2 = 0, key = 4},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 2, cost2 = 0, key = 4},
                [3] = {cost1 = 1, cost2 = 1, key = 3},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = -1, cost2 = -1, key = 3},
            },
            expected_heap = {
                [1] = {cost1 = -1, cost2 = -1, key = 3},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = -1, cost2 = 0, key = 3},
            },
            expected_heap = {
                [1] = {cost1 = -1, cost2 = 0, key = 3},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = -1, cost2 = 1, key = 3},
            },
            expected_heap = {
                [1] = {cost1 = -1, cost2 = 1, key = 3},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 0, cost2 = -1, key = 3},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = -1, key = 3},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 0, cost2 = 0, key = 3},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 3},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 0, cost2 = 1, key = 3},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 0, cost2 = 1, key = 3},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 1, cost2 = -1, key = 3},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 1, cost2 = -1, key = 3},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 1, cost2 = 0, key = 3},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 1, cost2 = 0, key = 3},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 1},
                [2] = {cost1 = 0, cost2 = 0, key = 2},
                [3] = {cost1 = 1, cost2 = 1, key = 3},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 0, key = 2},
                [2] = {cost1 = 1, cost2 = 1, key = 3},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 1, key = 1},
                [2] = {cost1 = 0, cost2 = 3, key = 2},
                [3] = {cost1 = 0, cost2 = 5, key = 3},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
                [5] = {cost1 = 0, cost2 = 9, key = 5},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 3, key = 2},
                [2] = {cost1 = 0, cost2 = 7, key = 4},
                [3] = {cost1 = 0, cost2 = 5, key = 3},
                [4] = {cost1 = 0, cost2 = 9, key = 5},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 1, key = 1},
                [2] = {cost1 = 0, cost2 = 5, key = 2},
                [3] = {cost1 = 0, cost2 = 3, key = 3},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
                [5] = {cost1 = 0, cost2 = 9, key = 5},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 3, key = 3},
                [2] = {cost1 = 0, cost2 = 5, key = 2},
                [3] = {cost1 = 0, cost2 = 9, key = 5},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
            },
            expected_key = 1,
        },
        {
            input_heap = {
                [1] = {cost1 = 0, cost2 = 1, key = 1},
                [2] = {cost1 = 0, cost2 = 3, key = 2},
                [3] = {cost1 = 0, cost2 = 5, key = 3},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
                [5] = {cost1 = 0, cost2 = 4, key = 5},
            },
            expected_heap = {
                [1] = {cost1 = 0, cost2 = 3, key = 2},
                [2] = {cost1 = 0, cost2 = 4, key = 5},
                [3] = {cost1 = 0, cost2 = 5, key = 3},
                [4] = {cost1 = 0, cost2 = 7, key = 4},
            },
            expected_key = 1,
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        local heap = deepCopy(case.input_heap)
        local actual_key = t.pf:_heapPop(heap)
        if not deepEqual(case.expected_heap, heap) then
            error(string.format("case #%d: wrong heap", case_idx))
        end
        if actual_key ~= case.expected_key then
            error(string.format("case #%d: wrong key (expected %s, got %s)", case_idx, case.expected_key, actual_key))
        end
    end
end

function buildT()
    local cfg = {}
    local env = buildEnv(cfg)
    loadfile("script.lua", "t", env)()
    local pf = env.buildPathfinder()
    return {
        cfg = cfg,
        env = env,
        pf = pf,
    }
end

function buildEnv(cfg)
    local env = {
        server = {},
        matrix = {},

        math = math,
        table = table,
        string = string,
        pairs = pairs,
        ipairs = ipairs,
        next = next,
        tostring = tostring,
        tonumber = tonumber,
        type = type,
    }

    function env.server.getOceanTransform(mat, min_search_range, max_search_range)
        if min_search_range ~= 0 then
            error(string.format("unsupported argument to min_search_range (0 expected, got "%s")", min_search_range))
        end
        if max_search_range ~= 1 then
            error(string.format("unsupported argument to max_search_range (1 expected, got "%s")", max_search_range))
        end

        local mat_x, _, mat_z = env.matrix.position(mat)
        if mat_x%1 ~= 0 then
            error(string.format("unsupported argument to mat_x (integer expected, got "%s")", mat_x))
        end
        if mat_z%1 ~= 0 then
            error(string.format("unsupported argument to mat_z (integer expected, got "%s")", mat_z))
        end

        local tile = (((cfg or {}).tile_tbl or {})[mat_x] or {})[mat_z]
        if tile ~= nil and tile["name"] ~= "" then
            return nil, false
        end

        return env.matrix.translation(mat_x, 0, mat_z), true
    end

    function env.matrix.translation(x, y, z)
        if type(x) ~= "number" then
            error("bad argument to x (number expected, got %s)", type(x))
        end
        if type(y) ~= "number" then
            error("bad argument to y (number expected, got %s)", type(y))
        end
        if type(z) ~= "number" then
            error("bad argument to z (number expected, got %s)", type(z))
        end

        return {
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            x, y, z, 1,
        }
    end

    function env.matrix.position(mat)
        if (
            mat[1] ~= 1 or mat[2] ~= 0 or mat[3] ~= 0 or mat[4] ~= 0 or
            mat[5] ~= 0 or mat[6] ~= 1 or mat[7] ~= 0 or mat[8] ~= 0 or
            mat[9] ~= 0 or mat[10] ~= 0 or mat[11] ~= 1 or mat[12] ~= 0 or
            type(mat[13]) ~= "number" or type(mat[14]) ~= "number" or type(mat[15]) ~= "number" or mat[16] ~= 1
        ) then
            error("unsupported argument")
        end
        return mat[13], mat[14], mat[15]
    end

    return env
end

function deepEqual(expected, actual)
    if type(expected) ~= "table" or type(actual) ~= "table" then
        return expected == actual
    end

    for key, _ in pairs(expected) do
        if not deepEqual(expected[key], actual[key]) then
            return false
        end
    end
    for key, _ in pairs(actual) do
        if expected[key] == nil then
            return false
        end
    end
    return true
end

function deepCopy(v)
    if type(v) ~= "table" then
        return v
    end

    local tbl = {}
    for key, val in pairs(v) do
        tbl[deepCopy(key)] = deepCopy(val)
    end
    return tbl
end

test()
