-- SPDX-License-Identifier: Unlicense

function test()
    local test_tbl = {
        {name = 'testGetOceanReachable', fn = testGetOceanReachable},
        {name = 'testInitEdge', fn = testInitEdge},
        {name = 'testInitArea', fn = testInitArea},
        {name = 'testSetNode', fn = testSetNode},
        {name = 'testCalcPath', fn = testCalcPath},
        {name = 'testGetPathList', fn = testGetPathList},
        {name = 'testReset', fn = testReset},
        {name = 'testGetTileNode', fn = testGetTileNode},
        {name = 'testTestRectAndLineCollision', fn = testTestRectAndLineCollision},
        {name = 'testTestLineAndLineCollision', fn = testTestLineAndLineCollision},
        {name = 'testHeap', fn = testHeap},
        {name = 'testHeapPush', fn = testHeapPush},
        {name = 'testHeapPop', fn = testHeapPop},
        {name = 'testHeapCompare', fn = testHeapCompare},
    }

    local pf = buildPathfinder()
    for _, test in ipairs(test_tbl) do
        local cpf = deepCopy(pf)
        local is_success, err = pcall(test.fn, cpf)
        if not is_success then
            io.write(string.format('FAIL %s\n', test.name))
            io.write(string.format('     %s\n', err))
        else
            io.write(string.format('PASS %s\n', test.name))
        end
    end
end

function testGetOceanReachable(pf)
    local case_tbl = {
        {
            input_world_x1 = -1000,
            input_world_z1 = -1000,
            input_world_x2 = 1000,
            input_world_z2 = 1000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 1000),
                },
            },
            input_matrix_start = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
            },
            input_matrix_end = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_ret = true,
        },
        {
            input_world_x1 = -2000,
            input_world_z1 = -2000,
            input_world_x2 = 2000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_matrix_start = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
            },
            input_matrix_end = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 1000, 1,
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_ret = true,
        },
        {
            input_world_x1 = -2000,
            input_world_z1 = -2000,
            input_world_x2 = 2000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_matrix_start = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
            },
            input_matrix_end = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 1000, 1,
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_ret = false,
        },
        {
            input_world_x1 = -2000,
            input_world_z1 = -2000,
            input_world_x2 = 2000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_matrix_start = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
            },
            input_matrix_end = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 1000, 1,
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_ret = false,
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -1000,
            input_world_x2 = 1000,
            input_world_z2 = 1000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_matrix_start = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
            },
            input_matrix_end = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 2000, 1,
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_ret = true,
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -1000,
            input_world_x2 = 1000,
            input_world_z2 = 1000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_matrix_start = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 2000, 1,
            },
            input_matrix_end = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_ret = true,
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._world_x1 = case.input_world_x1
        pf._world_z1 = case.input_world_z1
        pf._world_x2 = case.input_world_x2
        pf._world_z2 = case.input_world_z2
        pf._node_tbl = deepCopy(case.input_node_tbl)
        local actual_ret = pf:getOceanReachable(case.input_matrix_start, case.input_matrix_end)
        if not deepEqual(case.expected_node_tbl, pf._node_tbl) then
            error(string.format('case #%d: wrong node_tbl', case_idx))
        end
        if actual_ret ~= case.expected_ret then
            error(string.format('case #%d: wrong return value (expected %s, got %s)', case_idx, case.expected_ret, actual_ret))
        end
    end
end

function testInitEdge(pf)
    local case_tbl = {
        input_node_tbl = {
            [pf:_getNodeKey(0, 0)] = {
                x = 0,
                z = 0,
                is_ocean = true,
                edge_tbl = {
                    [pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 0},
                },
                area_key = pf:_getNodeKey(0, 0),
                visited = true,
                cost = {ocean_dist = 0, risky_dist = 0},
                prev_key = pf:_getNodeKey(0, 1),
            },
        },
        expected_node_tbl = {
            [pf:_getNodeKey(0, 0)] = {
                x = 0,
                z = 0,
                is_ocean = true,
                edge_tbl = {},
                area_key = nil,
                visited = false,
                cost = nil,
                prev_key = nil,
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = math.sqrt(2000000), risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = math.sqrt(2000000), risky_dist = 0},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = math.sqrt(2000000), risky_dist = 0},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = math.sqrt(2000000), risky_dist = 0},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(1000, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(1000, 1000)] = {
                    x = 1000,
                    z = 1000,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = math.sqrt(2000000)},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(1000, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._node_tbl = deepCopy(case.input_node_tbl)
        pf:_initEdge()
        if not deepEqual(case.expected_node_tbl, pf._node_tbl) then
            error(string.format('case #%d: wrong node_tbl', case_idx))
        end
    end
end

function testInitArea(pf)
    local case_tbl = {
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 1),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 1),
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -1000,
            input_world_x2 = 1000,
            input_world_z2 = 1000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -2000,
            input_world_x2 = 1000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = -1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = -1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -2000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -2000,
            input_world_x2 = 1000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -2000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -2000,
            input_world_x2 = 1000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 1000,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -2000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -2000,
            input_world_x2 = 1000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_area_tbl = {},
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -2000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_world_x1 = -2000,
            input_world_z1 = -2000,
            input_world_x2 = 2000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_area_tbl = {
                [pf:_getNodeKey(0, 0)] = {pf:_getNodeKey(0, 0), pf:_getNodeKey(0, 1000)},
            },
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = pf:_getNodeKey(0, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._world_x1 = case.input_world_x1
        pf._world_z1 = case.input_world_z1
        pf._world_x2 = case.input_world_x2
        pf._world_z2 = case.input_world_z2
        pf._node_tbl = deepCopy(case.input_node_tbl)
        pf:_initArea()

        local expected_node_tbl = deepCopy(case.expected_node_tbl)
        for area_key, node_key_list in pairs(case.expected_area_tbl) do
            for _, node_key in pairs(node_key_list) do
                expected_node_tbl[node_key].area_key = pf._node_tbl[area_key].area_key
            end
        end

        if not deepEqual(expected_node_tbl, pf._node_tbl) then
            error(string.format('case #%d: wrong node_tbl', case_idx))
        end
    end
end

function testSetNode(pf)
    local case_tbl = {
        {
            input_world_x1 = -1000,
            input_world_z1 = -1000,
            input_world_x2 = 1000,
            input_world_z2 = 1000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_x = 0,
            input_z = 0,
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_temp_node_tbl = {},
            expected_node_key = pf:_getNodeKey(0, 0),
        },
        {
            input_world_x1 = -2000,
            input_world_z1 = -2000,
            input_world_x2 = 2000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_x = 0,
            input_z = 1,
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 1000, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 999, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 999, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_temp_node_tbl = {
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 999, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_key = pf:_getNodeKey(0, 1),
        },
        {
            input_world_x1 = -2000,
            input_world_z1 = -2000,
            input_world_x2 = 2000,
            input_world_z2 = 2000,
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = pf:_getNodeKey(0, 1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_x = 0,
            input_z = 1,
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1000)] = {
                    x = 0,
                    z = 1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1000},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 999},
                    },
                    area_key = pf:_getNodeKey(0, 1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 999},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_temp_node_tbl = {
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 1000)] = {ocean_dist = 0, risky_dist = 999},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_key = pf:_getNodeKey(0, 1),
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -1000,
            input_world_x2 = 1000,
            input_world_z2 = 1000,
            input_node_tbl = {
                [pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_x = 0,
            input_z = -2000,
            expected_node_tbl = {
                [pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -2000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, -2000)] = {
                    x = 0,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_temp_node_tbl = {
                [pf:_getNodeKey(0, -2000)] = {
                    x = 0,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1000)] = {ocean_dist = 1000, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_key = pf:_getNodeKey(0, -2000),
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -1000,
            input_world_x2 = 1000,
            input_world_z2 = 1000,
            input_node_tbl = {
                [pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_x = 0,
            input_z = -2000,
            expected_node_tbl = {
                [pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -2000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, -2000)] = {
                    x = 0,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_temp_node_tbl = {
                [pf:_getNodeKey(0, -2000)] = {
                    x = 0,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1000)] = {ocean_dist = 0, risky_dist = 1000},
                    },
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_key = pf:_getNodeKey(0, -2000),
        },
        {
            input_world_x1 = -1000,
            input_world_z1 = -1000,
            input_world_x2 = 1000,
            input_world_z2 = 1000,
            input_node_tbl = {
                [pf:_getNodeKey(0, -2000)] = {
                    x = 0,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = false,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_x = 0,
            input_z = -1001,
            expected_node_tbl = {
                [pf:_getNodeKey(0, -2000)] = {
                    x = 0,
                    z = -2000,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1001)] = {ocean_dist = 0, risky_dist = 999},
                    },
                    area_key = pf:_getNodeKey(-1000, -1000),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, -1000)] = {
                    x = 0,
                    z = -1000,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1001)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, -1001)] = {
                    x = 0,
                    z = -1001,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -2000)] = {ocean_dist = 0, risky_dist = 999},
                        [pf:_getNodeKey(0, -1000)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_temp_node_tbl = {
                [pf:_getNodeKey(0, -1001)] = {
                    x = 0,
                    z = -1001,
                    is_ocean = false,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -2000)] = {ocean_dist = 0, risky_dist = 999},
                        [pf:_getNodeKey(0, -1000)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            expected_node_key = pf:_getNodeKey(0, -1001),
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._world_x1 = case.input_world_x1
        pf._world_z1 = case.input_world_z1
        pf._world_x2 = case.input_world_x2
        pf._world_z2 = case.input_world_z2
        pf._node_tbl = deepCopy(case.input_node_tbl)
        pf._temp_node_tbl = {}
        local actual_node_key = pf:_setNode(case.input_x, case.input_z)
        if not deepEqual(case.expected_node_tbl, pf._node_tbl) then
            error(string.format('case #%d: wrong node_tbl', case_idx))
        end
        if not deepEqual(case.expected_temp_node_tbl, pf._temp_node_tbl) then
            error(string.format('case #%d: wrong temp_node_tbl', case_idx))
        end
        if actual_node_key ~= case.expected_node_key then
            error(string.format('case #%d: wrong node_key', case_idx))
        end
    end
end

function testCalcPath(pf)
    local case_tbl = {
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 1000),
                },
            },
            input_start_node_key = nil,
            input_end_node_key = nil,
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_start_node_key = pf:_getNodeKey(0, 0),
            input_end_node_key = nil,
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_start_node_key = pf:_getNodeKey(0, 0),
            input_end_node_key = pf:_getNodeKey(0, 0),
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 3)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_start_node_key = pf:_getNodeKey(0, 0),
            input_end_node_key = pf:_getNodeKey(0, 3),
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 3)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
                [pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 3, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 2),
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 3, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 3, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 3)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_start_node_key = pf:_getNodeKey(0, 0),
            input_end_node_key = pf:_getNodeKey(0, 3),
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 3, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 3, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 3)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 1),
                },
                [pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 4, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 2),
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 3, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 3, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 3)] = {ocean_dist = 0, risky_dist = 3},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 3},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_start_node_key = pf:_getNodeKey(0, 0),
            input_end_node_key = pf:_getNodeKey(0, 3),
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 3, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 1},
                    prev_key = pf:_getNodeKey(0, 0),
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 3, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 3)] = {ocean_dist = 0, risky_dist = 3},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 3, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
                [pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 3},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 3, risky_dist = 3},
                    prev_key = pf:_getNodeKey(0, 2),
                },
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 3)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_start_node_key = pf:_getNodeKey(0, 0),
            input_end_node_key = pf:_getNodeKey(0, 3),
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 0, risky_dist = 1},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 3)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 1),
                },
                [pf:_getNodeKey(0, 3)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 0, risky_dist = 1},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 1},
                    prev_key = pf:_getNodeKey(0, 2),
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._node_tbl = deepCopy(case.input_node_tbl)
        pf._start_node_key = case.input_start_node_key
        pf._end_node_key = case.input_end_node_key
        pf:_calcPath()
        if not deepEqual(case.expected_node_tbl, pf._node_tbl) then
            error(string.format('case #%d: wrong node_tbl', case_idx))
        end
    end
end

function testGetPathList(pf)
    local case_tbl = {
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 2,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 1),
                },
            },
            input_start_node_key = pf:_getNodeKey(0, 0),
            input_end_node_key = pf:_getNodeKey(0, 2),
            expected = {
                {x = 0, z = 1},
                {x = 0, z = 2},
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
                [pf:_getNodeKey(0, 2)] = {
                    x = 0,
                    z = 2,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 2)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 2, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 1),
                },
            },
            input_start_node_key = nil,
            input_end_node_key = pf:_getNodeKey(0, 2),
            expected = {
                {x = 0, z = 0},
                {x = 0, z = 1},
                {x = 0, z = 2},
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._node_tbl = deepCopy(case.input_node_tbl)
        pf._start_node_key = case.input_start_node_key
        pf._end_node_key = case.input_end_node_key
        local actual = pf:_getPathList()
        if not deepEqual(case.expected, actual) then
            error(string.format('case #%d: wrong path_list', case_idx))
        end
    end
end

function testReset(pf)
    local case_tbl = {
        {
            input_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 0, risky_dist = 0},
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, -1)] = {
                    x = 0,
                    z = -1,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, 1)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, -1)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
            },
            input_temp_node_tbl = {
                [pf:_getNodeKey(0, 1)] = {
                    x = 0,
                    z = 1,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                        [pf:_getNodeKey(0, -1)] = {ocean_dist = 2, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = true,
                    cost = {ocean_dist = 1, risky_dist = 0},
                    prev_key = pf:_getNodeKey(0, 0),
                },
            },
            input_start_node_key = pf:_getNodeKey(0, 0),
            input_end_node_key = pf:_getNodeKey(0, 1),
            expected_node_tbl = {
                [pf:_getNodeKey(0, 0)] = {
                    x = 0,
                    z = 0,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, -1)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
                [pf:_getNodeKey(0, -1)] = {
                    x = 0,
                    z = -1,
                    is_ocean = true,
                    edge_tbl = {
                        [pf:_getNodeKey(0, 0)] = {ocean_dist = 1, risky_dist = 0},
                    },
                    area_key = pf:_getNodeKey(0, 0),
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._node_tbl = deepCopy(case.input_node_tbl)
        pf._temp_node_tbl = deepCopy(case.input_temp_node_tbl)
        pf._start_node_key = case.input_start_node_key
        pf._end_node_key = case.input_end_node_key
        pf:_reset()
        if not deepEqual(case.expected_node_tbl, pf._node_tbl) then
            error(string.format('case #%d: wrong node_tbl', case_idx))
        end
        if not deepEqual({}, pf._temp_node_tbl) then
            error(string.format('case #%d: wrong temp_node_tbl', case_idx))
        end
        if pf._start_node_key ~= nil then
            error(string.format('case #%d: wrong start_node_key (expected nil, got %s)', case_idx, pf._start_node_key))
        end
        if pf._end_node_key ~= nil then
            error(string.format('case #%d: wrong end_node_key (expected nil, got %s)', case_idx, pf._end_node_key))
        end
    end
end

function testGetTileNode(pf)
    local case_tbl = {
        {
            input_node_tbl = {
                [pf:_getNodeKey(1000, 2000)] = {
                    x = 1000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
                },
            },
            input_x = 0,
            input_z = 0,
            expected = nil,
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(1000, 2000)] = {
                    x = 1000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
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
                visited = false,
                cost = nil,
                prev_key = nil,
            },
        },
        {
            input_node_tbl = {
                [pf:_getNodeKey(1000, 2000)] = {
                    x = 1000,
                    z = 2000,
                    is_ocean = true,
                    edge_tbl = {},
                    area_key = nil,
                    visited = false,
                    cost = nil,
                    prev_key = nil,
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
                visited = false,
                cost = nil,
                prev_key = nil,
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._node_tbl = deepCopy(case.input_node_tbl)
        local actual = pf:_getTileNode(case.input_x, case.input_z)
        if not deepEqual(case.expected, actual) then
            error(string.format('case #%d: wrong node', case_idx))
        end
    end
end

function testTestRectAndLineCollision(pf)
    local case_tbl = {
        {input_list = {-1, -1, 1, 1, 0, 0, 0, 0}, expected = true},
        {input_list = {-1, -1, 1, 1, -3, 0, 0, 3}, expected = false},
        {input_list = {-1, -1, 1, 1, -2, 0, 0, 0}, expected = true},
        {input_list = {-1, -1, 1, 1, 0, 0, 2, 0}, expected = true},
        {input_list = {-1, -1, 1, 1, 0, -2, 0, 0}, expected = true},
        {input_list = {-1, -1, 1, 1, 0, 0, 0, 2}, expected = true},
    }

    for case_idx, case in ipairs(case_tbl) do
        local actual = pf:_testRectAndLineCollision(table.unpack(case.input_list))
        if case.expected ~= actual then
            error(string.format('case #%d: expected %s, got %s', case_idx, case.expected, actual))
        end
    end
end

function testTestLineAndLineCollision(pf)
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
        local actual = pf:_testLineAndLineCollision(table.unpack(case.input_list))
        if case.expected ~= actual then
            error(string.format('case #%d: expected %s, got %s', case_idx, case.expected, actual))
        end
    end
end

function testHeap(pf)
    local input_list = {43, 10, 41, 24, 23, 12, 53, 31, 96, 33, 22, 49, 27, 74, 72, 19, 16, 56, 52, 59, 93, 15, 17, 64, 32, 75, 14, 20, 98, 3, 90, 63, 94, 81, 0, 8, 80, 87, 76, 5, 39, 7, 83, 89, 51, 42, 60, 69, 4, 67, 11, 26, 71, 40, 61, 30, 38, 18, 77, 92, 97, 25, 36, 48, 47, 34, 73, 1, 9, 21, 82, 84, 28, 2, 68, 95, 50, 65, 91, 70, 29, 99, 55, 58, 88, 86, 37, 85, 35, 66, 62, 45, 46, 54, 79, 6, 57, 78, 13, 44}
    local expected_list = deepCopy(input_list)
    table.sort(expected_list)

    local actual_list = {}
    local heap = {}
    for _, input in ipairs(input_list) do
        pf:_heapPush(heap, input)
    end
    while true do
        local actual = pf:_heapPop(heap)
        if actual == nil then
            break
        end
        table.insert(actual_list, actual)
    end

    if not deepEqual(expected_list, actual_list) then
        error('failed')
    end
end

function testHeapPush(pf)
    local case_tbl = {
        {
            input_heap = {},
            input_value = {1, 2},
            expected_heap = {
                [1] = {1, 2},
            },
        },
        {
            input_heap = {
                [1] = {1},
                [2] = {3},
                [3] = {5},
                [4] = {7},
                [5] = {9},
            },
            input_value = {6},
            expected_heap = {
                [1] = {1},
                [2] = {3},
                [3] = {5},
                [4] = {7},
                [5] = {9},
                [6] = {6},
            },
        },
        {
            input_heap = {
                [1] = {1},
                [2] = {3},
                [3] = {5},
                [4] = {7},
                [5] = {9},
            },
            input_value = {4},
            expected_heap = {
                [1] = {1},
                [2] = {3},
                [3] = {4},
                [4] = {7},
                [5] = {9},
                [6] = {5},
            },
        },
        {
            input_heap = {
                [1] = {1},
                [2] = {3},
                [3] = {5},
                [4] = {7},
                [5] = {9},
            },
            input_value = {0},
            expected_heap = {
                [1] = {0},
                [2] = {3},
                [3] = {1},
                [4] = {7},
                [5] = {9},
                [6] = {5},
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        local heap = deepCopy(case.input_heap)
        pf:_heapPush(heap, table.unpack(case.input_value))
        if not deepEqual(case.expected_heap, heap) then
            error(string.format('case #%d: wrong heap', case_idx))
        end
    end
end

function testHeapPop(pf)
    local case_tbl = {
        {
            input_heap = {},
            expected_heap = {},
            expected_ret = {},
        },
        {
            input_heap = {
                [1] = {1, 2},
            },
            expected_heap = {},
            expected_ret = {1, 2},
        },
        {
            input_heap = {
                [1] = {1},
                [2] = {3},
                [3] = {5},
                [4] = {7},
                [5] = {9},
            },
            expected_heap = {
                [1] = {3},
                [2] = {7},
                [3] = {5},
                [4] = {9},
            },
            expected_ret = {1},
        },
        {
            input_heap = {
                [1] = {1},
                [2] = {5},
                [3] = {3},
                [4] = {7},
                [5] = {9},
            },
            expected_heap = {
                [1] = {3},
                [2] = {5},
                [3] = {9},
                [4] = {7},
            },
            expected_ret = {1},
        },
        {
            input_heap = {
                [1] = {1},
                [2] = {3},
                [3] = {5},
                [4] = {7},
                [5] = {4},
            },
            expected_heap = {
                [1] = {3},
                [2] = {4},
                [3] = {5},
                [4] = {7},
            },
            expected_ret = {1},
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        local heap = deepCopy(case.input_heap)
        local ret = {pf:_heapPop(heap)}
        if not deepEqual(case.expected_heap, heap) then
            error(string.format('case #%d: wrong heap', case_idx))
        end
        if not deepEqual(case.expected_ret, ret) then
            error(string.format('case #%d: wrong ret', case_idx))
        end
    end
end


function testHeapCompare(pf)
    local case_tbl = {
        {input_list1 = {}, input_list2 = {}, expected = 0},
        {input_list1 = {}, input_list2 = {0}, expected = -1},
        {input_list1 = {0}, input_list2 = {}, expected = 1},
        {input_list1 = {0}, input_list2 = {1}, expected = -1},
        {input_list1 = {1}, input_list2 = {0}, expected = 1},
        {input_list1 = {0}, input_list2 = {0}, expected = 0},
        {input_list1 = {0}, input_list2 = {0, 0}, expected = -1},
        {input_list1 = {0, 0}, input_list2 = {0}, expected = 1},
        {input_list1 = {0, 0}, input_list2 = {0, 1}, expected = -1},
        {input_list1 = {0, 1}, input_list2 = {0, 0}, expected = 1},
        {input_list1 = {-12}, input_list2 = {-1}, expected = -1},
        {input_list1 = {-1}, input_list2 = {-12}, expected = 1},
        {input_list1 = {0}, input_list2 = {'0'}, expected = -1},
        {input_list1 = {'0'}, input_list2 = {0}, expected = 1},
        {input_list1 = {false}, input_list2 = {false}, expected = 0},
        {input_list1 = {false}, input_list2 = {true}, expected = -1},
        {input_list1 = {true}, input_list2 = {false}, expected = 1},
    }

    for case_idx, case in ipairs(case_tbl) do
        local actual = pf:_heapCompare(case.input_list1, case.input_list2)
        if case.expected ~= actual then
            error(string.format('case #%d: expected %s, got %s', case_idx, case.expected, actual))
        end
    end
end

function buildPathfinder()
    local env = buildEnv()
    loadfile('script.lua', 't', env)()
    return env.buildPathfinder()
end

function buildEnv()
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
            error(string.format('unsupported argument to min_search_range (0 expected, got "%s")', min_search_range))
        end
        if max_search_range ~= 1 then
            error(string.format('unsupported argument to max_search_range (1 expected, got "%s")', max_search_range))
        end

        local mat_x, _, mat_z = env.matrix.position(mat)
        if mat_x%1 ~= 0 then
            error(string.format('unsupported argument to mat_x (integer expected, got "%s")', mat_x))
        end
        if mat_z%1 ~= 0 then
            error(string.format('unsupported argument to mat_z (integer expected, got "%s")', mat_z))
        end

        return env.matrix.translation(mat_x, 0, mat_z), true
    end

    function env.matrix.translation(x, y, z)
        if type(x) ~= 'number' then
            error('bad argument to x (number expected, got %s)', type(x))
        end
        if type(y) ~= 'number' then
            error('bad argument to y (number expected, got %s)', type(y))
        end
        if type(z) ~= 'number' then
            error('bad argument to z (number expected, got %s)', type(z))
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
            type(mat[13]) ~= 'number' or type(mat[14]) ~= 'number' or type(mat[15]) ~= 'number' or mat[16] ~= 1
        ) then
            error('unsupported argument')
        end
        return mat[13], mat[14], mat[15]
    end

    return env
end

function deepEqual(expected, actual)
    if type(expected) ~= 'table' or type(actual) ~= 'table' then
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
    if type(v) ~= 'table' then
        return v
    end

    local tbl = {}
    for key, val in pairs(v) do
        tbl[deepCopy(key)] = deepCopy(val)
    end
    return tbl
end

test()
