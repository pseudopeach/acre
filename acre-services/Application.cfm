<cfsilent>
<cfapplication name="AcreServices" sessionmanagement="yes" sessiontimeout="#createTimeSpan(0,1,1,0)#"/>
<cfif not isDefined("application.PListUtil") or isDefined("URL.reinit")>
	<cfset application.PListUtil = createObject("component","model.PListUtil")/>
</cfif>
<cfset PListUtil = application.PListUtil />
<cfif not isDefined("application.g_user") or isDefined("URL.reinit")>
	<cfset application.g_user = createObject("component","model.g_user")/>
</cfif>
<cfset g_user = application.g_user />
<cfif not isDefined("application.g_items") or isDefined("URL.reinit")>
	<cfset application.g_items = createObject("component","model.g_items")/>
</cfif>  
<cfset g_items = application.g_items />

<cfif not isDefined("application.g_lot") or isDefined("URL.reinit")>
	<cfset application.g_lot = createObject("component","model.g_lot")/>
</cfif>  
<cfset g_lot = application.g_lot />

<cfif not isDefined("application.UDF") or isDefined("URL.reinit")>
	<cfset application.UDF = createObject("component","model.UDF")/>
</cfif>
<cfset UDF = application.UDF />

</cfsilent>