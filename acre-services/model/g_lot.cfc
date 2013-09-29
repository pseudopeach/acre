<cfcomponent output="false">
	
  
<cffunction name="getSquaresByLocation" returntype="query">
	<cfargument name="Ci" />
	<cfargument name="Cj" />
  	<cfargument name="hashList" />
	<cfargument name="range" required="no" default="30"/>
    
    <cfset var loc = structNew() />

	<cfset jCoeff = -pi()/2*Cj/162000*sin(pi()/2/162000*Ci) />
	<cfquery name="loc.get" datasource="aa">
    	SELECT R.*
        FROM(
			SELECT l.name, l.devTypeId, l.ownerId, hex(500000*l.Ci+l.Cj) as hash
			FROM g_lots l
			WHERE l.Ci > <cfqueryparam value="#Ci-Range#" />
			AND l.Ci < <cfqueryparam value="#Ci+Range#" />
			AND l.Cj > 
        		<cfqueryparam value="#Cj-Range#" />+(Ci - <cfqueryparam value="#Ci#" />)*<cfqueryparam value="#jCoeff#" cfsqltype="cf_sql_float"/>
            AND l.Cj <         	
                <cfqueryparam value="#Cj+Range#" />+(Ci - <cfqueryparam value="#Ci#" />)*<cfqueryparam value="#jCoeff#" cfsqltype="cf_sql_float"/>
        ) R
        WHERE hash in (<cfqueryparam value="#hashList#" list="true"/>)
      	
        ORDER BY hash
	</cfquery>
  	
	<cfreturn loc.get />
	
</cffunction>

<cffunction name="getLotsByHouse">
	<cfargument name="userId"/>
    
    <cfset var loc = structNew() />
    
	<cfquery datasource="aa" name="loc.lots">
    	SELECT L.id as dbId, L.ci, L.cj, L.rentPrice, L.rentDue, L.locationName,
         L.devTypeId, dt.name as devTypeName, L.name,
         (CASE h.id WHEN L.id THEN 0 ELSE h.id END) as parentLotId
        FROM (
          SELECT Lh.*, da.qty
          FROM g_lots Lh
          LEFT JOIN g_devattributes da
          ON Lh.devTypeId = da.devTypeId
          WHERE da.resourceId = 0
          AND Lh.ownerId = <cfqueryparam value="#userId#"/>
        ) h
        LEFT JOIN
        g_lots L
        ON h.ownerId = L.ownerId
        AND (pow(L.Ci-h.Ci,2)+pow(L.Cj-h.Cj,2)) <= (h.qty*h.qty*626)
        LEFT JOIN g_devtypes dt
        ON L.devTypeId = dt.id
		GROUP BY L.id
    </cfquery>
    <cfreturn loc.lots/>
</cffunction>


<!---SELECT L.*, (CASE h.id WHEN L.id THEN 0 ELSE h.id END) as parentLotId, (pow(L.Ci-h.Ci,2)+pow(L.Cj-h.Cj,2)) as D, h.qty*h.qty*626 as maxD
        FROM (
          SELECT Lh.*, da.qty
          FROM g_lots Lh
          LEFT JOIN g_devattributes da
          ON Lh.devTypeId = da.devTypeId
          WHERE da.resourceId = 0
          AND Lh.ownerId = 1
        ) h
        LEFT JOIN
        g_lots L
        ON h.ownerId = L.ownerId
        AND (pow(L.Ci-h.Ci,2)+pow(L.Cj-h.Cj,2)) <= (h.qty*h.qty*626)
		GROUP BY L.id--->

<cffunction name="getLotsByOwner" returntype="query">
	<cfargument name="ownerid">
	
    <cfset var loc = structNew() />
    
	<cfquery datasource="aa" name="loc.result">
		SELECT
        ci*0.000555555556 as lat,
        90.0 / round(152594*cos(.00000969627362*Ci)) * Cj as lon
        FROM g_lots
		WHERE ownerid = <cfqueryparam value="#ownerid#"/>
	</cfquery>
	
	<cfreturn loc.result />
</cffunction>

<cffunction name="getLotRecord" returntype="query">
	<cfargument name="Ci" type="numeric"/>
	<cfargument name="Cj" type="numeric"/>
	
	<cfset var result = structNew() />

	<cfquery name="result.lotRec" datasource="aa">
    	SELECT L.*,  L.id as dbId, dt.name as devTypeName, dt.id as devTypeId, dt.type as devTypeType,
        dt.productionIndex, da.qty as itemLimit, daOff.qty as offerLimit, u.screenName as ownerName 
		FROM g_lots L
		LEFT JOIN g_devtypes dt
		ON L.devtypeid = dt.id
		LEFT JOIN g_devattributes da
		ON L.devTypeId = da.devTypeId
		AND da.type = 'ability'
        AND da.resourceId = -1
        LEFT JOIN g_devattributes daOff
		ON L.devTypeId = daOff.devTypeId
		AND daOff.type = 'ability'
        AND daOff.resourceId = -2
		LEFT JOIN g_users u
		ON L.ownerid = u.id
		WHERE Ci = <cfqueryparam value="#Ci#"/>
		AND Cj = <cfqueryparam value="#Cj#"/>
	</cfquery>
	
    <cfreturn result.lotRec/>
</cffunction>

<cffunction name="setOwner" returntype="void">
	<cfargument name="squareid"/>
	<cfargument name="newownerid"/>
	<cfargument name="wipe" required="no" default="true"/>
	
	<cfquery name="upd" datasource="aa">
		UPDATE g_lots
		SET ownerid = <cfqueryparam value="#newownerid#"/>
		<cfif wipe>,devtype = null</cfif>
		WHERE id = <cfqueryparam value="#userid#"/>
	</cfquery>
</cffunction>
	

<cffunction name="getQualifiedRentBids" returntype="query">
	<cfargument name="lotId"/>
    <cfset var loc = structNew() />
	
	<cfquery name="loc.offers" datasource="aa">
		SELECT o.id as offerId, o.userid as bidderId, o.itemHave_qty as offer
        FROM g_offers o
        INNER JOIN g_items i
        ON o.userId = i.ownerId
        AND o.itemHave_typeId = i.typeId
        AND i.qty >= o.itemHave_qty*2
        WHERE itemWant_typeId = 0
        AND tradeLocationId = <cfqueryparam value="#lotId#"/>
        AND o.unfulfilled > 0
        ORDER BY offer DESC
	</cfquery>
	
	<cfreturn loc.offers/>
</cffunction>


<cffunction name="auctionLease" returntype="struct">
	<cfargument name="lotRec" />
	
    <cfset var result = structNew() />
	<cfset var offerRec = getQualifiedRentBids(lotRec.id)/>
    
    <cfset result['resultObject'] = structNew() />
    
    <cfif lotRec.recordCount is 0>
    	<cfset result['success'] = false />
        <cfreturn result/>
    </cfif>
    
    <cfinvoke component="g_user" method="logEvent" description="Lot upkeep expired"
    		 loc_i="#lotRec.ci#"  loc_j="#lotRec.cj#" />
	
	<cfif offerRec.recordCount is not 0>
    	<!--- update ownership and due date --->
		<cfset payUpkeep(lotRec,offerRec.bidderId,2,offerRec.offer) />
		
        <!--- assign ownership of items --->
        <cfquery datasource="aa">
        	UPDATE g_items
            SET ownerId = <cfqueryparam value="#offerRec.bidderId#" />
            WHERE loc_i = <cfqueryparam value="#lotRec.ci#" />
            AND loc_j = <cfqueryparam value="#lotRec.cj#" />
        </cfquery>
		
		<cfquery datasource="aa">
			UPDATE g_offers
			SET unfulfilled = 0
			WHERE id = <cfqueryparam value="#offerRec.offerId#"/>
		</cfquery>
        <cfset result.resultObject['newOwner'] = offerRec.bidderId />
        <cfset result.resultObject['newRent'] = offerRec.offer />
	<cfelse>
		<cfset razeLot(lotRec.id,lotRec.ci,lotRec.cj) />
	</cfif>
	
	<cfset result['success'] = true />
	<cfreturn result/>
</cffunction>

<cffunction name="razeLot">
	<cfargument name="id" />
    <cfargument name="ci" />
    <cfargument name="cj" />
    
    <cfset var loc = structNew() />
    
    <cfquery datasource="aa" name="loc.inv">
		SELECT *
		FROM g_items i
		WHERE i.loc_i = <cfqueryparam value="#ci#"/>
        AND i.loc_j = <cfqueryparam value="#cj#"/>
        AND qty <> 0
	</cfquery> 
    
    <cfloop query="loc.inv">
    	<cfquery dbtype="query" name="loc.thisItem">
        	SELECT * FROM loc.inv WHERE id = <cfqueryparam value="#loc.inv.id#" cfsqltype="cf_sql_integer"/>
        </cfquery>
    	<cfinvoke component="g_items" method="destroyItem" itemRec="#loc.thisItem#" />
    </cfloop>
    
    <cfquery datasource="aa" result="loc.del">
    	DELETE FROM g_lots
        WHERE id = <cfqueryparam value="#id#"/>
        AND ci = <cfqueryparam value="#ci#"/>
        AND cj = <cfqueryparam value="#cj#"/>
    </cfquery>
   
   <cfif loc.del.recordCount is 1>
   		<cfinvoke component="g_user" method="logEvent" description="Lot razed id:#id#"
    		 loc_i="#ci#"  loc_j="#cj#" />
   </cfif> 
</cffunction>	

<cffunction name="getOffers" returntype="query">
	<cfargument name="squareid"/>
	<cfargument name="qualifiedOnly" required="no" default="false"/>
	<cfargument name="activeOnly" required="no" default="true">
	
	<cfset var result = structnew()/>
	
	<cfquery name="result.offers" datasource="aa">
		SELECT o.*,  
		(i.id is not null) as qualified
		FROM g_offers o
		LEFT JOIN g_lots sq
		ON o.tradelocationid = sq.id
		
		LEFT JOIN g_items i
		ON o.itemHave_typeId = i.typeId -- where the has the stuff
		AND o.userid = i.ownerid -- and owns it
		AND i.qty >= o.itemHave_qty
		AND 
		((o.itemHave_typeId > 1 -- either on site or its money
		AND i.loc_i = sq.Ci
		AND i.loc_j = sq.Cj)
		OR (o.itemHave_typeId = 1
		AND i.loc_i = 162001))
		
		WHERE tradelocationid = <cfqueryparam value="#squareid#"/>
		AND itemWant_typeId > 0 -- not rent offers
        <cfif qualifiedOnly>AND i.id is not null</cfif>
        <cfif activeOnly>AND o.unfulfilled > 0</cfif>
	</cfquery>
	
	<cfreturn result.offers/>
</cffunction>

<cffunction name="deleteOffersNotInList">
	<cfargument name="lotId"/>
	<cfargument name="offerIds"/>
    
    <cfquery datasource="aa" name="del">
    	DELETE FROM g_offers 
        WHERE tradeLocationId = <cfqueryparam value="#lotId#"/>
        AND itemWant_typeId <> 0
        AND id not in (<cfqueryparam value="#offerIds#" list="true"/>)
    </cfquery>
    
</cffunction>

<cffunction name="setLocationName">
	<cfargument name="lotRec" />
    <cfargument name="city" />
    
    <cfset var result = structNew()/>
    <cfif lotRec.locationName is not "">
    	<cfset result['success'] = false/>
        <cfset result['errorId'] = 56/>
        <cfset result['errorMessage'] = "Location already set" />
        <cfreturn result />
    </cfif>
    
    <cfquery datasource="aa">
    	UPDATE g_lots
        SET locationName = <cfqueryparam value="#city#"/>
        WHERE id = <cfqueryparam value="#lotRec.id#"/>
    </cfquery>
    
    <cfset result['success'] = true/>
        
    <cfreturn result />  
</cffunction>

<cffunction name="setLotRecord">
	<cfargument name="lotRec" type="query"/>
    <cfargument name="devTypeId" type="numeric"/>
    <cfargument name="userId" type="numeric"/>
    <cfargument name="name" />
    
    <cfset var result = structNew()/>
    <cfset var loc = structNew() />
    <cfset result['success'] = true/>
    
    <cfif len(name) gt 15>
    	<cfset name = left(name,12)&"..."/>
    </cfif>
    
     <!--- *** this could be cut down to only be farm --->
    <cfset loc.rWeightsSet = calcResourceWeights(lotRec) />
    
   	<cfif lotRec.devTypeId is devTypeId>
    	<cfquery datasource="aa" name="upd3">
            UPDATE g_lots
            SET name = <cfqueryparam value="#name#"/>,
            isWater = <cfqueryparam value="#loc.rWeightsSet is 0#" cfsqltype="cf_sql_tinyint" />
            WHERE id = <cfqueryparam value="#lotRec.id#"/>
        </cfquery>
    	<cfset result['success'] = true/>
        <cfreturn result/>
    </cfif>
    
  
    <cfquery datasource="aa" name="loc.citems">
        SELECT da.resourceId, da.qty as requiredQty, i.id as itemId, i.qty
        FROM g_devtypes dt
        LEFT JOIN g_devattributes da 
        ON dt.id = da.devTypeId
        LEFT JOIN g_items i
        ON da.resourceId = i.typeId
        AND ((
       		i.loc_i = 162001
        	AND i.ownerId = <cfqueryparam value="#userId#"/>
        ) OR (
        	i.loc_i = <cfqueryparam value="#lotRec.ci#"/>
        	AND i.loc_j = <cfqueryparam value="#lotRec.cj#"/>
        ))
        
        WHERE devTypeId = <cfqueryparam value="#devTypeId#"/>
        AND da.type = 'cost'
        
        ORDER BY da.resourceId, i.loc_i
	</cfquery>
   
     
     <!---<cfset result.citemsdebug  = citems/>--->
     
    <cfquery dbtype="query" name="loc.cgitems">
    	SELECT resourceId, min(requiredQty) as requiredQty, sum(qty) as qty
        FROM loc.citems
        GROUP BY resourceId 
    </cfquery>
    
    <cfloop query="loc.cgitems">
    	<cfset result['success'] = result.success and (loc.cgitems.requiredQty lte loc.cgitems.qty) />
    </cfloop>
    
    <cfif not result.success>
    	<cfset result['errorId'] = 51/>
        <cfset result['errorMessage'] = "insufficient resources"/>
        <cfreturn result/>
    </cfif>
    
    <cfset loc.lastResourceId = 0 />
    <cfset loc.leftQty = 0 />
    <cfset loc.qtyToSet = 0/>
    <cfloop query="loc.citems">
        
        <!---if this is a new item type, set the requiredQty--->
     	<cfif loc.lastResourceId is not loc.citems.resourceId>  
        	<cfset loc.leftQty = loc.citems.requiredQty/>
        </cfif>
          
        <!---if there's there's more left than this item has, zero it out, otherwise 0 out leftQty--->
        <cfif loc.leftQty gt loc.citems.qty>
        	<cfset loc.qtyToSet = 0/>
            <cfset loc.leftQty = loc.leftQty - loc.citems.qty />
        <cfelse>
        	<cfset loc.qtyToSet = loc.citems.qty - loc.leftQty/>
            <cfset loc.leftQty = 0/>
        </cfif>
        
        <cfif loc.qtyToSet is not loc.citems.qty>
        	<cfquery datasource="aa">
            	UPDATE g_items
                SET qty = <cfqueryparam value="#loc.qtyToSet#"/>
                WHERE id = <cfqueryparam value="#loc.citems.itemId#"/>
             </cfquery>
             <cfquery datasource="aa">
            	UPDATE g_resources
                SET destroyed = destroyed + <cfqueryparam value="#loc.citems.qty - loc.qtyToSet#"/>
                WHERE id = <cfqueryparam value="#loc.citems.resourceId#"/>
             </cfquery>
        </cfif>
        
        <cfset loc.lastResourceId = loc.citems.resourceId/>
        
    </cfloop>
    
    <cfquery datasource="aa">
    	UPDATE g_lots
        SET devTypeId = <cfqueryparam value="#devTypeId#"/>,
        name = <cfqueryparam value="#name#"/>
        WHERE id = <cfqueryparam value="#lotRec.id#"/>
    </cfquery>
    
    <cfinvoke component="g_user" method="logEvent" description="changed lot development to #devTypeId#"
    		 loc_i="#lotRec.ci#"  loc_j="#lotRec.cj#" />
    
    <cfreturn result />
    
</cffunction>

<cffunction name="getInventory" returntype="query">
	<cfargument name="ci"/>
    <cfargument name="cj"/>
    
    <cfset var loc = structNew() />
	
	<cfquery datasource="aa" name="loc.inv">
		SELECT id as dbId, typeId, qty
		FROM g_items i
		WHERE i.loc_i = <cfqueryparam value="#ci#"/>
        AND i.loc_j = <cfqueryparam value="#cj#"/>
        AND qty <> 0
	</cfquery>
	
	<cfreturn loc.inv/>
</cffunction>

<cffunction name="payUpkeep" returntype="struct">
	<cfargument name="lotRec" type="query"/>
	<cfargument name="userid"/>
    <cfargument name="weeks" required="no" type="numeric" default="1" />
    <cfargument name="newPrice" required="no" type="numeric" default="0" />
	
	<cfset var result = structnew()/>
    <cfset var loc = structnew()/>
    
    <cfset result['success'] = false />
    
	
	<cfquery name="loc.rentQ" datasource="aa">
		SELECT rentprice, rentdue
		FROM g_lots
		WHERE id = <cfqueryparam value="#lotRec.id#"/>
	</cfquery>
    
    <cfif dateDiff("h", now(), loc.rentQ.rentDue) gt 168>
    	<cfset result['errorId'] = 52 />
		<cfset result['errorMessage'] = 'upkeep not due' />
        <cfreturn result />
    </cfif>
    
    <cfinvoke component="g_items" method="executePayment" returnvariable="result"
    	amount="#loc.rentQ.rentprice*weeks#" userIdFrom="#userId#"/>
    
    <cfif not result.success>
    	<cfreturn result/>
    </cfif>
	<cfset result['resultObject'] = structNew() />
    <cfset result.resultObject['newDueDate'] = dateAdd("s",604800*weeks,loc.rentQ.rentdue) />
    
    <cfquery name="loc.upd" datasource="aa" result="loc.updRes">
        UPDATE g_lots
        SET rentdue = <cfqueryparam value="#result.resultObject.newDueDate#" cfsqltype="cf_sql_timestamp" />,
        ownerId = <cfqueryparam value="#userId#"/>
        <cfif newPrice is not 0>
        	,rentPrice = <cfqueryparam value="#newPrice#" />
        </cfif>
        WHERE ci = <cfqueryparam value="#lotRec.ci#"/>
        AND cj = <cfqueryparam value="#lotRec.cj#"/>
    </cfquery>

    <cfif loc.updRes.recordCount is 0>
        <cfset result['errorId'] = 53 />
        <cfset result['errorMessage'] = "Disaster! Paid without date update" />
    </cfif>
    
    <cfset result['success'] = true/>
	<cfreturn result />
</cffunction>

<cffunction name="claimLot" returntype="struct">
	<cfargument name="ci"/>
    <cfargument name="cj"/>
	<cfargument name="userid" type="numeric"/>
    <cfargument name="name" />
    <cfargument name="weeks" required="no" type="numeric" default="1" />
    <cfargument name="rentPrice" required="no" type="numeric" default="15" />
    <cfargument name="devTypeId" required="no" type="numeric" default="1" />
	
	<cfset var result = structnew()/>
    <cfset var loc = structnew()/>
    <cfset var newLotStruct = structNew() />
    
    <cfset result['success'] = false />
    
    <cfinvoke component="g_items" method="executePayment" returnvariable="result"
    	amount="#rentprice*weeks#" userIdFrom="#userId#"/>
        
    <cfif not result.success>
    	<cfreturn result />
    </cfif>
    
	<cfset result['resultObject'] = structNew() />
	<cfset result.resultObject['newDueDate'] = dateAdd("s",604800*weeks,now()) />
    
   	<!---<cfif lotRec.devTypeId is devTypeId>
    	<cfquery datasource="aa" name="upd3">
            UPDATE g_lots
            SET name = <cfqueryparam value="#name#"/>,
            isWater = <cfqueryparam value="#loc.rWeightsSet is 0#" />
            WHERE id = <cfqueryparam value="#lotRec.id#"/>
        </cfquery>
    	<cfset result['success'] = true/>
        <cfreturn result/>
    </cfif>--->
    
    <cfquery name="loc.res" datasource="aa" result="loc.lotInsertRes">
        INSERT INTO g_lots
        (ci, cj, name, ownerId, devTypeId, rentDue, rentPrice, timer)
        VALUES(
            <cfqueryparam value="#ci#"/>,
            <cfqueryparam value="#cj#"/>,
            <cfqueryparam value="#name#"/>,
            <cfqueryparam value="#userId#" />,
            <cfqueryparam value="#devTypeId#" />,
            <cfqueryparam value="#result.resultObject.newDueDate#" cfsqltype="cf_sql_timestamp" />,
            <cfqueryparam value="#rentPrice#"/>,
            <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp" />
        )
    </cfquery>
    
    <cfset newLotStruct.ci = ci />
    <cfset newLotStruct.cj = cj />
    <cfset newLotStruct.id = loc.lotInsertRes.GENERATED_KEY />
    <cfset loc.rWeightsSet = calcResourceWeights(newLotStruct) />
    <cfif loc.rWeightsSet is 0>
    	<cfquery datasource="aa">
        	UPDATE g_lots
            SET isWater = 1
            WHERE id = <cfqueryparam value="#loc.lotInsertRes.GENERATED_KEY#" />
        </cfquery>
    </cfif>
    
    <cfquery datasource="aa">
    	UPDATE g_items
        SET ownerId = <cfqueryparam value="#userId#" />
        WHERE loc_i = <cfqueryparam value="#ci#"/>
        AND loc_j = <cfqueryparam value="#cj#"/>
    </cfquery>
	
	<cfset result.resultObject['newLotId'] = loc.lotInsertRes.GENERATED_KEY/>
    
    <cfinvoke component="g_user" method="logEvent" description="Lot claimed"
    		 loc_i="#ci#"  loc_j="#cj#" userId="#userId#" />
    
    <cfset result['success'] = true/>
	<cfreturn result />
</cffunction>

<cffunction name="getRecentLogItems" returntype="query">
	<cfargument name="lotRec" />
    
    <cfset var loc = structNew() />
   
	<cfquery datasource="aa" name="loc.items">
    	SELECT lg.description, lg.userid, u.screenName as userScreenName, 
        	lg.timestamp, i.typeId as itemTypeId
        FROM g_log lg
        LEFT JOIN g_users u
        ON lg.userId = u.id
        LEFT JOIN g_items i
        ON lg.itemId_1 = i.id
        WHERE lg.loc_i = <cfqueryparam value="#lotRec.ci#" />
        AND lg.loc_j = <cfqueryparam value="#lotRec.cj#" />
        AND lg.timestamp >= <cfqueryparam value="#lotRec.timer#" cfsqltype="cf_sql_date"/>
        AND lg.exposed = 1
        ORDER BY lg.timestamp DESC
    </cfquery>
    
    <cfreturn loc.items/>
</cffunction>

<cffunction name="getAddressByCoord">
	<cfargument name="lat"/>
    <cfargument name="lon"/>
    	
    <cfset var result = structNew()/>
	
    <cfset result['Ci'] = ceiling(25.815/0.000555555556) - 1/>
	<cfset result['Cj'] = ceiling( -80.281/(90.0 / round(152594*cos(.00000969627362*Ci)))) - 1/>
    
    <cfreturn result/>
</cffunction>

<cffunction name="bidLot">
	<cfargument name="lotRec" />
    <cfargument name="bid" />
    <cfargument name="userId" />
    
    <cfset var loc = structNew()/>
    <cfset var result = structNew() />
    
    <cfif bid is 0>
    	<cfquery name="loc.clearBid" datasource="aa">
        	UPDATE g_offers
            SET unfulfilled = 0
            WHERE tradeLocationId = <cfqueryparam value="#lotRec.id#"/>
            AND itemWant_typeId = 0
            AND userId = <cfqueryparam value="#userId#" />
        </cfquery>
        <cfset result['success'] = true />
        <cfreturn result />
    </cfif>
    
    <cfset result['success'] = false />
    
    <cfquery name="loc.moneyItem" datasource="aa">
    	SELECT qty
        FROM g_items
        WHERE typeId = 1
        AND ownerId = <cfqueryparam value="#userId#" />
    </cfquery>
    
    <cfif loc.moneyItem.qty lt bid>
    	<cfset result['errorId'] = 54 />
        <cfset result['errorMessage'] = "Insufficient funds" />
        <cfreturn result />
    </cfif>
    
    <cfset loc.existingBids = getQualifiedRentBids(lotRec.id) />
    <cfif loc.existingBids.recordCount is 0>
    	<cfset loc.minimumBid = lotRec.rentPrice + 1/>
    <cfelse>
        <cfset loc.minimumBid = loc.existingBids.offer + 1 />
    </cfif>
    
    <cfif bid is not 0 and bid lt loc.minimumBid>
    	<cfset result['errorId'] = 55 />
        <cfset result['errorMessage'] = "Bid must be higher than existing high bid #loc.minimumBid# lotRec.id #lotRec.id#" />
        <cfreturn result />
    </cfif>
    
    <cfquery dbtype="query" name="loc.bidsThisUser">
    	SELECT * FROM loc.existingBids
        WHERE bidderId = <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer" />
    </cfquery>
    
    <cfif loc.bidsThisUser.recordCount is 0>
        <cfquery name="loc.ins" datasource="aa">
            INSERT INTO g_offers
            (tradeLocationId, userId, itemHave_typeId, itemHave_qty, itemWant_typeId, itemWant_qty)
            VALUES (
                <cfqueryparam value="#lotRec.id#" />,
                <cfqueryparam value="#userId#" />,
                <cfqueryparam value="#1#" />,
                <cfqueryparam value="#bid#" />,
                <cfqueryparam value="#0#" />,
                <cfqueryparam value="#1#" />
            )
        </cfquery>
    <cfelse>
    	<cfquery name="loc.upd" datasource="aa">
            UPDATE g_offers
            SET itemHave_qty = <cfqueryparam value="#bid#"/>,
            effective = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
            WHERE id = <cfqueryparam value="#loc.bidsThisUser.offerId#"/>
        </cfquery>
    </cfif>
    
    <cfset result['resultObject'] = structNew() />
    <cfset result.resultObject['newBid'] = bid />

	<cfset result['success'] = true/>
    <cfreturn result/>
</cffunction>

<cffunction name="calcResourceWeights" returntype="numeric">
	<cfargument name="lotRec" />
    	
    <cfset var result = structNew()/>
    <cfset var loc = structNew() />
    <cfset var borders = getLotBorders(lotRec.ci,lotRec.cj)/>
    
    <cfset var lat = (borders.bottomLat+borders.topLat)/2 />
    <cfset var lon = (borders.leftLon+borders.rightLon)/2 />
    
    <cfinvoke component="UDF" method="projectWinkel" lat="#lat#" lon="#lon#" returnvariable="loc.projection" />
    <cfset loc.mapX = round((loc.projection.x+.5)*2048) />
    <cfset loc.mapY = round((-loc.projection.y+.5)*1252) />
    
    <cfquery name="loc.resq" datasource="aa">
    	SELECT * FROM g_resources
        WHERE mapFileName is not NULL
        ORDER BY mapFileName
    </cfquery>
    
    <cfquery datasource="aa">
    	DELETE from g_resources_production
        WHERE lotId = <cfqueryparam value="#lotRec.id#" />
        AND persist = 0
    </cfquery>
    
    <cfset loc.file = "" />
    <cfset result.links = arrayNew(1) />
   
    <cfloop query="loc.resq">
    	<cfif loc.file is not loc.resq.mapFileName>
        	<cfinvoke component="UDF" method="getPixelColor" imageName="#loc.resq.mapFileName#"
            	x="#loc.mapX#" y="#loc.mapY#" returnvariable="loc.pixel" />
			<cfset loc.file = loc.resq.mapFileName />
        </cfif>
        <cfif loc.pixel[loc.resq.mapChannel] is not 0>
        	<cfset arrayAppend(result.links,"#lotRec.id#,#loc.resq.id#,#loc.pixel[loc.resq.mapChannel]#") />
        </cfif>
    </cfloop>
    
    <cfif arrayLen(result.links) is not 0>
    <cfquery datasource="aa" >
        INSERT INTO g_resources_production
        (lotId, resourceId, weight)
        VALUES
            <cfloop index="i" from="1" to="#arrayLen(result.links)#">
                <cfif i is not 1>,</cfif>(<cfqueryparam value="#result.links[i]#" list="true"/>)
            </cfloop>
    </cfquery>
    </cfif>
    
    <cfreturn arrayLen(result.links) />
</cffunction>

<cffunction name="doProduction">
	<cfargument name="lotRec" type="query"/>
    
    <!---<cfset var loc = structNew() />--->
    <cfset var result = structNew() />
    
    <cfset var i = 1/>
    <cfset var j = 1 />
    <cfset var cumu = 0 />
    
    <cfset var seedItems = .00018*dateDiff("s",lotRec.timer,NOW())*lotRec.productionIndex/>
    <cfset var nItems = seedItems />
    
    <cfset result.m = 1/>
    <!---<cfloop index="result.m" from="1" to="25">
    	<cfset nItems = nItems + (rand()-.5)*seedItems*.2/lotRec.productionIndex />
    </cfloop>--->
    
    <cfif nItems lt 0>
    	<cfset nItems = 0 />
    </cfif>
    
    <cfset result.rawQty = lotRec.productionRemainder + nItems />
    <cfset result.newItemCount = int(result.rawQty)/>
    <cfset result.newRemainder = result.rawQty - result.newItemCount /> 
    
  	<cfif result.newItemCount is 0>
    	<cfset result['newItemsCreated'] = 0 />
        <cfreturn result />
    <cfelse>
    	<cfset result['newItemsCreated'] = result.newItemCount />
    </cfif>
    
    <cfinvoke component="g_items" method="getLotSpace" returnvariable="result.lotSpace" ci="#lotRec.ci#" cj="#lotRec.cj#"
    	directLotRecord="#lotRec#" />
       
    <cfif result.lotSpace lt result.newItemCount>
    	<cfset result.newItemCount = result.lotSpace />
    </cfif>
    
	<cfset i = 1 />
    <cfset j = 1 />
    <cfset cumu = 0 />
    <cfquery name="result.allPossible" datasource="aa">
        SELECT r.id, r.name, rp.weight, ifNull(rp.weight/255,r.rarity) as composit, 0 as cumulative
        FROM g_resources r
        LEFT JOIN g_resources_production rp
        ON r.id = rp.resourceId
        AND rp.lotId = <cfqueryparam value="#lotRec.id#" />
    </cfquery>
     
    <cfquery name="result.wsum" dbtype="query">
        SELECT sum(composit) as sum1 FROM result.allPossible
    </cfquery>
     
    <cfset result.rands = arrayNew(1) />
     
    <cfset result.m = 1/>
    <cfloop from="1" to="#result.newItemCount#" index="result.m">
        <cfset result.rands[result.m] = rand()*result.wsum.sum1 />
    </cfloop>
     
    <cfset arraySort(result.rands,"numeric") />
     
    <cfloop condition="j lte result.newItemCount"> <!--- till all items created --->
        <cfset cumu = cumu + result.allPossible["composit"][i] />
        <cfset loc.thisItemQty = 0 />
        <cfloop condition="j lte result.newItemCount and cumu gte result.rands[j]">  <!--- till next item type --->
        	<cfset loc.thisItemQty = loc.thisItemQty + 1 />
            <cfset j = j + 1 />
        </cfloop>
        <cfif loc.thisItemQty gt 0>
            <cfinvoke component="g_items" method="createItem" typeId="#result.allPossible['id'][i]#" qty="#loc.thisItemQty#"
                loc_i="#lotRec.ci#" loc_j="#lotRec.cj#" ownerId="#lotRec.ownerId#" itemName="#result.allPossible['name'][i]#" />
        </cfif>
        <cfset i = i + 1 />
    </cfloop>
    
    <cfquery datasource="aa"><!---***loc--->
    	UPDATE g_lots
        SET productionRemainder = <cfqueryparam value="#result.newRemainder#" cfsqltype="cf_sql_float" />,
        timer = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
        WHERE ci =  <cfqueryparam value="#lotRec.ci#" />
        AND cj =  <cfqueryparam value="#lotRec.cj#" />
    </cfquery>
    
    <cfreturn result/>
</cffunction>

<cffunction name="getLotBorders">
	<cfargument name="Ci" type="numeric"/>
    <cfargument name="Cj" type="numeric"/>
    	
    <cfset var result = structNew()/>
    <cfset var latCoeff = .000555555556/>
    <cfset var lonCoeff = 90.0 / round(152594*cos(.00000969627362*Ci)) />
	<cfset result['bottomLat'] = latCoeff*Ci />
    <cfset result['topLat'] = result.bottomLat + latCoeff />
    <cfset result['leftLon'] = lonCoeff*Cj/>
    <cfset result['rightLon'] = result.leftLon + lonCoeff/>
	<cfset result['Cj'] = ceiling( -80.281/(90.0 / round(152594*cos(.00000969627362*Ci )))) - 1/>
    
    <cfreturn result/>
</cffunction>


</cfcomponent>