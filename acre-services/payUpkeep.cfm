<cfsilent>
<cfif not isDefined("FORM.ci")>
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

<cfset lotRec = g_lot.getLotRecord(input.ci, input.cj) />

<cfif result.success>
	<cfif lotRec.recordCount is not 0 and lotRec.ownerId is not SESSION.userId>
    	<cfset result['success'] = false />
		<cfset result['errorId'] = 8/>
        <cfset result['errorMessage'] = "lot is owned by other user" />
    </cfif>
</cfif>

<cfif result.success and (not isDefined("SESSION.lastLotLocation") or SESSION.lastLotLocation is not "#input.ci#,#input.cj#")
	and (not isDefined("SESSION.payableLots") or listFind(SESSION.payableLots,lotRec.id) is 0)>
	<cfset result['success'] = false />
	<cfset result['errorId'] = 9/>
    <cfset result['errorMessage'] = "lot not payable" />
</cfif>

<cfif result.success>
	<cfif lotRec.recordCount is not 0>
		<cfset result = g_lot.payUpkeep(lotRec, SESSION.userId)/>
	<cfelse>
    	<cflock name="lot#input.ci#,#input.cj#" timeout="10">
        	<cfset result = g_lot.claimLot(input.ci,input.cj,SESSION.userId,input.name)/>
        </cflock>
    </cfif>
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