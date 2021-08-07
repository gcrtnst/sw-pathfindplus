-- SPDX-License-Identifier: Unlicense

local g_announce_name = '[pfpjoint]'

function onCreate(is_world_create)
    local version = 1
    if type(g_savedata) ~= 'table' or g_savedata.version ~= version then
        g_savedata = {
            version = version,
            joint_tbl = {},
        }
    end

    local tile_size = 1000
    for x = -64000, 64000, tile_size do
        for z = -64000, 128000, tile_size do
            local _, is_success = server.getOceanTransform(matrix.translation(x, 0, z), 0, 1)
            if is_success then
                goto continue
            end

            local tile, is_success = server.getTile(matrix.translation(x, 0, z))
            if not is_success then
                goto continue
            end

            g_savedata.joint_tbl[tile.name] = g_savedata.joint_tbl[tile.name] or {[1] = true, [2] = true, [3] = true, [4] = true, [6] = true, [7] = true, [8] = true, [9] = true}
            for joint_idx, _ in pairs(g_savedata.joint_tbl[tile.name]) do
                local near_x = x + tile_size*((joint_idx - 1)%3 - 1)
                local near_z = z + tile_size*((joint_idx - 1)//3 - 1)
                local _, is_success = server.getOceanTransform(matrix.translation(near_x, 0, near_z), 0, 1)
                if is_success then
                    g_savedata.joint_tbl[tile.name][joint_idx] = nil
                    goto continue
                end

                local near, is_success = server.getTile(matrix.translation(near_x, 0, near_z))
                if not is_success then
                    goto continue
                end

                if g_savedata.joint_tbl[near.name] ~= nil and g_savedata.joint_tbl[near.name][10 - joint_idx] == nil then
                    g_savedata.joint_tbl[tile.name][joint_idx] = nil
                    goto continue
                end

                ::continue::
            end

            ::continue::
        end
    end

    local code = {}
    for tile_name, joint in pairs(g_savedata.joint_tbl) do
        local field_list = {}
        for joint_idx = 1, 9 do
            if joint[joint_idx] then
                table.insert(field_list, string.format('[%d] = true', joint_idx))
            end
        end
        if #field_list > 0 then
            table.insert(code, string.format("['%s'] = {", tile_name) .. table.concat(field_list, ', ') .. '},')
        end
    end
    table.sort(code)

    server.announce(g_announce_name, '-- begin code generated by pfpjoint')
    for _, line in ipairs(code) do
        server.announce(g_announce_name, line)
    end
    server.announce(g_announce_name, '-- end code generated by pfpjoint')

    server.save()
end