
<cfcomponent displayname="basic commit functions">
	<cffunction access="public" name="checkLogin" output="false" returntype="query">
		<cfargument name="login" type="string"/>
		<cfargument name="password" type="string"/>
		<cfset var hash = hashPassword(password)/>
		<cfquery name="userRecord" datasource="aa">
				SELECT *
				FROM g_users
				WHERE screenname = <cfqueryparam value="#login#"/>
				AND password = <cfqueryparam value="#hash#"/>
                AND isDisabled = 0
		</cfquery>
		<cfreturn userRecord/>
	</cffunction>
	

	<cffunction access="public" name="relogin" output="false" returntype="query">
		<cfif isDefined("SESSION.isloggedin")>
			<cfset id = SESSION.userid/>
		<cfelse>
			<cfset id = 0/>
		</cfif>
		<cfquery name="uRec" datasource="aa">
			SELECT *
			FROM g_users
			WHERE id = <cfqueryparam value="#id#"/>
		</cfquery>
	</cffunction>
	
	<cffunction access="public" name="hashPassword" output="false" returntype="string">
		<cfargument name="password" type="string"/>
		<cfloop from="1" to="3294" index="i">
			<cfset password = hash(password&"ghgh_noFatebWwM"&i&"KUAHLIfh	no")/>
		</cfloop>
		<cfreturn password/>
	</cffunction>
	
	<cffunction access="public" name="processLogin" output="false" returntype="void">
		<cfargument name="URec" type="query"/>
		<cfset SESSION['isLoggedIn'] = true/>
		<cfset SESSION['userId'] = URec.id/>
		<cfset SESSION['screenName'] = URec.screenname/>
		<cfset SESSION['userType'] = URec.usertype>
		<cfset SESSION['email'] = URec.email/>
	</cffunction>
	
	<cffunction access="public" name="logout" output="false" returntype="void">
		<cfset structDelete(SESSION,"isLoggedIn")/>
		<cfset structDelete(SESSION,"userType")/>
		<cfset structDelete(SESSION,"userId")/>
        <cfset structDelete(SESSION,"email")/>
        <cfset structDelete(SESSION,"screenName")/>
        <cfset structDelete(SESSION,"foo")/>
		<cfset structDelete(SESSION,"checkin_lat")/>
		<cfset structDelete(SESSION,"checkin_lon")/>
	</cffunction>
	
	<cffunction name="verifyEmail" access="public" output="false" returntype="boolean">
		<cfargument name="code"/>
		<cfquery name="check" datasource="aa">
			SELECT id
			FROM g_users
			WHERE id = <cfqueryparam value="#SESSION.userid#"/>
			AND verificationcode = <cfqueryparam value="#code#"/>
		</cfquery>
		<cfif check.RecordCount is 1>
			<cfquery name="verify" datasource="aa">
				UPDATE g_users
				SET 
				emailverified = 1,
				verificationcode = ''
				WHERE id = <cfqueryparam value="#check.id#"/>
				LIMIT 1
			</cfquery>
			<cfreturn true/>
		<cfelse>
			<cfreturn false/>
		</cfif>
	</cffunction>

<cffunction name="updateUserLocation" access="public" returntype="struct" output="false">
    <cfargument name="lat" type="numeric"/>
    <cfargument name="lon" type="numeric"/>
    <cfargument name="userId" />
    
    <cfset var result = structNew()/>
    
    <cfset result['success'] = false/>
    
    <cfif abs(lat) gt 90 or abs(lon) gt 180>
        <cfset result['errorId'] = 2/>
        <cfset result['errorMessage'] = "invalid location">
        <cfreturn result/>
    </cfif>
    
    <cfquery name="lastCheckin" datasource="aa">
        SELECT lastCheckin, checkin_lat as lat, checkin_lon as lon
        FROM g_users
        WHERE id = <cfqueryparam value="#userid#"/>
    </cfquery>
    
    <cfif lastCheckin.lat is not "">
    
        <cfinvoke component="UDF" method="calcDistance" returnvariable="D">
            <cfinvokeargument name="lat1" value="#lat#"/>
            <cfinvokeargument name="lat2" value="#lastCheckin.lat#"/>
            <cfinvokeargument name="lon1" value="#lon#"/>
            <cfinvokeargument name="lon2" value="#lastCheckin.lon#"/>
        </cfinvoke>
        
        <cfset t = datediff("s",lastCheckin.lastcheckin,NOW())/3600   />
        <cfif t is not 0>
			<cfif D gt 10 and ( D/t gt 700 or (D/t gt 100 and D lt 250))>
                <cfset result['errorId'] = 3/>
                <cfset result['errorMessage'] = "impossible check-in pattern" />
                <cfreturn result/>
            </cfif>
        </cfif>
    </cfif>
    
    <cfquery name="ins" datasource="aa">
        UPDATE g_users
        SET lastcheckin = <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp"/>,
        checkin_lat = <cfqueryparam value="#lat#"/>,
        checkin_lon = <cfqueryparam value="#lon#"/>
        WHERE id = <cfqueryparam value="#SESSION.userid#">
    </cfquery>
    
    <cfset SESSION.checkin_lat = lat/>
    <cfset SESSION.checkin_lon = lon/>
  
    <cfset result['success'] = true />
    <cfreturn result />
</cffunction>
    
	
<cffunction name="requestUnlockEmail" access="public" output="false">
	<cfargument name="email"/>
	
	<cfset var code = CreateUUID()/>
    <cfset var loc = structNew() />
	
	<cfquery datasource="aa" name="loc.userByEmail">
    	SELECT id, screenName, email
        FROM g_users
        WHERE email = <cfqueryparam value="#email#" />
    </cfquery>
    
    <cfif loc.userByEmail.recordCount is 1>
    	<cfquery datasource="aa">
        	UPDATE g_users
            SET verificationcode = <cfqueryparam value="#code#" />
            WHERE userId = <cfqueryparam value="#userId#"/>
        </cfquery>
    	<cfinclude template="/acre-services/emails/pwResetCode.cfm"/>
	</cfif>
</cffunction>

<cffunction name="checkVeriCode">
	<cfargument name="code" />
    <cfset var result = structNew() />
    
    <cfquery datasource="aa" name="result.uRec">
    	SELECT id, screenName
        FROM g_users
        WHERE verificationcode = <cfqueryparam value="#code#" />
        AND verificationcode is not null
    </cfquery>
    
    <cfreturn result.uRec />
</cffunction>

<cffunction name="setPassword">
	<cfargument name="userId" />
	<cfargument name="newPassword"/>
    
    <cfquery datasource="aa">
    	UPDATE g_users
        SET password = <cfqueryparam value="#hashPassword(newPassword)#" />,
        verificationcode = <cfqueryparam null="yes" />
        WHERE userId = <cfqueryparam value="#userId#"/>
    </cfquery>
</cffunction>

<cffunction name="getUserByID" returntype="query" output="false" access="public">
	<cfargument name="ID" required="yes"/>
	<cfquery name="get" datasource="aa">
		SELECT *
		FROM g_users
		WHERE id = <cfqueryparam value="#ID#"/>
	</cfquery>
	<cfreturn get/>
</cffunction>

<cffunction name="getUserByScreenname" returntype="query" output="false" access="public">
	<cfargument name="screenname" required="yes"/>
	<cfquery name="get" datasource="aa">
		SELECT id as dbid, screenName, isFemale
		FROM g_users
		WHERE screenname = <cfqueryparam value="#screenname#"/>
	</cfquery>
	<cfreturn get/>
</cffunction>

<cffunction name="getUserByEmail" returntype="query" output="false" access="public">
	<cfargument name="screenname" required="yes"/>
	<cfquery name="get" datasource="aa">
		SELECT *
		FROM g_users
		WHERE email = <cfqueryparam value="#screenname#"/>
        AND email <> ''
	</cfquery>
	<cfreturn get/>
</cffunction>

<cffunction name="deleteUserByEmail" returntype="void" output="false" access="public">
	<cfargument name="email" required="yes"/>
	<cfquery name="del" datasource="aa">
		DELETE FROM g_users
		WHERE email = <cfqueryparam value="#email#"/>
		LIMIT 1
	</cfquery>
</cffunction>
<cffunction name="commitUser" returntype="struct" output="false" access="public">
	<cfargument name="email" required="yes"/>
	<cfargument name="screenname" required="no" default=""/>
	<cfargument name="password" required="no"/>
    <cfargument name="isFemale" />
	<cfargument name="userId" required="no" default="0"/>
	
	<cfset var result = structNew()/>
    <cfset var testUn1 = getUserByScreenname(screenname)/>
	<cfset var testUn2 = getUserByEmail(email) />
    <cfset result['success'] = false/>	
    
    <cfset temp = rereplace(screenName,"\W","") />
	<cfif temp is not screenName>
        <cfset result['errorId'] = 4/>
        <cfset result['errorMessage'] = "Screen names can only have letters and numbers"/>
        <cfreturn result/>
	</cfif>
    <cfif password is not "" and not refind("(?=.*[a-z])(?=.*[A-Z])",password)>
		<cfset result['errorId'] = 5/>
        <cfset result['errorMessage'] = "Password must have lower and uppercase letters."/>
        <cfreturn result/>
	</cfif>
    <cfif len(password) lt 8 and (userId is 0 or password is not "")>
		<cfset result['errorId'] = 6/>
        <cfset result['errorMessage'] = "Password must be at least 8 characters"/>
        <cfreturn result/>
	</cfif>
    <cfif email is not "" and email is not " " and not isValid("email",email)>
		<cfset result['errorId'] = 7/>
        <cfset result['errorMessage'] = "Please enter a valid email address."/>
        <cfreturn result/>
	</cfif>
    <cfif userId is 0> 
	<!--- check displayname if entered --->
		<cfif testUn1.RecordCount is not 0>
			<cfset result['errorId'] = 2/>
			<cfset result['errorMessage'] = "Screenname already registered."/>
			<cfreturn result/>
		</cfif>
		<cfif testUn2.RecordCount is not 0>
			<cfset result['errorId'] = 3/>
			<cfset result['errorMessage'] = "Email address already registered."/>
			<cfreturn result/>
		</cfif>
        <cfquery name="ins" datasource="aa" result="qResult">
			INSERT INTO g_users
			(email, screenname, password, isFemale)
			VALUES(
			<cfqueryparam value="#email#"/>,
			<cfqueryparam value="#screenname#"/>,
			<cfqueryparam value="#hashPassword(password)#"/>,
            <cfqueryparam value="#isFemale#"/>)
		</cfquery>
        <cfset result['resultObject'] = structNew()/>
        <cfset result.resultObject['newId'] = qResult.GENERATED_KEY/>
        <cfquery name="money" datasource="aa">
        	INSERT INTO g_items
            (typeId, qty, loc_i, loc_j, ownerId)
            VALUES(
            	1,100,162001,0,<cfqueryparam value="#qResult.GENERATED_KEY#"/>
            )
        </cfquery>
    <cfelse>
    	<cfif testUn1.RecordCount is not 0 and testUn1.id is not userId>
        	<cfset result['errorId'] = 2/>
			<cfset result['errorMessage'] = "Screenname already registered."/>
			<cfreturn result/>
        </cfif>
        <cfif testUn2.RecordCount is not 0 and testUn2.id is not userId>
        	<cfset result['errorId'] = 3/>
			<cfset result['errorMessage'] = "Email address already registered."/>
			<cfreturn result/>
        </cfif>
        <cfquery name="ins" datasource="aa" result="resultQ">
			UPDATE g_users
			SET
			screenname = <cfqueryparam value="#screenname#"/>
            email = <cfqueryparam value="#email#"/>
            isFemale = <cfqueryparam value="#isFemale#"/>
			<cfif password is not "">
				,password = <cfqueryparam value="#hashPassword(password)#"/>
			</cfif>
			WHERE userId = <cfqueryparam value="#userId#"/>
		</cfquery>
    </cfif>
    <cfset result['success'] = true/>
    
	<cfreturn result/>
</cffunction>

<cffunction name="setUserProfileText" returntype="struct" access="public">
	<cfargument name="userid" required="yes"/>
	<cfargument name="text" required="yes"/>
	<cfset var result = structNew()/>
	
	<cfif Len(text) gt 2000>
		<cfset result.success = false/>
		<cfset result.error = 1/>
		<cfset result.message = "Text too long. Limit 2000 characters."/>
		<cfreturn result/>
	</cfif>
	<cfquery name="upd" datasource="aa" result="result">
		UPDATE g_users
		SET profiletext = <cfqueryparam value="#text#" cfsqltype="cf_sql_longvarchar"/>
		WHERE id = <cfqueryparam value="#userid#"/>
		LIMIT 1
	</cfquery>
	<cfset result.success = true/>
	
	<cfreturn result/>
</cffunction>

<cffunction name="logEvent">
	<cfargument name="description" required="no" default="" />
	<cfargument name="loc_i" required="no" default=""/>
    <cfargument name="loc_j" required="no" default="" />
    <cfargument name="userId" required="no" default="" />
    <cfargument name="itemId_1" required="no" default="" />
    <cfargument name="itemId_2" required="no" default="" />
    <cfargument name="offerId" required="no" default="" />
    <cfargument name="notes" required="no" default="" />
    <cfargument name="exposed" required="no" default="0" />
    
    <cfset var loc = structNew()/>
    <cfquery name="loc.ins" datasource="aa">
    	INSERT INTO g_log (description, loc_i, loc_j, userId, itemId_1, itemId_2, offerId, notes, exposed)
        VALUES(
        	<cfqueryparam value="#description#" null="#description is ''#"/>,
            <cfqueryparam value="#loc_i#" null="#loc_i is ''#"/>,
            <cfqueryparam value="#loc_j#" null="#loc_j is ''#"/>,
            <cfqueryparam value="#userId#" null="#userId is ''#"/>,
            <cfqueryparam value="#itemId_1#" null="#itemId_1 is ''#"/>,
            <cfqueryparam value="#itemId_2#" null="#itemId_2 is ''#"/>,
            <cfqueryparam value="#offerId#" null="#offerId is ''#"/>,
            <cfqueryparam value="#notes#" null="#notes is ''#"/>,
            <cfqueryparam value="#exposed#"/>
       	)
    </cfquery>
    
</cffunction>

<cffunction name="getNUserEvents">
	<cfargument name="userId"/>
    <cfset var loc = structNew()/>
    
    <cfquery datasource="aa" name="loc.countQ">
    	SELECT count(*) as n
        FROM g_log
        WHERE userId = <cfqueryparam value="#userId#"/>
    </cfquery>

	<cfreturn loc.countQ.n/>
</cffunction>  

<cffunction name="getTitlesForUser">
	<cfargument name="userId"/>
    <cfset var loc = structNew()/>
    
    <cfquery datasource="aa" name="loc.titleQ">
    	SELECT *
        FROM g_nobles
        WHERE userId = <cfqueryparam value="#userId#"/>
    </cfquery>

	<cfreturn loc.titleQ />
</cffunction>

<cffunction name="getUserLotTypes">
	<cfargument name="userId" />
    
    <cfset var result = structNew()/>
    <cfset var loc = structNew()/>
    
	<cfquery datasource="aa" name="loc.lotTypes">
    	SELECT count(L.id) as count, dt.type
        FROM g_lots L
        LEFT JOIN g_devTypes dt
        ON L.devTypeId = dt.id
        WHERE L.ownerId = <cfqueryparam value="#userId#" />
        GROUP BY dt.type
    </cfquery>
    
    <cfquery dbtype="query" name="loc.nFarm">
    	SELECT * FROM loc.lotTypes WHERE type = 'farm'
    </cfquery>
    <cfif loc.nFarm.recordCount is 0>
    	<cfset result['nFarm'] = 0/>
    <cfelse>
    	<cfset result['nFarm'] = loc.nFarm.count/>
    </cfif>
    
    <cfquery dbtype="query" name="loc.nStore">
    	SELECT * FROM loc.lotTypes WHERE type = 'store'
    </cfquery>
    <cfif loc.nStore.recordCount is 0>
    	<cfset result['nStore'] = 0/>
    <cfelse>
    	<cfset result['nStore'] = loc.nStore.count/>
    </cfif>
    
    <cfquery dbtype="query" name="loc.nHouse">
    	SELECT * FROM loc.lotTypes WHERE type = 'house'
    </cfquery>
    <cfif loc.nHouse.recordCount is 0>
    	<cfset result['nHouse'] = 0/>
    <cfelse>
    	<cfset result['nHouse'] = loc.nHouse.count/>
    </cfif>
    
    <cfquery dbtype="query" name="loc.nFactory">
    	SELECT * FROM loc.lotTypes WHERE type = 'factory'
    </cfquery>
    <cfif loc.nFactory.recordCount is 0>
    	<cfset result['nFactory'] = 0/>
    <cfelse>
    	<cfset result['nFactory'] = loc.nFactory.count/>
    </cfif>
    
    <cfreturn result />
</cffunction>

</cfcomponent>