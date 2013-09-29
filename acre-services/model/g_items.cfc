<cfcomponent output="false">
<cffunction name="getAllResourceTypes">
	<cfquery datasource="aa" name="list">
    	SELECT id as typeId, name as typeName, image
        FROM g_resources
    </cfquery>
    <cfreturn list/>
</cffunction>

<cffunction name="generateEmptyLotItem">
	<cfargument name="ci" />
    <cfargument name="cj" />
    
    <cfset var loc = structNew() />
    <cfset var result = structNew() />
    
    <cfquery name="loc.aLot" datasource="aa">
    	SELECT id FROM g_lots
        WHERE ci = <cfqueryparam value="#ci#"/>
        AND cj = <cfqueryparam value="#cj#"/>
    </cfquery>
    
    <cfif loc.aLot.recordCount is not 0>
    	<cfset result['success'] = false />
        <cfreturn result />
    </cfif>
    
    <cfset loc.rri = randRange(1,listLen(application.allowedRandomResources)) />
    <cfset result['createdResourceType'] = listGetAt(application.allowedRandomResources,loc.rri) />
    
    <cfset loc.creationResult = createItem(result.createdResourceType,1,ci,cj) />
    <cfset result['success'] = loc.creationResult.success />
    
    <cfreturn result/>
</cffunction>
    

<cffunction name="getItemRecord">
	<cfargument name="id"/>
    <cfset var result = structNew() />
    
    <cfquery name="result.q" datasource="aa">
    	SELECT * FROM g_items
        WHERE id = <cfqueryparam value="#id#"/>
    </cfquery>
    
    <cfreturn result.q />
</cffunction>

<cffunction name="executePayment">
	<cfargument name="amount" type="numeric"/>
	<cfargument name="userIdFrom"  required="no" default="0" type="numeric"/>
    <cfargument name="userIdTo"  required="no" default="0" type="numeric"/>
    <cfargument name="directItemsQuery" type="query" required="no"/>
    
    <cfset var loc = structNew() />
	<cfset var result = structNew()/>
    <cfset var fromId = 0/>
    <cfset var toId = 0/>
    
    <cfset result['success'] = false/>
    
    <cfif userIdFrom is userIdTo>
    	<cfset result['errorId'] = 25 />
        <cfset result['errorMessage'] = "Two distict users are required"/>
        <cfreturn result/>
    </cfif>
    
    <!--- find the money items --->
    <cfif not isDefined("directItemsQuery")>
        <cfquery name="loc.items" datasource="aa">
            SELECT id, typeId, ownerId, qty
            FROM g_items
            WHERE typeId = 1
            AND (
                ownerId = <cfqueryparam value="#userIdFrom#" />
                OR ownerId = <cfqueryparam value="#userIdTo#" />
            )
        </cfquery>
    <cfelse>
    	<cfset loc.items = directItemsQuery />
    </cfif>
    
    <cfif userIdFrom is not 0>
    	<cfquery dbtype="query" name="loc.fromItem">
			SELECT * FROM loc.items WHERE ownerId = <cfqueryparam value="#userIdFrom#" cfsqltype="cf_sql_integer"/>
            AND typeId = 1
		</cfquery>
        <cfset fromId = loc.fromItem.id/>
		<cfif loc.fromItem.qty lt amount>
            <cfset result['errorId'] = 26 />
            <cfset result['errorMessage'] = "Insufficient funds, user:#userIdFrom#, item:#fromId#, qty:#loc.fromItem.qty#
			less than #amount#."/>
            <cfreturn result/>
         </cfif>
    </cfif>
    
  
    <cfif userIdTo is not 0>
		<cfquery dbtype="query" name="loc.toItem">
			SELECT * FROM loc.items WHERE ownerId = <cfqueryparam value="#userIdTo#" cfsqltype="cf_sql_integer"/>
            AND typeId = 1
		</cfquery>
       	<cfset toId = loc.toItem.id/>
    </cfif>
        
	<!--- the actual transfer--->
    <cfquery name="trans" datasource="aa">
    	UPDATE g_items
        SET qty = CASE id 
        	WHEN <cfqueryparam value="#fromId#"/> THEN qty - <cfqueryparam value="#amount#"/> 
            ELSE qty + <cfqueryparam value="#amount#"/> 
        END
        WHERE id = <cfqueryparam value="#fromId#"/>
        OR id = <cfqueryparam value="#toId#"/>
    </cfquery>
    
    <cfif userIdFrom is 0 or userIdTo is 0>
    	<!--- special: creating or destroying item --->
        <cfquery name="updTot" datasource="aa">
            UPDATE g_resources
            <cfif fromId is 0>
                SET created = created + <cfqueryparam value="#amount#"/>
            <cfelse>
                SET destroyed = destroyed + <cfqueryparam value="#amount#"/>
            </cfif>
            WHERE id = 1
        </cfquery>
    </cfif>
    
    <cfinvoke component="g_user" method="logEvent" description="payment executed: $#amount#"
    	itemId_1="#fromId#" itemId_2="#toId#" userId="#userIdTo#"/>
    
    <cfset result['success'] = true/>
    <cfreturn result />
</cffunction>

<cffunction name="createItem">
	<cfargument name="typeId" />
    <cfargument name="qty" />
    <cfargument name="loc_i" />
    <cfargument name="loc_j" />
    <cfargument name="ownerId" required="no" default="" />
    <cfargument name="itemName" required="no" default="" />
    
    <cfset var result = structNew() />
    <cfset result['success'] = false/>
    
    <cfquery name="result.existingRaw" datasource="aa">
    	SELECT id, typeId
        FROM g_items
        WHERE loc_i = <cfqueryparam value="#loc_i#" />
        AND loc_j = <cfqueryparam value="#loc_j#" />
    </cfquery>
    
    <cfquery name="result.existing" dbtype="query">
    	SELECT *
        FROM result.existingRaw
        WHERE typeId = <cfqueryparam value="#typeId#" cfsqltype="cf_sql_integer"/>
    </cfquery>
    
    <cfif result.existing.recordCount is 0>
        <cfquery name="result.ins" datasource="aa" result="result.updRes">
            INSERT INTO g_items
            (typeId, qty, loc_i, loc_j, ownerId)
            VALUES(
                <cfqueryparam value="#typeId#" />,
                <cfqueryparam value="#qty#" />,
                <cfqueryparam value="#loc_i#" />,
                <cfqueryparam value="#loc_j#" />,
                <cfqueryparam value="#ownerId#" null="#ownerId is ''#" />
            )
        </cfquery>
      	<cfset result.recordId = result.updRes.GENERATED_KEY />
    <cfelse>
		<cfquery name="result.upd" datasource="aa">
            UPDATE g_items
            SET qty = qty + <cfqueryparam value="#qty#" />
            WHERE id = <cfqueryparam value="#result.existing.id#" />
    	</cfquery>
        <cfset result.recordId = result.existing.id />
    </cfif>
    
    <cfquery name="result.updCreated" datasource="aa">
        UPDATE g_resources
        SET created = created + <cfqueryparam value="#qty#"/>
        WHERE id = <cfqueryparam value="#typeId#" />
    </cfquery>
   
    <cfif itemName is not "">
        <cfinvoke component="g_user" method="logEvent" description="produced #qty# #itemName#" 
            itemId_1="#result.recordId#" userId="#ownerId#" loc_i="#loc_i#" loc_j="#loc_j#" exposed="1"/>
    <cfelse>    
    	<cfinvoke component="g_user" method="logEvent" description="dropped item on empty lot" 
    	itemId_1="#result.recordId#" loc_i="#loc_i#" loc_j="#loc_j#" exposed="0"/>
     </cfif>
     <cfset result['success'] = true/>   
    <cfreturn result />
</cffunction>

<cffunction name="destroyItem">
	<cfargument name="itemRec" />
    
    <cfset var result = structNew()/>
    <cfset var loc = structNew()/>
    
    <cfquery datasource="aa"  result="loc.resDestroy">
    	DELETE FROM g_items
        WHERE id = <cfqueryparam value="#itemRec.id#"/>
        AND qty = <cfqueryparam value="#itemRec.qty#" />
        AND typeId = <cfqueryparam value="#itemRec.typeId#" />
        AND ownerId = <cfqueryparam value="#itemRec.ownerId#" />
    </cfquery>
    
    <cfset result['success'] = loc.resDestroy.recordCount is 1 />
    
    <cfif result.success>
    	<cfquery name="result.updCreated" datasource="aa">
            UPDATE g_resources
            SET destroyed = destroyed + <cfqueryparam value="#itemRec.qty#"/>
            WHERE id = <cfqueryparam value="#itemRec.typeId#" />
        </cfquery>
    	<cfinvoke component="g_user" method="logEvent" description="item destroyed id:#itemRec.id# type:#itemRec.typeId# qty:#itemRec.qty#" 
    		itemId_1="#itemRec.id#" loc_i="#itemRec.loc_i#" loc_j="#itemRec.loc_j#"/>
    </cfif>
    
    <cfreturn result />
</cffunction>

<cffunction name="setLotItemQtyFromCarried">
	<cfargument name="resourceTypeId"type="numeric" />
    <cfargument name="lotQty" type="numeric"/>
    <cfargument name="loc_i" type="numeric"/>
    <cfargument name="loc_j" type="numeric" />
    <cfargument name="userId" type="numeric" />
    <cfargument name="directItemsQuery" type="query" required="no"/>
    
    <cfset var result = structNew()/>
    <cfset var loc = structNew() />
    
    <cfinvoke component="g_lot" method="getLotRecord" returnvariable="loc.lotRec"
    	ci="#loc_i#" cj="#loc_j#" />
        
    <cfif loc.lotRec.recordCount gt 0>
    	<cfset loc.newOwnerId = loc.lotRec.ownerId/>
    </cfif>
    
    <cfset result['success'] = false/>
   
    <cfif resourceTypeId is 1>
    	<cfset result['errorId'] = 27/>
        <cfset result['errorMessage'] = "can't move money into lot"/>
        <cfreturn result/>
    </cfif>
    
    <cfset result.resourceTypeId = resourceTypeId />
    
    <cfif not isDefined("directItemsQuery")>
        <cfquery datasource="aa" name="loc.items">
            SELECT *
            FROM g_items
            WHERE typeId = <cfqueryparam value="#resourceTypeId#"/>
            AND((
                loc_i = <cfqueryparam value="#loc_i#"/> 
                AND loc_j = <cfqueryparam value="#loc_j#"/>
           ) OR (
                loc_i = 162001
                AND ownerId = <cfqueryparam value="#userId#"/>
           ))
        </cfquery>
    <cfelse>
    	<cfset loc.items = directItemsQuery />
    </cfif>
    
    
    
    <cfquery dbtype="query" name="loc.carriedItem">
    	SELECT * FROM loc.items WHERE loc_i = 162001
        AND typeId = <cfqueryparam value="#resourceTypeId#" cfsqltype="cf_sql_integer"/>
    </cfquery>
    <cfquery dbtype="query" name="loc.lotItem">
    	SELECT * FROM loc.items WHERE loc_i <> 162001
        AND typeId = <cfqueryparam value="#resourceTypeId#" cfsqltype="cf_sql_integer"/>
    </cfquery>
    <cfquery dbtype="query" name="loc.itemSum">
    	SELECT sum(qty) as iSum FROM loc.items
        WHERE typeId = <cfqueryparam value="#resourceTypeId#" cfsqltype="cf_sql_integer"/>
    </cfquery>
    
    <cfif loc.lotItem.recordCount is not 0 and loc.lotItem.qty is lotQty>
    	<!---special: no change--->
    	<cfset result['success'] = true/>
        <cfreturn result/>
    </cfif>
   
    <cfif lotQty gt loc.itemSum.isum or lotQty lt 0 or loc.items.recordCount is 0>
    	<cfset result['errorId'] = 28/>
        <cfset result['errorMessage'] = "qty not allowed"/>
        <cfreturn result/>
    </cfif>
    
    <cfif ((loc.lotItem.recordCount + loc.carriedItem.recordCount) is 1)
		and (lotQty is 0 or lotQty is loc.itemSum.iSum)>
		<!---special: move location only--->
        <cfquery name="loc.simplemove" datasource="aa">
            UPDATE g_items
            SET 
            <cfif lotQty is 0>
                loc_i = 162001,
                loc_j = 0
            <cfelse>
                loc_i = <cfqueryparam value="#loc_i#"/>,
                loc_j = <cfqueryparam value="#loc_j#"/>
            </cfif>
            <cfif isDefined("loc.newOwnerId")>
            	, ownerId = <cfqueryparam value="#loc.newOwnerId#"/>
            <cfelseif lotQty is 0><!---removing all items from empty lot, finders keepers! --->
            	, ownerId = <cfqueryparam value="#userId#"/>
            </cfif>
            <cfif lotQty is 0>
            	WHERE id = <cfqueryparam value="#loc.lotItem.id#"/>
            <cfelse>
            	WHERE id = <cfqueryparam value="#loc.carriedItem.id#"/>
            </cfif>
            LIMIT 1
        </cfquery>
     <cfelse>
     	<!---insert or update lot item--->
     	<cfif loc.lotItem.recordCount is 0>
        	<cfquery name="loc.ins" datasource="aa" result="loc.insres">
				INSERT INTO g_items
				(typeId,loc_i,loc_j,qty
                <cfif isDefined("loc.newOwnerId")>
                	,ownerId
                </cfif>)
				VALUES(
					<cfqueryparam value="#resourceTypeId#"/>,
					<cfqueryparam value="#loc_i#"/>,
					<cfqueryparam value="#loc_j#"/>,
					<cfqueryparam value="#lotQty#"/>
                    <cfif isDefined("loc.newOwnerId")>
                        ,<cfqueryparam value="#loc.newOwnerId#"/>
                    </cfif>
				)
			</cfquery>
            <cfset result['newId'] = loc.insRes.GENERATED_KEY/>
        <cfelse>
        	<cfquery name="loc.upd" datasource="aa" result="loc.updres">
				UPDATE g_items
				SET qty = <cfqueryparam value="#lotQty#"/>
                WHERE loc_i = <cfqueryparam value="#loc_i#"/>
                AND loc_j = <cfqueryparam value="#loc_j#"/>
                AND typeId = <cfqueryparam value="#resourceTypeId#"/>
			</cfquery>
        </cfif>
        
        <!---insert or update carried item--->
        <cfif loc.carriedItem.recordCount is 0>
        	<cfquery name="loc.ins" datasource="aa" result="loc.insres">
				INSERT INTO g_items
				(typeId,loc_i,loc_j,ownerid,qty)
				VALUES(
					<cfqueryparam value="#resourceTypeId#"/>,
					<cfqueryparam value="#162001#"/>,
					<cfqueryparam value="#0#"/>,
                    <cfqueryparam value="#userId#"/>,
					<cfqueryparam value="#loc.itemSum.iSum - lotQty#"/>
				)
			</cfquery>
            <cfset result['newId'] = loc.insRes.GENERATED_KEY/>
        <cfelse>
        	<cfquery name="loc.upd" datasource="aa" result="loc.updres">
				UPDATE g_items
				SET qty = <cfqueryparam value="#loc.itemSum.iSum - lotQty#"/>
                WHERE loc_i = <cfqueryparam value="#162001#"/>
                AND ownerId = <cfqueryparam value="#userId#"/>
                AND typeId = <cfqueryparam value="#resourceTypeId#"/>
			</cfquery>
        </cfif>
     </cfif>
     
     <cfset result['success'] = true/>
     
     <cfinvoke component="g_user" method="logEvent" description="set item type:#resourceTypeId# to #lotQty#"
     		itemId_1="#loc.carriedItem.id#" itemId_2="#loc.lotItem.id#"
    		userId="#userId#" loc_i="#loc_i#"  loc_j="#loc_j#" notes="total count was #loc.itemSum.iSum#"/>
     
     <cfreturn result/>
</cffunction>

<cffunction name="getCarriedItems">
	<cfargument name="userId"/>
    <cfset var loc = structNew() />
    <cfquery name="loc.getRes" datasource="aa">
		SELECT id as dbId, typeId, qty
		FROM g_items 
		WHERE ownerId = <cfqueryparam value="#userId#"/>
		AND loc_i = 162001 
        AND qty <> 0
	</cfquery>
    <cfreturn loc.getRes/>
</cffunction>

<cffunction name="liquidateItem">
	<cfargument name="itemRec" />
    
    <cfset var loc = structNew()/>
    <cfset var result = structNew() />
    <cfset result['success'] = false />
    
    <cfif itemRec.typeId is 1>
    	<cfset result['errorId'] = 29 />
        <cfset result['errorMessage'] = "Can't liquidate money" />
        <cfreturn result/>
    </cfif>
    
    <cfquery datasource="aa" name="loc.destroy" result="loc.resDestroy">
    	DELETE FROM g_items
        WHERE id = <cfqueryparam value="#itemRec.id#"/>
        AND qty = <cfqueryparam value="#itemRec.qty#" />
        AND typeId = <cfqueryparam value="#itemRec.typeId#" />
        AND ownerId = <cfqueryparam value="#itemRec.ownerId#" />
    </cfquery>
    
    <cfif loc.resDestroy.recordCount is not 1>
    	<cfset result['errorId'] = 30 />
        <cfset result['errorMessage'] = "Item modified before it was destroyed" />
        <cfreturn result/>
    </cfif>
    
    <cfset result = executePayment(amount=itemRec.qty,userIdTo=itemRec.ownerId) />
     
    <cfif loc.resDestroy.recordCount is 1> 
        <cfquery name="updTot" datasource="aa">
            UPDATE g_resources
            SET destroyed = destroyed + <cfqueryparam value="#itemRec.qty#"/>
            WHERE id = <cfqueryparam value="#itemRec.typeId#" />
        </cfquery>
    </cfif>
   
    <cfif result.success>
        <cfinvoke component="g_user" method="logEvent" description="item liquidated:  typeId:#itemRec.typeId# qty:#itemRec.qty#" 
            itemId_1="#itemRec.id#" userId="#itemRec.ownerId#"/>
    </cfif>
        
    <cfreturn result />
    
</cffunction>

<cffunction name="getUserCarrySpace" returntype="numeric">
	<cfargument name="userId" />
    
    <cfset var loc = structNew()/>
    
    <cfquery name="loc.carryLimit" datasource="aa" >
    	SELECT carryLimit FROM g_users
        WHERE id = <cfqueryparam value="#userId#"/>
    </cfquery>
   
    <cfquery name="loc.carrySum" datasource="aa">
		SELECT ifNull(sum(qty),0) as sum
        FROM g_items 
		WHERE ownerId = <cfqueryparam value="#userId#"/>
		AND loc_i = 162001
        AND typeId <> 1
	</cfquery>
    
    <cfreturn loc.carryLimit.carryLimit - loc.carrySum.sum />
</cffunction>

<cffunction name="getLotSpace" returntype="numeric">
	<cfargument name="ci" />
    <cfargument name="cj" />
    <cfargument name="resourceType" required="no" default="-1" />
    <cfargument name="directLotRecord" required="no"/>
    
    <cfset var loc = structNew()/>
    
    <cfif isDefined("directLotRecord")>
    	<cfset loc.lotRec = directLotRecord />
    <cfelse>
        <cfinvoke component="g_lot" method="getLotRecord" 
            returnvariable="loc.lotRec" ci="#ci#" cj="#cj#"/>
    </cfif>
    
    <cfif loc.lotRec.recordCount is 0>
    	<cfset loc.lotRec = structNew() />
        <cfset loc.lotRec.itemLimit = 5 />
    </cfif>
    
    <cfquery name="loc.lotSum" datasource="aa">
		SELECT ifNull(sum(qty),0) as sum
        FROM g_items 
		WHERE loc_i = <cfqueryparam value="#ci#"/>
        AND loc_j = <cfqueryparam value="#cj#"/>
	</cfquery>
    
    <cfreturn loc.lotRec.itemLimit - loc.lotSum.sum />
</cffunction>


<cffunction name="getOfferByID" returntype="query">
	<cfargument name="id"/>
    <cfargument name="unfulfilledOnly" required="no" default="false"/>
	<cfquery name="get" datasource="aa">
		SELECT o.*, L.ci as loc_i, L.cj as loc_j, L.ownerId as lotOwnerId, dt.type as lotType
		FROM g_offers o
		LEFT JOIN g_lots L
        ON o.tradeLocationId = L.id
        LEFT JOIN g_devTypes dt
        ON L.devTypeId = dt.id
		WHERE o.id = <cfqueryparam value="#id#"/>
        <cfif unfulfilledOnly>
        	AND unfulfilled > 0
        </cfif>
	</cfquery>
	<cfreturn get/>
</cffunction>

<cffunction name="getOffersByUser" returntype="query">
	<cfargument name="userid"/>
	<cfargument name="activeonly" required="no" default="false"/>
	<cfquery name="result" datasource="aa">
		SELECT o.*, rw.name as resourcename_want, rh.name as resourcename_have
		FROM g_offers o
		LEFT JOIN g_resources rw
		ON o.itemWant_typeId = rw.id
		LEFT JOIN g_resources rh
		ON o.itemHave_typeId = rh.id
		WHERE userid = <cfqueryparam value="#userid#"/>
		<cfif activeonly>
			AND effectivedate <= <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_date"/>
			AND expires >= <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_date"/>
			AND isComplete = 0
		</cfif>
	</cfquery>
	<cfreturn result/>
</cffunction>

<cffunction name="insertOffers" returntype="struct">
	<cfargument name="insertRecords" type="array">
	<cfargument name="userId"/>
	<cfargument name="tradelocationid">
	
    <cfset var loc = structNew() />
    <cfset var allResourceIds = ""/>
    
	<cfset var result = structnew()/>
	<cfset result['success'] = false>
    
    <cfquery name="allResources" datasource="aa" cachedwithin="#createTimeSpan(0,1,0,0)#">
		SELECT id
		FROM g_resources
	</cfquery>
    
    <cfset allResourceIds = valueList(allResources.id)/>
    
    <!--- format: (1)tradeLocationId, (2)userId, (3)itemHave_typeId, (4)itemHave_qty, (5)itemWant_typeId, (6)itemWant_qty--->
    
    <cfloop index="i" from="1" to="#arrayLen(insertRecords)#">
    	<cfif listLen(insertRecords[i]) is not 6>
        	<cfset result['errorId'] = 31 />
        	<cfset result['errorMessage'] = "bad offer format" />
            <cfreturn result/>
        </cfif>
    	<cfif listGetAt(insertRecords[i],4) lt 0 or listGetAt(insertRecords[i],6) lt 0>
        	<cfset result['errorId'] = 32 />
        	<cfset result['errorMessage'] = "all quantities must be positive" />
            <cfreturn result/>
        </cfif>
    	<cfif listGetAt(insertRecords[i],3) is listGetAt(insertRecords[i],5)>
        	<cfset result['errorId'] = 33 />
        	<cfset result['errorMessage'] = "items must be distinct" />
            <cfreturn result/>
        </cfif>
        <cfif (listFind(allResourceIds,listGetAt(insertRecords[i],3)) is 0) or (listFind(allResourceIds,listGetAt(insertRecords[i],5)) is 0)>
        	<cfset result['errorId'] = 34 />
        	<cfset result['errorMessage'] = "invalid resource" />
            <cfreturn result/>
        </cfif>
    </cfloop>
    
    <cfquery datasource="aa" name="ins">
        INSERT INTO g_offers
        (tradeLocationId, userId, itemHave_typeId, itemHave_qty, itemWant_typeId, itemWant_qty)
        VALUES
            <cfloop index="i" from="1" to="#arrayLen(insertRecords)#">
                <cfif i is not 1>,</cfif>(<cfqueryparam value="#insertRecords[i]#" list="true"/>)
            </cfloop>
    </cfquery>
    
	<cfset result['success'] = true />
    <cfreturn result/>
</cffunction>

<cffunction name="getNUserItems">
	<cfargument name="userId"/>
    <cfset var loc = structNew()/>
    
    <cfquery datasource="aa" name="loc.countQ">
    	SELECT ifNull(sum(qty),0) as n
        FROM g_items
        WHERE ownerId = <cfqueryparam value="#userId#"/>
    </cfquery>

	<cfreturn loc.countQ.n/>
</cffunction>

<cffunction name="executeOffer" returntype="struct">
	<cfargument name="oRec" type="query"/>	
	<cfargument name="takerid" type="numeric"/>
		
	<cfset var result = structnew()/>
    <cfset var resultHave = structnew()/>
    <cfset var resultWant = structnew()/>
    <cfset var loc = structNew()/>
    
   
    <cfset result['success'] = false/>
    
    <cfquery datasource="aa" name="loc.items">
    	SELECT i.*, o.unfulfilled
        FROM g_offers o
        LEFT JOIN g_items i
        
        ON (												
        	(
            	i.typeId = o.itemWant_typeId OR
            	i.typeId = o.itemhave_typeId
            ) AND (
            	(											
                    i.loc_i = <cfqueryparam value="#oRec.loc_i#"/> AND
                    i.loc_j = <cfqueryparam value="#oRec.loc_j#"/>
                ) OR (										
                	i.ownerId = <cfqueryparam value="#takerId#"/> AND
            		i.loc_i = 162001
             	)
			)
        ) OR (												
        	i.typeId = 1 AND
            i.ownerId = o.userId AND
            i.loc_i = 162001
        )
    
        WHERE o.id = <cfqueryparam value="#oRec.id#"/>
    </cfquery>
    
    <cfquery dbtype="query" name="loc.paidItem">
    	SELECT * FROM loc.items
    	WHERE typeId = <cfqueryparam value="#oRec.itemWant_typeId#" cfsqltype="cf_sql_integer"/>
        AND ownerId = <cfqueryparam value="#takerId#" cfsqltype="cf_sql_integer"/>
    </cfquery>
    
    <cfquery dbtype="query" name="loc.offeredItem">
    	SELECT * FROM loc.items
    	WHERE typeId = <cfqueryparam value="#oRec.itemHave_typeId#" cfsqltype="cf_sql_integer"/>
        AND ownerId = <cfqueryparam value="#oRec.userId#" cfsqltype="cf_sql_integer"/>
    </cfquery>
    
    <cfquery dbtype="query" name="loc.itemForInboundMerge">
    	SELECT * FROM loc.items
    	WHERE loc_i <> 162001
        AND typeId = <cfqueryparam value="#oRec.itemWant_typeId#" cfsqltype="cf_sql_integer" />
    </cfquery>
  
  
  <!---<cfset result.debugallitemsofinterest = loc.items/>
  <cfset result.debugpaidItem = loc.paidItem/>
  <cfset result.debugofferedItem = loc.offeredItem/>
  <cfset result.debuginbound = loc.itemForInboundMerge/>--->
    
    <!---validation--->
    <cfif loc.items.unfulfilled lte 0 or dateCompare(oRec.effective,now()) is 1>
    	<cfset result['errorId'] = 35/>
        <cfset result['errorMessage'] = "Offer no longer available" />
        <cfreturn result/>
    </cfif>
    <cfif loc.paidItem.recordCount is 0 or loc.paidItem.qty lt oRec.itemWant_qty>
    	<cfset result['errorId'] = 36/>
        <cfset result['errorMessage'] = "Payment item insufficient" />
        <cfreturn result/>
    </cfif>
    <cfif loc.offeredItem.recordCount is 0 or loc.offeredItem.qty lt oRec.itemHave_qty>
    	<cfset result['errorId'] = 37/>
        <cfset result['errorMessage'] = "Lot can't fulfill offer" />
        <cfreturn result/>
    </cfif>
    <cfif oRec.itemhave_typeId is not 1 and getUserCarrySpace(takerId) lt oRec.itemHave_qty>
    	<cfset result['errorId'] = 38/>
        <cfset result['errorMessage'] = "Taker doesn't have enough carry space" />
        <cfreturn result/>
    </cfif>
    <cfif oRec.itemWant_typeId is not 1 and getLotSpace(oRec.loc_i, oRec.loc_j) lt oRec.itemWant_qty>
    	<cfset result['errorId'] = 39/>
        <cfset result['errorMessage'] = "Not enough space in lot" />
        <cfreturn result/>
    </cfif>
    
    <!---do it--->
    <cfif loc.itemForInboundMerge.recordCount gt 0>
    	<cfset loc.mergeQty = loc.itemForInboundMerge.qty/>
    <cfelse>
    	<cfset loc.mergeQty = 0/>
    </cfif> 
    <cfif loc.paidItem.typeId is 1> <!--- offerer wants money, taker pays ammount to offerer--->
    	<cfset resultWant = executePayment(oRec.itemWant_qty, takerId, oRec.userId, loc.items) />
    <cfelse><!---put items into lot--->
    	<cfset resultWant = setLotItemQtyFromCarried(loc.paidItem.typeId,loc.mergeQty+oRec.itemWant_qty,
			oRec.loc_i, oRec.loc_j, takerId, loc.items) />
    </cfif>
    
    <cfif loc.offeredItem.typeId is 1> <!--- offerer has money, taker pays ammount to offerer--->
    	<cfset resultHave = executePayment(oRec.itemHave_qty, oRec.userId, takerId, loc.items) />
    <cfelse><!---take items from lot--->
    	<cfset resultHave = setLotItemQtyFromCarried(loc.offeredItem.typeId, loc.offeredItem.qty-oRec.itemHave_qty, 
			oRec.loc_i, oRec.loc_j, takerId, loc.items) />
    </cfif>
    
	<cfset result['success'] = resultWant.success and resultHave.success/>
    <cfif result.success>
    	<cfquery name="loc.updQ" datasource="aa">
            UPDATE g_offers
            SET unfulfilled = unfulfilled - 1
            WHERE id = <cfqueryparam value="#oRec.id#"/>
        </cfquery>
        
        <cfinvoke component="g_user" method="logEvent" description="executed offer"
    		offerId="#oRec.id#" loc_i="#oRec.loc_i#"  loc_j="#oRec.loc_j#" userId="#takerId#"
            itemId_1="#loc.offeredItem.id#" itemId_2="#loc.paidItem.id#" exposed="1" />
            
        <cfif oRec.lotType is 'factory'>
        	<cfinvoke component="g_lot" method="getLotRecord" ci="#oRec.loc_i#" cj="#oRec.loc_j#" 
            	returnvariable="loc.lotRec"/>
    			
        	<cfset loc.factoryRun = tryFactoryProduction(loc.lotRec) />
            <cfloop condition="loc.factoryRun is not 0">
            	<cfset loc.factoryRun = tryFactoryProduction(loc.lotRec) />
            </cfloop>
        </cfif>
        
    <cfelse>
    	<cfset result['resultObject'] = structNew()/>
   		<cfif not resultWant.success>
        	<cfset result = resultWant />
        <cfelse>
        	<cfset result = resultHave />
        </cfif>
    </cfif>
    
	<cfreturn result/>
</cffunction>	

<cffunction name="tryFactoryProduction">
	<cfargument name="lotRec"/>
    
    <cfset var loc = structNew() />

<cfquery datasource="aa" name="loc.productionRuns">
    SELECT actionGroup, -i.qty/da.qty as runs, da.qty as qtyNeeded, 
    i.qty as qty, i.id as itemId, da.resourceId as typeId
    FROM g_devattributes da
    LEFT JOIN g_items i
    ON da.resourceId = i.typeId
    AND i.loc_i= <cfqueryparam value="#lotRec.ci#"/>
    AND i.loc_j = <cfqueryparam value="#lotRec.cj#"/>
    WHERE da.devTypeId = <cfqueryparam value="#lotRec.devTypeId#"/>
    AND da.type = 'product'
</cfquery>

<cfquery dbtype="query" name="loc.minMax">
	SELECT actionGroup, min(runs) minR
    FROM loc.productionRuns
    WHERE qtyNeeded < 0
    GROUP BY actionGroup
    HAVING minR >= 1
    ORDER BY actionGroup DESC
</cfquery>

<cfif loc.minMax.recordCount is not 0>
	<cfset loc.runCap = int(loc.minMax.minR)/>
    <cfset loc.thisAG = loc.minMax.actionGroup />
<cfelse>
	<cfset loc.runCap = 0/>
</cfif>

<cfif loc.runCap is 0>
	<cfreturn loc.runCap />
</cfif>

<cfquery dbtype="query" name="loc.thisGroup">
	SELECT *
    FROM loc.productionRuns
    WHERE actionGroup = <cfqueryparam value="#loc.thisAG#" cfsqltype="cf_sql_integer" />
    ORDER BY qtyNeeded
</cfquery>

<cfloop query="loc.thisGroup">
	<cfif loc.thisGroup.typeId is not 1> 
        <cfquery datasource="aa">
            UPDATE g_items
            SET qty = qty + <cfqueryparam value="#loc.runCap*loc.thisGroup.qtyNeeded#" cfsqltype="cf_sql_integer"/>
            WHERE id = <cfqueryparam value="#loc.thisGroup.itemId#" />
         </cfquery>
         
         <cfquery datasource="aa">
         	UPDATE g_resources
            <cfif loc.thisGroup.qtyNeeded lt 0>
            	SET destroyed = destroyed - <cfqueryparam value="#loc.runCap*loc.thisGroup.qtyNeeded#" cfsqltype="cf_sql_integer"/>
            <cfelse>
				SET destroyed = created + <cfqueryparam value="#loc.runCap*loc.thisGroup.qtyNeeded#" cfsqltype="cf_sql_integer"/>
            </cfif>
            WHERE id = <cfqueryparam value="#loc.thisGroup.typeId#" />
         </cfquery>
    <cfelse>
    	<cfset executePayment(loc.runCap*loc.thisGroup.qtyNeeded,0,lotRec.ownerId) />
    </cfif>
</cfloop>

<cfinvoke component="g_user" method="logEvent" description="Factory produced X#loc.runCap#" exposed="1"
    	loc_i="#lotRec.ci#" loc_j="#lotRec.cj#" />

<cfreturn loc.runCap />
       
</cffunction>
									

</cfcomponent>