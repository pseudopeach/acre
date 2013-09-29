<cfcomponent>
	<cffunction name="structToPlistDict" access="public" returntype="string" output="false">
		<cfargument name="str" type="struct" required="yes">
        <cfargument name="omitDictTags" type="boolean" required="no" default="false"/>
		<cfset var result="<dict>">
        <cfset var keys = structKeyList(str)/>
        <cfset var tmpDate = now()/>
        <cfset var i = 0/>
<cfsavecontent variable="result"><cfoutput>
<cfif not omitDIctTags><dict></cfif>
<cfloop list="#keys#" index="i"><key>#i#</key>#varToDictItem(str[i])#
</cfloop>
<cfif not omitDIctTags></dict></cfif></cfoutput></cfsavecontent>
		<cfreturn result />
	</cffunction>
    
    <cffunction name="varToDictItem" output="false" returntype="string">
    	<cfargument name="theVar"/>
        <cfargument name="dataType" required="no"/>
    	<cfset var result =""/>
        <cfset var tmpDate = now() />
        
		<cfif isDefined("dataType") and (dataType is 'VARCHAR' or theVar is '')>
            <cfset result = '<string>#theVar#</string>' />
        <cfelseif isDefined("dataType") and (dataType is 'INTEGER' or dataType is 'BIGINT')>
            <cfset result = '<integer>#theVar#</integer>' />
        <cfelseif isDefined("dataType") and (dataType is 'FLOAT' or dataType is 'DOUBLE')>
            <cfset result = '<real>#theVar#</real>' />
        
   
        <!--- automatically determine type --->
        <cfelseif isNumeric(theVar)>
            <cfif round(theVar) is theVar>
                <cfset result = '<integer>#theVar#</integer>' />
            <cfelse>
                <cfset result = '<real>#theVar#</real>' />
            </cfif>
        <cfelseif isDate(theVar)>
            <cfset tmpDate = DateAdd( "s", GetTimeZoneInfo().UTCTotalOffset, theVar ) />
            <cfset result = '<date>#dateFormat(tmpDate,"yyyy-mm-dd")#T#dateFormat(tmpDate,"HH:mm:ss")#Z</date>' /><!---2010-12-15T20:51:44Z--->
            
        <cfelseif isQuery(theVar)>
            <cfset result = queryToDictArray(theVar) />
        <cfelseif isBoolean(theVar)>
            <cfif theVar> <cfset result = "<true/>"/>
            <cfelse> <cfset result = "<false/>"/></cfif>
        <cfelseif isStruct(theVar)>
            <cfset result = structToPlistDict(theVar)/> 
        <cfelseif isArray(theVar)>
            <cfset result = arrayToArray(theVar) />
        <cfelse>
            <cfset result = '<string>#theVar#</string>' />
        </cfif>
        
    <cfreturn result/>
    </cffunction>
    
    <cffunction name="arrayToArray" output="false">
    	<cfargument name="ary">
        <cfset var i = 0/>
        <cfset var result = "<array>"/>
        <cfloop from="1" to="#arrayLen(ary)#" index="i">
			<cfset result = result&varToDictItem(ary[i]) />
        </cfloop>
        <cfset result = result&"</array>" />
        <cfreturn result />
    </cffunction>
    
    <cffunction name="queryToDictArray" output="false">
    	<cfargument name="qry" type="query"/>
        <cfargument name="clist" type="string" required="no" default=""/>
        
        <cfset var i = 0/>
        <cfset var result =""/>
        <cfset var columnTypeList = ""/>
        <cfset var someArray = getMetaData(qry)/>
        <cfif clist is "">
        	<cfoutput><cfloop array="#someArray#" index="i">
            	<cfset clist = listAppend(clist, i.name)/>
                <cfset columnTypeList = listAppend(columnTypeList, i.TypeName)/>
        	</cfloop></cfoutput>
         </cfif>
        
<cfsavecontent variable="result">
<cfoutput>
<array><cfloop query="qry">
<dict><cfloop from="1" to="#listLen(clist)#" index="i">
    <key>#listGetAt(clist,i)#</key>#varToDictItem(qry[listGetAt(clist,i)][currentRow], listGetAt(columnTypeList,i) )#</cfloop>
</dict></cfloop>
</array> 
</cfoutput></cfsavecontent> 
        
        <cfreturn result/> 	
    </cffunction>
    
        <cffunction name="queryLineToDictItems" output="false">
    	<cfargument name="qry" type="query"/>
        <cfargument name="clist" required="no" default=""/>
        <cfset var someArray = arrayNew(1)/>
        <cfset var columnTypeList = ""/>
        <cfset var tempint =  0/>
        
        <cfset var i = 0/>
       
       	<cfif clist is "">
			<cfset someArray = getMetaData(qry)/>
            <cfloop array="#someArray#" index="i">
                <cfset clist = listAppend(clist, i.name)/>
                <cfset columnTypeList = listAppend(columnTypeList, i.TypeName)/>
            </cfloop>
        <cfelse>
        	<cfset someArray = getMetaData(qry)/>
            <cfset columnTypeList = clist />
           <cfloop array="#someArray#" index="i">
           		<cfset tempint = listFind(clist,i.name) />
                <cfif tempint is not 0 >
                	<cfset columnTypeList = listSetAt(columnTypeList,tempint,i.TypeName) />
                </cfif>
            </cfloop>  
        </cfif>
         
        
<cfsavecontent variable="result">
<cfoutput>
<cfloop from="1" to="#listLen(clist)#" index="i">
    <key>#listGetAt(clist,i)#</key>#varToDictItem(qry[listGetAt(clist,i)], listGetAt(columnTypeList,i) )#</cfloop>
</cfoutput></cfsavecontent> 
        
        <cfreturn result/> 	
    </cffunction>
    
    
</cfcomponent>