function read_file(filePath)
    file = io.open(filePath,'r')
    t = file:read("*all")
    file:close()
	return t
end

local json = require "easyjson"
str = "{\
  \"f1\":1, \
  \"f2\":\"xx\\\"cc\\\"xx\",\
  \"g2\":true,\
  \"f4\":{\
   \"h2\":\"hjk\",\
    \"h1\":789 \
  },\
  \"g3\":false,\
  \"f3\":[{\
    \"xxx\":1,\
    \"yyy\":\"222\"\
  }] \
}";

local tt={
f="x",g="d",d="20",
hh={10},{20},{30}
}

str1=json.encode(tt,true)
print(str1)


local tt, err = json.decode(str)
if not tt then
    print(err)
else
    print(json.encode(tt, true, 0, {ind='  ', line='\n'}))
end

local dump=require("dumpTable")
jsonStr=read_file("json.data")
print(jsonStr)

tt,err=json.decode(jsonStr)
dump(tt,"tt",8)

function getType(v)
	if type(v) == 'table' then
		if type(v[1]) == 'table' then
			return 'list'
		else
			return 'obj'
		end
	else
		return 'string'
	end
end

function generate(xtable)
    for k,v in pairs(xtable) do
		print("k:"..k.."  v:"..type(v))
		local Type=getType(v)
        if (Type == 'obj') then
            generate(v)
		elseif (Type == 'list') then
			generate(v[1])
        end
    end
end

generate(tt)
