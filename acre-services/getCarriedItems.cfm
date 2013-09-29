<cfsilent>
<cfset input = FORM/>


<cfset result = structNew()/>
<cfset result['success'] = true/>

<cfif not isDefined("SESSION.isLoggedIn") or not SESSION.isLoggedIn>
	<cfheader statuscode="401"/>
    <cfset result['success'] = false />
    <cfset result['errorId'] = 1/>
    <cfset result['errorMessage'] = "not logged in" />
</cfif>
<cfif result.success>
	<cfset result['resultQuery'] = g_items.getCarriedItems(SESSION.userId)/>
</cfif>

</cfsilent><!---<cfcatch type="any">
	<cfheader statuscode="400"/> <!---401=unauthorized--->
    <h1>Bad Request</h1>
    <cfabort/>
</cfcatch></cftry>--->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<cfoutput>#PListUtil.structToPListDict(result)#</cfoutput>
</plist>