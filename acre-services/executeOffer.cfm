<cfsilent>
<cfset input = FORM/>
<cfif not isDefined("FORM.id")>
	<cfset input = URL />
</cfif>

<cfset result = structNew()/>
<cfset result['success'] = true/>

<cfif not isDefined("SESSION.isLoggedIn") or not SESSION.isLoggedIn>
	<cfheader statuscode="401"/>
    <cfset result['success'] = false />
    <cfset result['errorId'] = 1/>
    <cfset result['errorMessage'] = "not logged in" />
</cfif>
<cfif result.success>
	<cfset offerRec = g_items.getOfferById(input.id,true)/>
    
    <cfif offerRec.recordCount is 0>
    	<cfset result['success'] = false />
        <cfset result['errorId'] = 2/>
        <cfset result['errorMessage'] = "Offer not found" />
    </cfif>
</cfif>

<cfif result.success and (not isDefined("SESSION.lastLotLocation") or SESSION.lastLotLocation is not "#offerRec.loc_i#,#offerRec.loc_j#")>
	<cfset result['success'] = false />
    <cfset result['errorId'] = 3/>
    <cfset result['errorMessage'] = "Offer not available in current lot" />
</cfif>

<cfif result.success>  
    <cflock name="lot#offerRec.loc_i#,#offerRec.loc_j#" timeout="10">
        <cfset result = g_items.executeOffer(offerRec,SESSION.userId)/>
    </cflock>
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

