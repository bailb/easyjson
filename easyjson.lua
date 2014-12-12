--[[
The MIT License (MIT)

Copyright (c) 2014 Ping.X

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

-------------------------------------------------------------------------------
--	json encoding implementation
-------------------------------------------------------------------------------
local function isarray(t)
	if t[1] == nil then
		return false
	else
		return true
	end
end

function encode(t, isfmt, level)
	local json = ''
	level = level or 0
	local tab = isfmt and '\t' or ''
	local tabs = isfmt and string.rep(tab, level) or ''
	local el = isfmt and '\n' or ''
	if t == nil then
		json = json..'null'
	elseif type(t) == 'boolean' then
		json = json..tostring(t)
	elseif type(t) == 'number' then
		json = json..t
	elseif type(t) == 'table' then
		if isarray(t) then
			json = json..'['..el
			for i = 1, #t do
				if i > 1 then
					json = json..','..el
				end
				json = json..tabs..tab..encode(t[i], isfmt, level + 1)
			end
			json = json..el..tabs..']'
		else
			json = json..'{'..el
			local count = 0
			for i, v in pairs(t) do
				count = count + 1
				if count > 1 then
					json = json..','..el
				end
				json = json..tabs..tab..'"'..i..'":'..encode(v, isfmt, level + 1)
			end
			json = json..el..tabs..'}'
		end
	else
		json = json..'"'..string.gsub(t, '"', '\\"')..'"'
	end
	return json
end

-------------------------------------------------------------------------------
--	json decoding implementation, using Lua string Regular Expression
-------------------------------------------------------------------------------
local function find_key(json, pos)
	local _, ep, key = string.find(json, '^%s*"(%w+)"%s*:', pos)
	return key, ep
end

local function find_quote_string(json, pos)
	pos = pos or 1
	local outside = true
	local lastch
	local startpos
	for i = pos, #json do
		local ch = string.sub(json, i, i)
		if ch == '"' and lastch ~= '\\' then
			if outside then
				startpos = i
				outside = false
			else
				local value = string.sub(json, startpos + 1, i - 1)
				return startpos, i, string.gsub(value, '\\"', '"')
			end
		else
			if outside then
				if ch ~= '\n' and ch ~= '\r' and ch ~= '\t' and ch ~= ' ' then
					break
				end
			end
		end
		lastch = ch
	end
end

local function find_value(json, pos)
	local _, ep, value = find_quote_string(json, pos)
	if value ~= nil then
		return 'string', value, ep
	end
	local _, ep, value = string.find(json, '^%s*([+-]?[%.%d]+)', pos)
	if value ~= nil then
		return 'number', tonumber(value), ep
	end
	local _, ep, value = string.find(json, '^%s*(true)', pos)
	if value ~= nil then
		return 'bool', true, ep
	end
	local _, ep, value = string.find(json, '^%s*(false)', pos)
	if value ~= nil then
		return 'bool', false, ep
	end
	local _, ep, value = string.find(json, '^%s*(null)', pos)
	if value ~= nil then
		return 'null', nil, ep
	end
	local _, ep, value = string.find(json, '^%s*(%b{})', pos)
	if value ~= nil then
		return 'object', value, ep
	end
	local _, ep, value = string.find(json, '^%s*(%b[])', pos)
	if value ~= nil then
		return 'array', value, ep
	end
end

local function find_seperator(json, pos)
	local _, ep, sep = string.find(json, '^%s*([,}%]])', pos)
	return sep, ep
end

function parse_object(object)
	local t = {}
	if #object == 2 then
		return t
	end
	local pos = 1
	while true do
		local key, kind, value, sep
		key, pos = find_key(object, pos + 1)
		if key == nil then
			return nil, 'cannot find key'
		end
		kind, value, pos = find_value(object, pos + 1)
		if kind == nil then
			return nil, 'cannot find value'
		end
		if kind == 'object' then
			local sub, err = parse_object(value)
			if sub == nil then
				return nil, err
			else
				t[key] = sub
			end
		elseif kind == 'array' then
			local sub, err = parse_array(value)
			if sub == nil then
				return nil, err
			else
				t[key] = sub
			end
		else
			t[key] = value
		end
		sep, pos = find_seperator(object, pos + 1)
		if sep == ',' then
		elseif sep == '}' then
			return t
		else
			return nil, 'missing "}"'
		end
	end
	return t
end

function parse_array(array)
	local t = {}
	if #array == 2 then
		return t
	end
	local pos = 1
	local count = 1
	while true do
		local kind, value, sep
		kind, value, pos = find_value(array, pos + 1)
		if kind == nil then
			return nil, 'cannot find element'
		end
		if kind == 'object' then
			local sub, err = parse_object(value)
			if sub == nil then
				return nil, err
			else
				t[count] = sub
			end
		elseif kind == 'array' then
			local sub, err = parse_array(value)
			if sub == nil then
				return nil, err
			else
				t[count] = sub
			end
		else
			t[count] = value
		end
		sep, pos = find_seperator(array, pos + 1)
		if sep == ',' then
			count = count + 1
		elseif sep == ']' then
			return t
		else
			return nil, 'missing "]"'
		end
	end
	return t
end

function decode(json)
	local kind, value = find_value(json)
	if kind == 'object' then
		return parse_object(value)
	elseif kind == 'array' then
		return parse_array(value)
	end
	return nil, 'cannot find json object or array'
end

-------------------------------------------------------------------------------
--	export functions
-------------------------------------------------------------------------------
return {
	encode = encode,
	decode = decode
}
