
<cfif not isDefined("FORM.screenName")>
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

<cfset userRec = g_user.getUserByScreenName(input.screenName) />
<cfif result.success and userRec.recordCount is 0>
    <cfset result['success'] = false />
    <cfset result['errorId'] = 2/>
    <cfset result['errorMessage'] = "user not found #input.screenName#" />
</cfif>

<cfif result.success>
    <cfset nEvents = g_user.getNUserEvents(userRec.dbId) />
    <cfset nItems = g_items.getNUserItems(userRec.dbId) />
    <cfset titleQ =  g_user.getTitlesForUser(userRec.dbId)/>
    <cfset lotLocations = g_lot.getLotsByOwner(userRec.dbId)/>
    
    <cfset titles = arrayNew(1)/>
    <cfloop query="titleQ">
    	<cfif userRec.isFemale>
        	<cfset thisTitle = listLast(titleQ.title,"/")/>
        <cfelse>
        	<cfset thisTitle = listFirst(titleQ.title,"/")/>
        </cfif>
    	<cfset arrayAppend(titles, "#thisTitle# of #titleQ.locality#") />
	</cfloop>
    
    <cfset result['resultObject'] = structNew() />
    
    <cfset result.resultObject['screenName'] = userRec.screenName/>
    <cfset result.resultObject['dbId'] = userRec.dbId/>
    <cfset result.resultObject['isFemale'] = userRec.isFemale is not 0/>
    <cfset result.resultObject['lotsOwned'] = lotLocations.recordCount/>
    <cfset result.resultObject['score'] = lotLocations.recordCount*1000 + nItems*100 + nEvents*10  /><!---+ len(titles)[1]*10000--->
    <cfset result.resultObject['nobleTitles'] = titles/>
    <cfset result.resultObject['mapPoints'] = lotLocations/>
</cfif>

<!---<cfcatch type="any">
	<cfheader statuscode="400"/> <!---401=unauthorized--->
    <h1>Bad Request</h1>
    <cfabort/>
</cfcatch></cftry>--->

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<cfoutput>#PListUtil.structToPlistDict(result)#</cfoutput>
</plist>