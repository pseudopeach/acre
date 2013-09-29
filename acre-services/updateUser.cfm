<cftry><cfsilent>
<cfset input = FORM/>

<cfset result = structNew()/>
<cfset result['success'] = true/>

<cfif not isDefined("SESSION.isLoggedIn") or not SESSION.isLoggedIn>
	<cfset result['success'] = false/>
    <cfset result['errorId'] = 1/>
    <cfset result['errorMessage'] = "User not logged in" />
</cfif>

<cfif result.success>
<cfinvoke component="model.g_user" method="commitUser" returnvariable="result1">
	<cfinvokeargument name="email" value="#input.email#"/>
    <cfinvokeargument name="screenName" value="#input.screenName#"/>
    <cfinvokeargument name="password" value="#input.password#"/>
    <cfinvokeargument name="isFemale" value="#input.isFemale#"/>
    <cfinvokeargument name="userId" value="#SESSION.userId#"/>
</cfinvoke>
<cfset result = result1/>
</cfif>

</cfsilent><cfcatch type="any">
	<cfheader statuscode="400"/> <!---401=unauthorized--->
    <h1>Bad Request</h1>
    <cfabort/>
</cfcatch></cftry>
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<cfoutput>#PListUtil.structToPListDict(result)#</cfoutput>
</plist>
