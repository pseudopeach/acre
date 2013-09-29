<cfsilent><cfset input = FORM/>

<cfset validation = structNew() />
<cfset resultLotRec = structNew()/>
<cfset resultItems = structNew()/>
<cfset resultOffers = structNew()/>


<cfset validation['success'] = true/>
<cfset resultLotRec['success'] = true/>
<cfset resultItems['success'] = true/>
<cfset resultOffers['success'] = true/>

<cfif not isDefined("SESSION.isLoggedIn") or not SESSION.isLoggedIn>
	<cfheader statuscode="401"/>
    <cfset validation['success'] = false/>
    <cfset validation['errorId'] = 1/>
    <cfset validation['errorMessage'] = "not logged in" />
</cfif>

<cfif validation.success and (not isDefined("SESSION.lastLotLocation") or SESSION.lastLotLocation is not "#input.Ci#,#input.Cj#")>
    <cfset validation['errorId'] = 2/>
    <cfset validation['errorMessage'] = "wrong lot to edit" />
</cfif>

<cflock name="lot#input.ci#,#input.cj#" timeout="10">

<cfset lotRec = g_lot.getLotRecord(input.Ci,input.Cj)/>

<cfif validation.success and (lotRec.recordCount gt 0 and lotRec.ownerId is not SESSION.userId)>
    <cfset validation['errorId'] = 3/>
    <cfset validation['errorMessage'] = "user is not lot owner" />
</cfif>

<!--- passed security validation, changes allowed from here --->


<cfif validation.success>
	<!--- lot update --->
    <cfif lotRec.recordCount is not 0>
		<cfset resultLotRec = g_lot.setLotRecord(lotRec,input.devTypeId,SESSION.userId,input.name) />
        <cfset lotItemLimit = lotRec.itemLimit />
    <cfelse>
    	<cfset lotItemLimit = 5 />
    </cfif>

	<!---items--->
    
    <cfset requestedLotItemSum = 0/>
    
	<cfloop list="#itemQtyList#" index="i" delimiters=";">
    	<cfset thisResource = listFirst(i)/>
        <cfset thisQty = listLast(i)/>
        <cfset requestedLotItemSum = requestedLotItemSum + thisQty />
        <cfif requestedLotItemSum lte lotItemLimit>
    		<cfset resultItems1 = g_items.setLotItemQtyFromCarried(thisResource,thisQty,input.Ci,input.Cj,#SESSION.userId#)/>	
        <cfelse>
        	<cfset resultItems1['success'] = false />
        	<cfset resultItems1['errorId'] = 9/>
    		<cfset resultItems1['errorMessage'] = "item won't fit in lot" />
        </cfif>
        <cfif not resultItems1.success>
        	<cfset resultItems = resultItems1/>
        </cfif>
    </cfloop>
    
    <cfif lotRec.recordCount is not 0>
		<!---offers--->
        <cfset existingOfferIds = ""/>
        <cfset insertRecords = arrayNew(1)/>
        <cfloop list="#input.offerList#" index="i" delimiters=";">
            <cfset thisId = listFirst(i)/>
            <cfif isNumeric(thisId)>
                <cfif thisId is 0>
                    <cfset arrayAppend(insertRecords,'#lotRec.id#,#SESSION.userId#,'&listRest(i))/>
                <cfelse>
                    <cfset existingOfferIds = listAppend(existingOfferIds,thisId) />
                </cfif>
            </cfif>
        </cfloop>
        <cfset g_lot.deleteOffersNotInList(lotRec.id,existingOfferIds)/>
        
        <cfif arrayLen(insertRecords) is not 0>
            <cfset resultOffers = g_items.insertOffers(insertRecords,SESSION.userId,lotRec.dbId) />
        </cfif>
        
        <cfif lotRec.devTypeType is 'factory'>
        	<cfset factoryRun = g_items.tryFactoryProduction(lotRec) />
            <cfloop condition="factoryRun is not 0">
            	<cfset factoryRun = g_items.tryFactoryProduction(lotRec) />
            </cfloop>
        </cfif>
    </cfif>
    
</cfif>

</cflock>

<cfset result = structNew()/>
<cfif lotRec.recordCount is 0>
	<!--- empty lot--->
	<cfset result['success'] = validation.success and resultItems.success />
    <cfif not validation.success>
    	<cfset result = validation/>
    <cfelse>
    	<cfset result = resultItems/>
    </cfif>
<cfelse>
	<!--- registered lot--->
	<cfset result['success'] = validation.success and resultLotRec.success and resultItems.success and resultOffers.success />
    <cfif not result.success>
        <cfif not validation.success>
            <cfset result = validation/>
        <cfelse>
            <cfset result['errorId'] = 6/>
            <cfset result['errorMessage'] = "partial failure"/>
            <cfset result['resultObject'] = structNew()/>
            <cfset result.resultObject['resultLotRec'] = resultLotRec/>
            <cfset result.resultObject['resultItems'] = resultItems/>
            <cfset result.resultObject['resultOffers'] = resultOffers/>
        </cfif>
    </cfif>
</cfif>

</cfsilent>
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<cfoutput>#PListUtil.structToPListDict(result)#</cfoutput>
</plist>