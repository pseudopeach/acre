<cftry>
	<h3>Upkeep Enforcer</h3>
	<cfinclude template="/acre-services/agent/enforceRents.cfm" />
    <cfcatch type="any">
    	<cfmail to="pseudopeach@gmail.com" subject="Acre Agent Failure: Upkeep Enforcer" from="acre@actinicapps.com">
        	on lot id: #currentLotId#<br/>
        	<cfdump var="#cfcatch#" />
        </cfmail>
    </cfcatch>
</cftry>
<br/>
<cftry>
	<h3>Nobles</h3>
	<cfinclude template="/acre-services/agent/buildNobleTable.cfm" />
    <cfcatch type="any">
    	<cfmail to="pseudopeach@gmail.com" subject="Acre Agent Failure: Nobles" from="acre@actinicapps.com">
        	<cfdump var="#cfcatch#" />
        </cfmail>
    </cfcatch>
</cftry>
<br/>
<cftry>
	<h3>Anomalies</h3>
	<cfinclude template="/acre-services/agent/anomalies.cfm" />
    <cfcatch type="any">
    	<cfmail to="pseudopeach@gmail.com" subject="Acre Agent Failure: Anomalies" from="acre@actinicapps.com">
        	<cfdump var="#cfcatch#" />
        </cfmail>
    </cfcatch>
</cftry>

<cfset application.lastAgentRun = now() />

