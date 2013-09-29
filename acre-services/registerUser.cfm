<cfsilent>
<cfset input = FORM/>
<cfparam name="input.email" default=""/>

<cfinvoke component="model.g_user" method="commitUser" returnvariable="result">
	<cfinvokeargument name="email" value="#input.email#"/>
    <cfinvokeargument name="screenName" value="#input.screenName#"/>
    <cfinvokeargument name="password" value="#input.password#"/>
    <cfinvokeargument name="isFemale" value="#input.isFemale#"/>
</cfinvoke>

</cfsilent><!---<cfcatch type="any">
	<cfheader statuscode="400"/> <!---401=unauthorized--->
    <h1>Bad Request</h1>
    <cfabort/>
</cfcatch></cftry>--->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<cfoutput>#PListUtil.structToPListDict(result)#</cfoutput>
</plist>
