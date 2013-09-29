<cfif not isDefinied('loc.userByEmail') >
	Can't use this outside of wrapper.
	<cfabort />
</cfif>

<cfmail to="#loc.userByEmail.email#" from="acre@ActinicApps.com" subject="You Requested a New Acre Password" type="html"><cfoutput>
	<p>Hello,</p>
    
    <p>Someone, (hopefully you) has requested a password change for the user: #loc.userByEmail.screenName#.
    If you wish to create a new password, follow the link below:</p>
    
    <p>
    <a href="http://actinicapps.com/acre-services/prfileMgr/passwordReset.cfm?verificationCode=#code#">
    	http://actinicapps.com/acre-services/prfileMgr/passwordReset.cfm?verificationCode=#code#
    </a>
    </p>
    
    <p>If you didn't request a new password. Please reply to this email and let us know about it.</p>
    
    <p>Thanks,<br/> The Acre Team</p>
    
</cfoutput></cfmail>