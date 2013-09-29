<cfsilent>
<cfif not isDefined("FORM.id")>
	<cfset input = URL/>
<cfelse>
	<cfset input = FORM/>
</cfif>

<cfset result = structNew()/>
<cfset result['success'] = true/>

<cfif not isDefined("SESSION.isLoggedIn") or not SESSION.isLoggedIn>
	<cfheader statuscode="401"/>
    <cfset result['success'] = false />
    <cfset result['errorId'] = 1/>
    <cfset result['errorMessage'] = "not logged in" />
</cfif>

<cfset itemRec = g_items.getItemRecord(input.id) />

<cfif result.success>
	<cfif itemRec.recordCount is 0>
    	<cfset result['success'] = false />
		<cfset result['errorId'] = 2/>
        <cfset result['errorMessage'] = "Item not found" />
    </cfif>
</cfif>

<cfif result.success>
	<cfif itemRec.ownerId is not SESSION.userId>
    	<cfset result['success'] = false />
		<cfset result['errorId'] = 3/>
        <cfset result['errorMessage'] = "Item is owned by other user" />
    </cfif>
</cfif>

<cfif result.success>
	<cfif itemRec.loc_i is not 162001>
    	<cfset result['success'] = false />
		<cfset result['errorId'] = 4/>
        <cfset result['errorMessage'] = "Item is not carried" />
    </cfif>
</cfif>

<cfif result.success>
	<cfset result = g_items.liquidateItem(itemRec) />
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