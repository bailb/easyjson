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

eList = jsonUtils.ElementList()
eStack=jsonUtils.ElementList()
#(level,name,desc,eleType)
#eStack.push(g_ElementList.getIndex(0))
def conToClassDesc():
    for i in range(0,listCount):
        aEl=g_ElementList.getIndex(i)
        
        print("i[%s] desc[%s] type[%s] name[%s] [%s]"%(aEl._level,aEl._desc,aEl._eleType,aEl._name,i))
        if (aEl._eleType == 'objlist'):
            if (eStack.count() == 0):
                eStack.push(aEl)
                eList.pushParam(aEl._level,aEl._name,aEl._desc,"objlistbegin")
            else:
                ele=eStack.pop()
                if(ele._level == aEl._level):
                    eList.pushParam(ele._level,ele._name,ele._desc,ele._eleType+"end")
                else:
                    eStack.push(ele)
                eList.pushParam(aEl._level,aEl._name,aEl._desc,"objlistbegin")
                eStack.push(aEl)

        elif(aEl._eleType == 'obj'):
            if (eStack.count() == 0):
                eStack.push(aEl)
                eList.pushParam(aEl._level,aEl._name,aEl._desc,"objbegin")
            else:
                ele=eStack.pop()
                if(ele._level == aEl._level):
                    eList.pushParam(ele._level,ele._name,ele._desc,ele._eleType+"end")
                else:
                    eStack.push(ele)
                eList.pushParam(aEl._level,aEl._name,aEl._desc,"objbegin")
                eStack.push(aEl)
        elif(aEl._eleType == 'var' or aEl._eleType == 'varlist'):
            if (eStack.count() == 0):
                eStack.push(aEl)
            else:
                ele=eStack.pop()
                if(ele._level == aEl._level):
                    eList.pushParam(ele._level,ele._name,ele._desc,ele._eleType+"end")
                else:
                    eStack.push(ele)
            eList.pushParam(aEl._level,aEl._name,aEl._desc,aEl._eleType)

    if (eStack.count() > 0):
        eStack.pop()

conToClassDesc()

print("----------------------------------")
for i in range(eList.count()):
    aEl=eList.getIndex(i) 
    print("i[%s] desc[%s] type[%s] name[%s] [%s]"%(aEl._level,aEl._desc,aEl._eleType,aEl._name,i))

print("----------------------------------")
for i in range(eStack.count()):
    aEl=eStack.getIndex(i) 
    print("i[%s] desc[%s] type[%s] name[%s] [%s]"%(aEl._level,aEl._desc,aEl._eleType,aEl._name,i))


