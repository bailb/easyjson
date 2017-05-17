import json

def dumpJson(jsonStr,i=0):
    if(isinstance(jsonStr,dict)):
        for item in jsonStr:
            print("item  : "+item)
            print(type(jsonStr[item]))
            if(isinstance(jsonStr[item],dict)):-
                dumpJson(jsonStr[item],i=i+1)
            elif(isinstance(jsonStr[item],list)):
                length=len(jsonStr[item])
                for i in range(0, length):
                    if(isinstance(jsonStr[item][i],dict)):
                        dumpJson(jsonStr[item][i])
            else:
                print("**** %s"%jsonStr[item])

    else:
        print("jsonStr is not json object!")
