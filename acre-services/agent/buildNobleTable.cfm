<cfset localTitles = arrayNew(1) />
<cfset localName = "" />
<cfset localCount = 1/>

<cfquery datasource="aa" name="rawCounts">
	TRUNCATE TABLE g_nobles
</cfquery>

<cfquery datasource="aa" name="rawCounts">
	SELECT locationName, ownerId, count(*) as count
    FROM g_lots
    GROUP BY locationName, ownerId
    HAVING count >= 3
    ORDER BY locationName, count DESC
</cfquery>

<cfloop query="rawCounts">
	<cfif rawCounts.locationName is not localName>
    	
        <cfif arrayLen(localTitles) gt 0 and localName is not "">
        	<cfquery datasource="aa">
            	INSERT INTO g_nobles
                (locality, userId, title)
                VALUES
                <cfloop from="1" to="#arrayLen(localTItles)#" index="i">
                	<cfif i is not 1>,</cfif>(
                    	<cfqueryparam value="#localName#"/>,
                        <cfqueryparam value="#localTitles[i]#"/>,
                        <cfqueryparam value="#i#"/>
                    )
                </cfloop>
            </cfquery>
        	<cfoutput>inserted #arrayLen(localTitles)# for #localName# <br/></cfoutput>
        </cfif>
    
    	<cfset arrayClear(localTitles)/>
        <cfset localName = rawCounts.locationName/>
        <cfset localCount = 1/>
    </cfif>
    <cfif localCount lte 3>
    	<cfset arrayPrepend(localTitles,rawCounts.ownerId)/>
        <cfset localCount = localCount + 1 />
    </cfif>
</cfloop>