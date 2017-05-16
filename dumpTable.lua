--这是quick中的工具，作用就是打印Lua中强大的table的结构， 当table的嵌套层级比较多的时候，这个工具非常方便，开发中必备的工具。
--具体使用方法：local debug = require("debug")
--　　　　　　　debug.dump(dataTable, "dataTable", 3)  接下来就可以在控制台看到输出的结果了，非常漂亮的树形结构
--module(..., package.seeall)

--local g_Debug_Flag = true

--function log(msg)
--    if g_Debug_Flag == false then
--       return
--    end
--   cclog(msg)
--end

---
--@function  dump()
--@param value table 需要打印的
--@param description string 描述
--@param nesting int table嵌套层级
--@end

function dump(value, description, nesting)
--    if g_Debug_Flag == false then
--       return
--    end

    --默认打印层级3
    if type(nesting) ~= "number" then
        nesting = 3
    end

    local lookupTable = {}
    local result =  {}

    function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    function _dump(value, description, indent, nest, keylen)
        description = description or "<var>"
        spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ",keylen - string.len(_v(description)))
        end

        if type(value) ~= "table" then
            result[#result + 1] = string.format("%s%s%s = %s", indent, _v(description), spc, _v(value))
        elseif lookupTable[value] then
            result[#result + 1] = string.format("%s%s%s = *REF*", indent, description, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, description)
            else
                result[#result + 1] = string.format("%s%s = {" , indent, _v(description))
                local indent2 = indent .. "    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vk1 = string.len(vk)
                    if vk1 > keylen then
                        keylen = vk1
                    end
                    values[k] = v
                end
                table.sort(keys,function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)

                for i, k in pairs(keys) do
                    _dump(values[k], k, indent2,nest + 1,keylen)
                end
                result[#result + 1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value,description, "- ", 1)

    for i, line in pairs(result) do
        print(line)
    end
end

--function (logStr)
--    print(logStr)
--    print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
--end
return dump
