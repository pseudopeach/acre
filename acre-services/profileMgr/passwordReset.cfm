<style>
	body, table td {
		font-family: Verdana, Arial, sans-serif;
		}
	body{#74c1da; background:#74c1da url(/acre-services/resourceMaps/sky_02.jpg) center no-repeat}
	table td {padding:30px 0px;}
	input {font-size:18px}
	.error{color:#ff0000;}
</style>
<body>
<div style="width:455px;border:#d0d0d0 2px solid;padding:10px;margin:auto;background:#ffffff">
<h2>Reset Acre Password</h2>
<cfif isDefined('URL.verificationCode')>
	<cfset uRec = g_user.checkVeriCode(URL.verificationCode) /> 
</cfif>
<cfoutput>
<cfif not isDefined('URL.verificationCode') or uRec.recordCount is 0>
	<cfif not isDefined('FORM.submitted') or not isDefined("SESSION.lastCaptcha") or FORM.captchaAnser is not SESSION.lastCaptcha>
    	<cfif isDefined("FORM.submitted")>
        	<p class="error">That wos not the right word. Please try again.</p>
        </cfif>
        <form action="#CGI.SCRIPT_NAME#" method="post"/>
        <h3>Enter Email</h3>
        <p>To reset your Acre password, enter the email address you used to register your acre screen name.</p>
        <table><tr>
            <td style="width:170px">Email:</td><td> <input type="text" name="email"  style="width:280px" /> </td>
        
        </tr><tr>
        <td colspan="2"><cfset UDF.printCaptcha() /></td>
        </tr><tr>
        	<td style="width:170px">Type the word above:</td><td> <input name="captchaAnser" type="text"  style="width:280px"  /></td>
        </tr></table><br/>
        <input type="submit" name="submitted" value="Submit"/>
        
        
    <cfelse>
    	<h3>Thanks</h3>
        <p>If this email address is registered, an email with a code allowing you to change your password will be sent.</p>
        <cfset g_user.requestUnlockEmail(FORM.email) />
    </cfif>
<cfelse>
	<cfif not isDefined('FORM.submitted') and (FORM.password is FORM.confirm) >
    	<cfif isDefined('FORM.submitted')>
        	<p class="error">Passwords did not match.</p>
        </cfif>
        <form action="#CGI.SCRIPT_NAME#" method="post">
        <h3>Enter a New Password</h3>
        <table><tr>
        <td>New Password:</td><td><input type="password" name="password" /></td>
        </tr><tr>
        <td>Confirm:</td><td><input type="password" name="confirm" /></td>
        </tr></table><br/>
        <input type="submit" name="submitted" value="Submit" />
        </form>
	<cfelse>
    	<cfset g_user.setPassword(uRec.id,FORM.password)/>
    	<h3>Your password has been changed.</h3>
    </cfif>
</cfif>
</cfoutput>

</div>

</body>