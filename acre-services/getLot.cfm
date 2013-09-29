<!---<cfsilent>---><cfif not isDefined("FORM.ci")>
	<cfset input = URL/>
<cfelse>
	<cfset input = FORM/>
</cfif>
<cfset result = structNew()/>
<cfset result['success'] = true/>
<cfif not isDefined("SESSION.isLoggedIn") or not SESSION.isLoggedIn>
	<cfheader statuscode="401"/>
	<cfset result['success'] = false/>
    <cfset result['errorId'] = 1/>
    <cfset result['errorMessage'] = "not logged in" />
</cfif>
<cfset borders = g_lot.getLotBorders(Ci,Cj)/>
<cfif result.success and not isDefined("SESSION.checkin_lat")>
	<cfset result['success'] = false/>
    <cfset result['errorId'] = 2/>
    <cfset result['errorMessage'] = "user location not set" />
</cfif>
<cfif result.success and UDF.calcDistance(borders.bottomLat,borders.leftLon,SESSION.checkin_lat,SESSION.checkin_lon) gt 1.05>
	<cfset result['success'] = false/>
    <cfset result['errorId'] = 3/>
    <cfset result['errorMessage'] = "lot out of range,  lat:#borders.bottomLat#, lon:#borders.leftLon#,  #UDF.calcDistance(borders.bottomLat,borders.leftLon,SESSION.checkin_lat,SESSION.checkin_lon)#" />
</cfif>




<!---<cftry>--->
<cfif result.success>

	<cfset lotRec = g_lot.getLotRecord(input.Ci,input.Cj)/>
   
    <cfif lotRec.recordCount is not 0 and lotRec.productionIndex is not 0>
    	<cfset resultProduction = g_lot.doProduction(lotRec) />
    </cfif>
  
    <cfset itemsQ = g_lot.getInventory(input.Ci,input.Cj)/>
    
    <cfif lotRec.recordCount is not 0>
    	<cfset bids = g_lot.getQualifiedRentBids(lotRec.id) />
		<cfset bidInfo = structNew() />
        <cfquery name="userBid" dbtype="query">
            SELECT * FROM bids WHERE bidderId = <cfqueryparam value="#SESSION.userId#" cfsqltype="cf_sql_integer"/>
        </cfquery>
        <cfif userBid.recordCount is not 0>
            <cfset bidInfo['rentPrice'] = userBid.offer/>
        </cfif>
        <cfif bids.recordCount is 0>
            <cfset bidInfo['rentBid'] = lotRec.rentPrice/>
        <cfelse>
            <cfset bidInfo['rentBid'] = bids.offer/>
        </cfif>
        
        <cfif lotRec.devTypeType is 'factory' or lotRec.devTypeType is 'store' or lotRec.ownerId is SESSION.userId>
            <cfset offersQ = g_lot.getOffers(lotRec.id,(lotRec.ownerId is not SESSION.userId))/>
        </cfif>
        <cfif lotRec.ownerId is SESSION.userId>
           <cfset historyQ = g_lot.getRecentLogItems(lotRec)/>
           <cfset bidInfo['rentPrice'] = lotRec.rentPrice />
        <cfelse>
        	
        </cfif>
    </cfif>
	<cfset SESSION.lastLotLocation = "#Ci#,#Cj#"/>
</cfif>

<!---<cfif lotRec.RecordCount is not 0>
		<cfset result['dbId'] = lotRec.id/>
        <cfset result['rentPrice'] = lotRec
        
        <cfset result['rentBid'] = getQualifiedRentBids(result.id,true).offer/>
		<cfset result['offers'] = getOffers(result.id)/>
	</cfif>
	
	
	
	<cfset result['items'] = getInventory(Ci,Cj)/>	
	<cfset result.success = true/>
	<cfreturn result />--->
    
<!---</cfsilent><cfcatch type="any">
	<cfheader statuscode="400"/> <!---401=unauthorized--->
    <h1>Bad Request</h1>
    <cfabort/>
</cfcatch></cftry>--->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">

<cfif result.success>
<dict>
<key>success</key><true/>
<key>resultObject</key>
<dict>

<cfif lotRec.recordCount is not 0>
	<cfoutput>#PListUtil.queryLineToDictItems(lotRec,
        	"dbId,ci,cj,name,ownerId,devTypeId,rentDue,devTypeName,devTypeType,itemLimit,offerLimit,ownerName,locationName")#
			#PListUtil.structToPlistDict(bidInfo,true)#</cfoutput>
	<cfif lotRec.devTypeType is 'factory' or lotRec.devTypeType is 'store' or lotRec.ownerId is SESSION.userId>

<cfoutput><key>offers</key>
<array><cfloop query="offersQ">
<dict>
    <key>dbId</key>
    <integer>#offersQ.id#</integer>
    <key>haveItem</key>
    <dict>
        <key>typeId</key>
        <integer>#offersQ.itemHave_typeId#</integer>
        <key>qty</key>
        <integer>#offersQ.itemHave_qty#</integer>
    </dict>
    <key>wantItem</key>
    <dict>
        <key>typeId</key>
        <integer>#offersQ.itemWant_typeId#</integer>
        <key>qty</key>
        <integer>#offersQ.itemWant_qty#</integer>
    </dict>
    <key>unfulfilled</key>
    <integer>#offersQ.unfulfilled#</integer>
</dict>
</cfloop>
</array>
</cfoutput>
	</cfif>
    <cfset bidQ = g_lot.getQualifiedRentBids(lotRec.id,true)/><cfif bidQ.recordCount is not 0>
        <key>rentBid</key><integer><cfoutput>#bidQ.offer#</cfoutput></integer>
    </cfif>
    <cfif lotRec.ownerId is SESSION.userId>
        <key>lotHistory</key>
        <cfoutput>#PListUtil.queryToDictArray(historyQ)#</cfoutput>
    </cfif>
<cfelse>
	<key>ci</key><integer><cfoutput>#input.Ci#</cfoutput></integer>
    <key>cj</key><integer><cfoutput>#input.Cj#</cfoutput></integer>
</cfif>

<cfif lotRec.recordCount is 0 or lotRec.ownerId is SESSION.userId> <!---owned by user or empty--->
	<key>itemsPresent</key>
    <cfoutput>#PListUtil.queryToDictArray(itemsQ)#</cfoutput>
</cfif>
<cfif lotRec.recordCount is 0>
	<key>itemLimit</key><integer>5</integer>
</cfif>




</dict><!---end resultObject--->
</dict><!---end ServerResponse--->
<cfelse>
	<cfoutput>#PListUtil.structToPListDict(result)#</cfoutput>
</cfif>
</plist>