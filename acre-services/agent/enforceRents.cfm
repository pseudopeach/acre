
<cfset cutoffdate = dateAdd("d",-7,NOW()) />

<cfquery name="late" datasource="aa">
	SELECT *
	FROM g_lots sq
	WHERE sq.rentdue <= <cfqueryparam value="#cutoffdate#" cfsqltype="cf_sql_date"/>
</cfquery>

<cfoutput>
<cfloop query="late">
	<cfset currentLotId = late.id />
	<cfquery dbtype="query" name="lotRec">
    	SELECT * FROM late
        WHERE id = <cfqueryparam value="#late.id#" cfsqltype="cf_sql_bigint"/>
    </cfquery>
	<cfset result = g_lot.auctionLease(lotRec) />
    Lot #lotRec.id# - #lotRec.ci#, #lotRec.cj#
    <cfif structKeyExists(result.resultObject,"newOwner")>
    	New Owner:#result.resultObject.newOwner#
    <cfelse>
    	Razed
    </cfif>
    <br/>
</cfloop>
</cfoutput>
