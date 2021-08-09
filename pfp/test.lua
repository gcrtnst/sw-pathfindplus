-- SPDX-License-Identifier: Unlicense

function test()
    local test_tbl = {
        {name = 'testPathfindOcean', fn = testPathfindOcean},
        {name = 'testInitNodeList', fn = testInitNodeList},
        {name = 'testReset', fn = testReset},
        {name = 'testAddTempNode', fn = testAddTempNode},
        {name = 'testTestRectAndLineCollision', fn = testTestRectAndLineCollision},
        {name = 'testTestLineAndLineCollision', fn = testTestLineAndLineCollision},
        {name = 'testCalcPath', fn = testCalcPath},
        {name = 'testHeap', fn = testHeap},
        {name = 'testHeapPush', fn = testHeapPush},
        {name = 'testHeapPop', fn = testHeapPop},
        {name = 'testGetPathList', fn = testGetPathList},
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

function testPathfindOcean(pf)
    local case_tbl = {
        {
            input_matrix_start = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                -500, 0, -1000, 1,
            },
            input_matrix_end = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                -500, 0, 1000, 1,
            },
            expected_path_list = {
                {x = -500, z = -500},
                {x = -500, z = 500},
                {x = -500, z = 1000},
            },
        },
        {
            input_matrix_start = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                -500, 0, -1250, 1,
            },
            input_matrix_end = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                -500, 0, 1250, 1,
            },
            expected_path_list = {
                {x = -500, z = -500},
                {x = -500, z = 500},
                {x = -500, z = 1250},
            },
        },
    }

    for case_idx, case in pairs(case_tbl) do
        local path_list = pf:pathfindOcean(case.input_matrix_start, case.input_matrix_end)
        if not deepEqual(case.expected_path_list, path_list) then
            error(string.format('case #%d: wrong path_list', case_idx))
        end
        if #pf._node_list ~= pf._num_perm_node + 2 then
            error(string.format('case #%d: wrong num_of_node (expected %s, got %s)', pf._num_perm_node, #pf._node_list))
        end
    end
end

function testInitNodeList(pf)
    local case_tbl = {
        {
            input_tile_list = {},
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {[2] = 1000, [3] = 1000, [4] = math.sqrt(2000000)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {[1] = 1000, [3] = math.sqrt(2000000), [4] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 500,
                    z = -500,
                    edge_tbl = {[1] = 1000, [2] = math.sqrt(2000000), [4] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [4] = {
                    x = 500,
                    z = 500,
                    edge_tbl = {[1] = math.sqrt(2000000), [2] = 1000, [3] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_num_perm_node = 4,
        },
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[1] = true}},
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {[3] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = 500,
                    z = -500,
                    edge_tbl = {[3] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 500,
                    z = 500,
                    edge_tbl = {[1] = 1000, [2] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_num_perm_node = 3,
        },
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[3] = true}},
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {[2] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {[1] = 1000, [3] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 500,
                    z = 500,
                    edge_tbl = {[2] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_num_perm_node = 3,
        },
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[7] = true}},
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {[2] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = 500,
                    z = -500,
                    edge_tbl = {[1] = 1000, [3] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 500,
                    z = 500,
                    edge_tbl = {[2] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_num_perm_node = 3,
        },
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[9] = true}},
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {[2] = 1000, [3] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {[1] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 500,
                    z = -500,
                    edge_tbl = {[1] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_num_perm_node = 3,
        },
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[4] = true, [6] = true}},
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {[3] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {[4] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 500,
                    z = -500,
                    edge_tbl = {[1] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [4] = {
                    x = 500,
                    z = 500,
                    edge_tbl = {[2] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_num_perm_node = 4,
        },
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[2] = true, [8] = true}},
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {[2] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {[1] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 500,
                    z = -500,
                    edge_tbl = {[4] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [4] = {
                    x = 500,
                    z = 500,
                    edge_tbl = {[3] = 1000},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_num_perm_node = 4,
        },
    }

    for case_idx, case in pairs(case_tbl) do
        pf._tile_list = case.input_tile_list
        pf._world_x1 = case.input_world_x1
        pf._world_z1 = case.input_world_z1
        pf._world_x2 = case.input_world_x2
        pf._world_z2 = case.input_world_z2
        pf:_initNodeList()
        if not deepEqual(case.expected_node_list, pf._node_list) then
            error(string.format('case #%d: wrong node_list', case_idx))
        end
        if case.expected_num_perm_node ~= pf._num_perm_node then
            error(string.format('case #%d: wrong num_perm_node (expected %s, got %s)', case_idx, case.expected_num_perm_node, pf._num_perm_node))
        end
    end
end

function testReset(pf)
    local case_tbl = {
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 0, [3] = 0},
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 0, [3] = 0},
                    cost = 0,
                    prev = 1,
                    visited = true,
                },
                [3] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 0, [2] = 0},
                    cost = 0,
                    prev = 1,
                    visited = true,
                },
            },
            input_num_perm_node = 2,
            input_start_node_idx = 1,
            input_end_node_idx = 3,
            expected_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 0},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 0},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._node_list = deepCopy(case.input_node_list)
        pf._num_perm_node = case.input_num_perm_node
        pf._start_node_idx = case.input_start_node_idx
        pf._end_node_idx = case.input_end_node_idx
        pf:_reset()
        if not deepEqual(case.expected_node_list, pf._node_list) then
            error(string.format('case #%d: wrong node_list', case_idx))
        end
        if pf._start_node_idx ~= nil then
            error(string.format('case #%d: wrong start_node_idx (expected nil, got %s)', case_idx, pf._start_node_idx))
        end
        if pf._end_node_idx ~= nil then
            error(string.format('case #%d: wrong end_node_idx (expected nil, got %s)', case_idx, pf._end_node_idx))
        end
    end
end

function testAddTempNode(pf)
    local case_tbl = {
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[1] = true, [2] = true, [3] = true, [4] = true, [6] = true, [7] = true, [8] = true, [9] = true}},
            },
            input_node_list = {},
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_args = {0, 0},
            expected_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_node_idx = 1,
        },
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[2] = true, [3] = true, [4] = true, [6] = true, [8] = true, [9] = true}},
            },
            input_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_args = {0, -250},
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {[3] = math.sqrt(312500)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 0,
                    z = -250,
                    edge_tbl = {[1] = math.sqrt(312500)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_node_idx = 3,
        },
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[2] = true, [3] = true, [4] = true, [6] = true, [8] = true, [9] = true}},
            },
            input_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_args = {0, 250},
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {[3] = math.sqrt(312500)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 0,
                    z = 250,
                    edge_tbl = {[2] = math.sqrt(312500)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_node_idx = 3,
        },
        {
            input_tile_list = {},
            input_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = -500,
                    z = 1000,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_args = {0, -250},
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {[4] = math.sqrt(312500)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {[4] = math.sqrt(812500)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = -500,
                    z = 1000,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [4] = {
                    x = 0,
                    z = -250,
                    edge_tbl = {[1] = math.sqrt(312500), [2] = math.sqrt(812500)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_node_idx = 4,
        },
        {
            input_tile_list = {
                {x = 0, z = 0, joint = {[2] = true, [3] = true, [4] = true, [6] = true, [8] = true}},
            },
            input_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 500,
                    z = 500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_world_x1 = 0,
            input_world_z1 = 0,
            input_world_x2 = 0,
            input_world_z2 = 0,
            input_args = {-2000, -500},
            expected_node_list = {
                [1] = {
                    x = -500,
                    z = -500,
                    edge_tbl = {[4] = 1500},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = -500,
                    z = 500,
                    edge_tbl = {[4] = math.sqrt(3250000)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 500,
                    z = 500,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [4] = {
                    x = -2000,
                    z = -500,
                    edge_tbl = {[1] = 1500, [2] = math.sqrt(3250000)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            expected_node_idx = 4,
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._tile_list = case.input_tile_list
        pf._node_list = deepCopy(case.input_node_list)
        pf._world_x1 = case.input_world_x1
        pf._world_z1 = case.input_world_z1
        pf._world_x2 = case.input_world_x2
        pf._world_z2 = case.input_world_z2

        local node_idx = pf:_addTempNode(table.unpack(case.input_args))
        if case.expected_node_idx ~= node_idx then
            error(string.format('case #%d: wrong node_idx (expected %s, got %s)', case_idx, case.expected_node_idx, node_idx))
        end
        if not deepEqual(case.expected_node_list, pf._node_list) then
            error(string.format('case #%d: wrong node_list', case_idx))
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
            error(string.format('case #%d: expected %s, got %s', case.expected, actual))
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

function testCalcPath(pf)
    local case_tbl = {
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 0},
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 0},
                    cost = 0,
                    prev = 1,
                    visited = true,
                },
            },
            input_start_node_idx = nil,
            input_end_node_idx = nil,
            expected_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 0},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 0},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
        },
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_start_node_idx = 1,
            input_end_node_idx = nil,
            expected_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {},
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
        },
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 0},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 0},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_start_node_idx = 1,
            input_end_node_idx = 1,
            expected_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 0},
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 0},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
        },
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 1, [3] = math.sqrt(2)},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = 1,
                    z = 0,
                    edge_tbl = {[1] = 1, [3] = 1},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 1,
                    z = 1,
                    edge_tbl = {[1] = math.sqrt(2), [2] = 1},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_start_node_idx = 1,
            input_end_node_idx = 3,
            expected_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 1, [3] = math.sqrt(2)},
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
                [2] = {
                    x = 1,
                    z = 0,
                    edge_tbl = {[1] = 1, [3] = 1},
                    cost = 1,
                    prev = 1,
                    visited = true,
                },
                [3] = {
                    x = 1,
                    z = 1,
                    edge_tbl = {[1] = math.sqrt(2), [2] = 1},
                    cost = math.sqrt(2),
                    prev = 1,
                    visited = true,
                },
            },
        },
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 0, [3] = 1},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 0, [3] = 0},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [3] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 1, [2] = 0, [4] = 10},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
                [4] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[3] = 10},
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_start_node_idx = 1,
            input_end_node_idx = 4,
            expected_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[2] = 0, [3] = 1},
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
                [2] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 0, [3] = 0},
                    cost = 0,
                    prev = 1,
                    visited = true,
                },
                [3] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[1] = 1, [2] = 0, [4] = 10},
                    cost = 0,
                    prev = 2,
                    visited = true,
                },
                [4] = {
                    x = 0,
                    z = 0,
                    edge_tbl = {[3] = 10},
                    cost = 10,
                    prev = 3,
                    visited = true,
                },
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._node_list = deepCopy(case.input_node_list)
        pf._start_node_idx = case.input_start_node_idx
        pf._end_node_idx = case.input_end_node_idx
        pf:_calcPath()
        if not deepEqual(case.expected_node_list, pf._node_list) then
            error(string.format('case #%d: wrong node_list', case_idx))
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
        pf:_heapPush(heap, input, -input)
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
            input_val = 'TEST',
            input_priority = 0,
            expected_heap = {
                {val = 'TEST', priority = 0},
            },
        },
        {
            input_heap = {
                {val = 'TEST7', priority = 7},
                {val = 'TEST5', priority = 5},
                {val = 'TEST3', priority = 3},
                {val = 'TEST1', priority = 1},
            },
            input_val = 'TEST0',
            input_priority = 0,
            expected_heap = {
                {val = 'TEST7', priority = 7},
                {val = 'TEST5', priority = 5},
                {val = 'TEST3', priority = 3},
                {val = 'TEST1', priority = 1},
                {val = 'TEST0', priority = 0},
            },
        },
        {
            input_heap = {
                {val = 'TEST7', priority = 7},
                {val = 'TEST5', priority = 5},
                {val = 'TEST3', priority = 3},
                {val = 'TEST1', priority = 1},
            },
            input_val = 'TEST6',
            input_priority = 6,
            expected_heap = {
                {val = 'TEST7', priority = 7},
                {val = 'TEST6', priority = 6},
                {val = 'TEST3', priority = 3},
                {val = 'TEST1', priority = 1},
                {val = 'TEST5', priority = 5},
            },
        },
        {
            input_heap = {
                {val = 'TEST7', priority = 7},
                {val = 'TEST5', priority = 5},
                {val = 'TEST3', priority = 3},
                {val = 'TEST1', priority = 1},
            },
            input_val = 'TEST9',
            input_priority = 9,
            expected_heap = {
                {val = 'TEST9', priority = 9},
                {val = 'TEST7', priority = 7},
                {val = 'TEST3', priority = 3},
                {val = 'TEST1', priority = 1},
                {val = 'TEST5', priority = 5},
            },
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        local heap = deepCopy(case.input_heap)
        pf:_heapPush(heap, case.input_val, case.input_priority)
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
            expected_val = nil,
        },
        {
            input_heap = {
                {val = 'TEST', priority = 0},
            },
            expected_heap = {},
            expected_val = 'TEST',
        },
        {
            input_heap = {
                {val = 'TEST9', priority = 9},
                {val = 'TEST7', priority = 7},
                {val = 'TEST5', priority = 5},
                {val = 'TEST3', priority = 3},
                {val = 'TEST1', priority = 1},
            },
            expected_heap = {
                {val = 'TEST7', priority = 7},
                {val = 'TEST3', priority = 3},
                {val = 'TEST5', priority = 5},
                {val = 'TEST1', priority = 1},
            },
            expected_val = 'TEST9',
        },
        {
            input_heap = {
                {val = 'TEST9', priority = 9},
                {val = 'TEST5', priority = 5},
                {val = 'TEST7', priority = 7},
                {val = 'TEST3', priority = 3},
                {val = 'TEST1', priority = 1},
            },
            expected_heap = {
                {val = 'TEST7', priority = 7},
                {val = 'TEST5', priority = 5},
                {val = 'TEST1', priority = 1},
                {val = 'TEST3', priority = 3},
            },
            expected_val = 'TEST9',
        },
        {
            input_heap = {
                {val = 'TEST9', priority = 9},
                {val = 'TEST7', priority = 7},
                {val = 'TEST5', priority = 5},
                {val = 'TEST3', priority = 3},
                {val = 'TEST4', priority = 4},
            },
            expected_heap = {
                {val = 'TEST7', priority = 7},
                {val = 'TEST4', priority = 4},
                {val = 'TEST5', priority = 5},
                {val = 'TEST3', priority = 3},
            },
            expected_val = 'TEST9',
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        local heap = deepCopy(case.input_heap)
        local val = pf:_heapPop(heap)
        if not deepEqual(case.expected_heap, heap) then
            error(string.format('case #%d: wrong heap', case_idx))
        end
        if not deepEqual(case.expected_val, val) then
            error(string.format('case #%d: wrong val (expected %s, got %s)', case_idx, case.expected_val, val))
        end
    end
end

function testGetPathList(pf)
    local case_tbl = {
        {
            input_node_list = {},
            input_start_node_idx = nil,
            input_end_node_idx = nil,
            expected_path_list = {},
        },
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_start_node_idx = nil,
            input_end_node_idx = 1,
            expected_path_list = {},
        },
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
                [2] = {
                    x = 0,
                    z = 1,
                    cost = 1,
                    prev = 1,
                    visited = true,
                },
                [3] = {
                    x = 0,
                    z = 2,
                    cost = 2,
                    prev = 2,
                    visited = true,
                },
            },
            input_start_node_idx = 1,
            input_end_node_idx = 3,
            expected_path_list = {
                {x = 0, z = 1},
                {x = 0, z = 2},
            },
        },
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
                [2] = {
                    x = 0,
                    z = 1,
                    cost = 1,
                    prev = 1,
                    visited = true,
                },
                [3] = {
                    x = 0,
                    z = 2,
                    cost = nil,
                    prev = nil,
                    visited = false,
                },
            },
            input_start_node_idx = 1,
            input_end_node_idx = 3,
            expected_path_list = {
                {x = 0, z = 1},
            },
        },
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
            },
            input_start_node_idx = nil,
            input_end_node_idx = 1,
            expected_path_list = {
                {x = 0, z = 0},
            },
        },
        {
            input_node_list = {
                [1] = {
                    x = 0,
                    z = 0,
                    cost = 0,
                    prev = nil,
                    visited = true,
                },
            },
            input_start_node_idx = 1,
            input_end_node_idx = 1,
            expected_path_list = {},
        },
    }

    for case_idx, case in ipairs(case_tbl) do
        pf._node_list = case.input_node_list
        pf._start_node_idx = case.input_start_node_idx
        pf._end_node_idx = case.input_end_node_idx
        local path_list = pf:_getPathList()
        if not deepEqual(case.expected_path_list, path_list) then
            error(string.format('case #%d: wrong path_list', case_idx))
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

    function env.server.getTile(transform)
        local transform_x, _, transform_z = env.matrix.position(transform)
        if transform_x%1 ~= 0 then
            error(string.format('unsupported argument to transform_x (integer expected, got "%s")', transform_x))
        end
        if transform_z%1 ~= 0 then
            error(string.format('unsupported argument to transform_z (integer expected, got "%s")', transform_z))
        end

        local tile_data = {
            ['name'] = '',
            ['sea_floor'] = 100,
            ['cost'] = 0,
            ['purchased'] = false,
        }
        return tile_data, true
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
