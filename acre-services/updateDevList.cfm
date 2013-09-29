<cfquery name="devs" datasource="aa">
    SELECT dt.*
    FROM g_devtypes dt
    INNER JOIN g_devattributes da
    ON dt.id = da.devTypeId
    AND da.type = 'cost'
    AND da.resourceId = 1
    ORDER BY da.qty
</cfquery>
<cfquery name="das" datasource="aa">
    SELECT * 
    FROM g_devattributes 
</cfquery>

<cfsavecontent variable="result"><cfoutput>
<array>
<cfset thisId = 0/>
<cfloop query="devs">
    <dict>
    <key>dbId</key><integer>#devs.id#</integer>
    <key>typeName</key><string>#devs.type#</string>
    <key>name</key><string>#devs.name#</string>
    <key>description</key><string>#devs.description#</string>
    <key>image</key><string>#devs.id#</string>
    <cfsilent>
    <cfquery dbtype="query" name="thisdev">
        SELECT * FROM das WHERE devTypeId = <cfqueryparam value="#devs.id#" cfsqltype="cf_sql_integer"/>
    </cfquery>
    <cfquery dbtype="query" name="costs">
        SELECT resourceId as typeId, qty
        FROM thisdev 
        WHERE type = 'cost'
    </cfquery>
    <cfquery dbtype="query" name="inputs">
        SELECT resourceId as typeId, qty, actionGroup
        FROM thisdev  
        WHERE type = 'product'
        AND qty < 0
    </cfquery>
    <cfquery dbtype="query" name="outputs">
        SELECT resourceId as typeId, qty, actionGroup
        FROM thisdev  
        WHERE type = 'product'
        AND qty >= 0
    </cfquery>
    <cfquery dbtype="query" name="abilities">
        SELECT label FROM thisdev 
        WHERE type = 'ability'
    </cfquery>
    </cfsilent>
    <key>input</key>
    #PListUtil.queryToDictArray(inputs)#
    <key>output</key>
    #PListUtil.queryToDictArray(outputs)#
    <key>cost</key>
    #PListUtil.queryToDictArray(costs)#
    <key>abilities</key>
    <array>
        <cfloop query="abilities"><string>#abilities.label#</string>
        </cfloop>
    </array>
    </dict>
</cfloop>
</array>
</cfoutput></cfsavecontent>
<cfset path = expandPath('/acre-services')/>
<cffile action="write" file="#path#/allDevelopments.xml" output="#result#"/>
<h2>Done.</h2>