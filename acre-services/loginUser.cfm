<cfsilent>
<cfset input = FORM/>
<cfif not isDefined("FORM.password")> <cfset input = URL/></cfif>
<cfinvoke component="model.g_user" method="checkLogin" returnvariable="loginRecord">
	<cfinvokeargument name="login" value="#input.login#"/>
    <cfinvokeargument name="password" value="#input.password#"/>
</cfinvoke>
<cfset result = structNew()/>
<cfset result['success'] = loginRecord.RecordCount is 1/>
<cfif result.success>
	<cfset g_user.processLogin(loginRecord)/>
    <cfset result['resultObject'] = structNew()/>
    <cfset result.resultObject['sessionInfo'] = structNew()/>
    <cfset result.resultObject.sessionInfo['dbId'] = loginRecord.id/>
    <!---<cfset result.resultObject.sessionInfo['email'] = loginRecord.email/>--->
    <cfset result.resultObject.sessionInfo['screenName'] = loginRecord.screenName/>
    <cfset result.resultObject.sessionInfo['isFemale'] = loginRecord.isFemale is not 0/>
    
    <cfset result.resultObject['carryLimit'] = loginRecord.carryLimit/>
    
	<cfset result.resultObject['allItems'] = g_items.getAllResourceTypes()/>
	<!---<cfset result.resultObject['allDevelopments'] =--->
	<cfset result.resultObject['carriedItems'] = g_items.getCarriedItems(loginRecord.id)/>
	
    
    <cfset userLotTypes = g_user.getUserLotTypes(loginRecord.id)/>
    <cfquery dbtype="query" name="uBalanceQ">
    	SELECT * from result.resultObject.carriedItems
        WHERE typeId = 1
    </cfquery>
    
    <cfif (userLotTypes.nStore + userLotTypes.nFactory) is 0 or uBalanceQ.qty lt 1000>
		<cfif g_lot.getLotsByOwner(SESSION.userId).recordCount is 0>
            <cfset result.resultObject['notice'] = "Start by making a few gardens in empty lots, then coming back a few hours later to see what grew!" />
        <cfelseif result.resultObject.carriedItems.recordCount lt 3>
        	 <cfset result.resultObject['notice'] = "Check your garden and farm lots to see if anything has grown. Even empty lots sometimes have free items." />
        <cfelseif uBalanceQ.qty lt 20>
        	 <cfset result.resultObject['notice'] = "Need some money? Try selling your items to a factory, or liquidating them by pressing the house icon." />
        <cfelseif userLotTypes.nFactory is 0>
        	 <cfset result.resultObject['notice'] = "Try building some factories that use items common in your area. That's where the real money is!" />
        <cfelseif userLotTypes.nHouse is 0>
        	 <cfset result.resultObject['notice'] = "Having trouble keeping track of all your lots? Build houses in each area, so you can upkeep without visiting." />
        </cfif>
    </cfif>
    
    
<cfelse>
	<cfset result['errorId'] = 2/>
    <cfset result['errorMessage'] = "Login incorrect."/>
</cfif>
</cfsilent><cfoutput>
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<cfif not result.success>#PlistUtil.structToPlistDict(result)#<cfelse>
<dict>
    <key>success</key>#PListUtil.varToDictItem(result.success)#
    <key>resultObject</key>
    <dict>
        #PlistUtil.structToPlistDict(result.resultObject,true)#
        <key>allDevelopments</key><cfinclude template="/acre-services/allDevelopments.xml" />
    </dict>
</dict></cfif>
</plist>
</cfoutput>