local util = {}

function util.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function util.file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        f:close()
        return true
    end
    return false
end

function util.tableWriteStr(tableName, tbl)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = tableName.." = {\n"

    while true do
        local size = 0
        for k,v in pairs(tbl) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(tbl) do
            if (cache[tbl] == nil) or (cur_index >= cache[tbl]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = '["'..tostring(k)..'"]'
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,tbl)
                    table.insert(stack,v)
                    cache[tbl] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. ' = "'..tostring(v)..'"'
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            tbl = stack[#stack]
            stack[#stack] = nil
            depth = cache[tbl] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    local tableEmpty = true

    for _ in pairs(tbl) do
        tableEmpty = false
        break
    end

    if tableEmpty then
        output_str = tableName.." = {}"
    end

    return output_str
end

return util