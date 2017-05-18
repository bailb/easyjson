#coding=utf-8

import json
# eleType="varlist/objbegin/objend/objlistbegin/objlistend"
#
#
class Element(object):
        def __init__(self,level,name,desc,eleType):
                self._level=level
                self._name=name
                self._desc=desc
                self._eleType=eleType

class ElementList(object):
        def __init__(self):
                self._eleList=[]

        def push_back(self,aElement):
                self._eleList.append(aElement)
                return self._eleList;

        def count(self):
                return len(self._eleList)

        def getIndex(self,index):
                return self._eleList[index]


g_ElementList = ElementList()

def getType(value):
    if(isinstance(value,dict)):
        return 'obj'
    elif(isinstance(value,list)):
        if(isinstance(value[0],str) or isinstance(value[0],unicode)):
            return 'varlist'
        else:
            return 'objlist'
    elif(isinstance(value,str) or isinstance(value,unicode)):
        return 'var'

def getDesc(string):
    if(isinstance(string,str) or isinstance(string,unicode)):
        return string
    else:
        return ""
def isListLegal(value):
    if(len(value) > 1):
        return False
    if(isinstance(value[0],list) or isinstance(value[0],dict) or isinstance(value[0],str) or isinstance(value[0],unicode)):
        return True
    else:
        return False

def dumpJson(jsonStr,i=0):
    if(isinstance(jsonStr,dict)):
        for item in jsonStr:
            print("item  : ["+item + "] getType[ "+ getType(jsonStr[item]) + "] type %s %s"%(type(jsonStr[item]),i))
            desc=getDesc(jsonStr[item])
            valueType=getType(jsonStr[item])
            aElem=Element(i,item,desc,valueType)
            g_ElementList.push_back(aElem)

            if(isinstance(jsonStr[item],dict)):
                dumpJson(jsonStr[item],i=i+1)
            elif(isinstance(jsonStr[item],list)):
                if(False == isListLegal(jsonStr[item])):
                    print("This json wasn't right["+item+"]")
                    return False
                dumpJson(jsonStr[item],i=i+1)
            elif(isinstance(jsonStr[item],str) or isinstance(jsonStr[item],unicode)):
                print("****%s"%jsonStr[item])
            else:
                print("ERROR type:%s" % type(jsonStr[item]))
#            desc=getDesc(jsonStr[item])
#            valueType=getType(jsonStr[item])
#            aElem=Element(i,item,desc,valueType)
#            g_ElementList.push_back(aElem)
    elif(isinstance(jsonStr,list)):
        length=len(jsonStr)
        for j in range(0, length):
            if(isinstance(jsonStr[j],dict)):
                dumpJson(jsonStr[j],i=i+1)
            else:
                print("type [%s]"%type(jsonStr[j]))
    else:
        print("jsonStr is not json object!")


jsonStr=open("test.lua","r").read()
print jsonStr
encodejson = json.load(open("json",'r'))
print (type(encodejson))
dumpJson(encodejson)
listCount=g_ElementList.count();

for i in range(listCount):
    aEl=g_ElementList.getIndex(i)
    print("i[%s] desc[%s] type[%s] name[%s]"%(aEl._level,aEl._desc,aEl._eleType,aEl._name))
