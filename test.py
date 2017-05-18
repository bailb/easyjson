import jsonUtils
import json

g_ElementList = jsonUtils.ElementList()

jsonStr=open("json.data","r").read()
print jsonStr
print ("-------type:[%s]"%type(jsonStr))
encodejson = json.load(open("json.data",'r'))
print (type(encodejson))
jsonUtils.decodeJson(encodejson,g_ElementList,0)
listCount=g_ElementList.count();

for i in range(listCount):
    aEl=g_ElementList.pop()
    print("i[%s] desc[%s] type[%s] name[%s] [%s]"%(aEl._level,aEl._desc,aEl._eleType,aEl._name,i))

