<cfcomponent>
	<cffunction name="getAllDevelopments">
    	<cfquery name="devs" datasource="aa">
            SELECT *
            FROM g_devtypes 
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
            <key>typeName</key><string>#devs.type#</string>typeName name description image
            <key>name</key><string>#devs.name#</string>
            <key>description</key><string>#devs.description#</string>
            <key>image</key><string>#devs.id#</string>
           	<cfsilent>
            <cfquery dbtype="query" name="thisdev">
            	SELECT * FROM das WHERE devTypeId = <cfqueryparam value="#dev.id#"/>
            </cfquery>
            <cfquery dbtype="query" name="costs">
            	SELECT resourceTypeId as typeId, qty
                FROM thisdev 
                WHERE typeName = 'cost'
            </cfquery>
            <cfquery dbtype="query" name="inputs">
            	SELECT resourceTypeId as typeId, qty
                FROM thisdev  
                WHERE typeName = 'product'
                AND qty < 0
            </cfquery>
            <cfquery dbtype="query" name="outputs">
            	SELECT resourceTypeId as typeId, qty
                FROM thisdev  
                WHERE typeName = 'product'
                AND qty >= 0
            </cfquery>
            <cfquery dbtype="query" name="abilities">
            	SELECT label FROM thisdev 
                WHERE typeName = 'ability'
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
    </cffunction>
</cfcomponent>