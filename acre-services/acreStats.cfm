<cfquery datasource="aa" name="userQ">
	SELECT * FROM g_users
    ORDER BY lastCheckin DESC
</cfquery>

<cfquery datasource="aa" name="lotQ">
	SELECT count(*) as c FROM g_lots
</cfquery>

<cfquery datasource="aa" name="logQ">
	SELECT count(*) as c FROM g_log
    WHERE description not like 'dropped%'
</cfquery>

<cfquery datasource="aa" name="logRecent">
	SELECT * FROM g_log
    ORDER BY timestamp DESC
    LIMIT 100
</cfquery>

<cfquery dbtype="query" name="userCount">
	SELECT count(id) as c FROM userQ
</cfquery>

<cfquery dbtype="query" name="recentUserLocations">
	SELECT checkin_lat, checkin_lon
    FROM userQ
    WHERE lastCheckin >= <cfqueryparam value="#dateAdd('h',-24,now())#" cfsqltype="cf_sql_timestamp" />
</cfquery>

<cfoutput>
<h3>There are #userCount.c# users</h3>
<h4>Last login #dateFormat(userQ.lastCheckin,"d/m/yyyy")#, #dateDiff("n",userQ.lastCheckin,now())# minutes ago</h4>

<h3>Lots: #lotQ.c#</h3>
<h3>Log: #logQ.c#</h3>

<h4>Last activity #dateDiff("n",logRecent.timestamp,now())# minutes ago</h4>
</cfoutput>

<cfset theImage = imageRead(expandPath('/acre-services/resourceMaps/smallWorld.png')) />
<cfset imageSetAntialiasing(theImage,"on") />
<cfset imageSetDrawingColor(theImage,"00FFFF")/>

<cfset imageSetDrawingTransparency(theImage,50)/>

<cfloop query="recentUserLocations">
	<cfset point = UDF.projectWinkel(recentUserLocations.checkin_lat,recentUserLocations.checkin_lon) />
    <cfset mapX = (point.x+.5)*500 />
    <cfset mapY = (-point.y+.5)*306 />
    <cfset imageDrawOval(theImage,mapX-2,mapY-2,4,4,"yes")>
</cfloop>
<h3>Logins Last 24 Hours</h3>
<cfimage action="writeToBrowser" source="#theImage#" />