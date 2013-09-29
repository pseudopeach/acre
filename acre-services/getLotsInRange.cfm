<cftry>
<cfif not isDefined("FORM.centerCi")>
	<cfset input = URL/>
<cfelse>
	<cfset input = FORM/>
</cfif>

<cfparam name="input.lotlist" default=""/>

<cfset result = structNew()/>
<cfset result['success'] = true/>

<cfif not isDefined("SESSION.isLoggedIn") or not SESSION.isLoggedIn>
	<cfheader statuscode="401"/>
	<cfset result['success'] = false/>
    <cfset result['errorId'] = 1/>
    <cfset result['errorMessage'] = "not logged in" />
</cfif>

<cfif result.success and isDefined("input.GPSLatitude")>
	<cfinvoke component="model.g_user" method="updateUserLocation" returnvariable="result1">
        <cfinvokeargument name="lat" value="#input.GPSLatitude#"/>
        <cfinvokeargument name="lon" value="#input.GPSLongitude#"/>
        <cfinvokeargument name="userId" value="#SESSION.userId#"/>
    </cfinvoke>
    <cfset result = result1 />
</cfif>

<cfif result.success and not isDefined("SESSION.checkin_lat")>
    <cfset result['success'] = false/>
    <cfset result['errorId'] = 5/>
    <cfset result['errorMessage'] = "User location not set" />
</cfif>

<cfif result.success>
<cfinvoke component="model.g_lot" method="getSquaresByLocation" returnvariable="lotList">
	<cfinvokeargument name="Ci" value="#input.centerCi#"/>
    <cfinvokeargument name="Cj" value="#input.centerCj#"/>
    <cfinvokeargument name="hashList" value="#input.lotList#"/>
    <cfinvokeargument name="range" value="26"/>
</cfinvoke>
<cfset result['resultQuery'] = lotList/>
</cfif>


<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<cfoutput>#PListUtil.structToPListDict(result)#</cfoutput>
</plist>
<cfcatch type="any">
	<cfmail from="acre@actinicapps.com" to="justin@mopkin.com,pseudopeach@gmail.com" subject="-1 error">
    	<cfdump var="#cfcatch#"/>
    </cfmail>
    <cfabort/>
</cfcatch></cftry>
<!---<cfif isDefined("result1")>
check in result:<cfdump var="#result1#">
</cfif>
<cfdump var="#lotlist#">
<cfdump var="#result#">--->