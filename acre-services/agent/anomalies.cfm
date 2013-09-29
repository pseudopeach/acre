<cfif isDefined("application.lastAgentRun")>
	<cfset logBegin = application.lastAgentRun/>
<cfelse>
	<cfset logBegin = dateAdd('h',-12,now()) />
</cfif>

<cfquery datasource="aa" name="rLog">
	SELECT loc_i, loc_j
    FROM g_log
    WHERE timestamp > <cfqueryparam value="#logBegin#"  cfsqltype="cf_sql_timestamp"/>
    AND loc_i IS NOT NULL
    AND userId IS NOT NULL
</cfquery>


<cfloop query="rLog">
<cfset toCreateOrNot = randRange(1,5) />

<cfif toCreateOrNot is 2>
	<cfset i = rLog.loc_i />
    <cfset j = rLog.loc_j />
    
    <cfscript>
        a = 1;
        do{
            for(k=0;k lt 200;k=k+1){
                decider = randRange(0,3);
                switch(decider){
                    case 0:
                        i=i+1;
						break;
                    case 1:
                        i=i-1;
						break;
                    case 2:
                        j=j+1;
						break;
                    case 3:
                        j=j-1;
						break;
                }
            }
            result = g_items.generateEmptyLotItem(i,j);
        } while(not result.success);
        
    </cfscript>
    
    <cfoutput>
    created an #result.createdResourceType# at #rLog.loc_i#, #rLog.loc_j# 
    <br/>
    </cfoutput>

</cfif>
</cfloop>