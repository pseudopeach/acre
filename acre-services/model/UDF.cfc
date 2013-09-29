<cfcomponent>

<cffunction name="calcDistance" returntype="numeric">
	<cfargument name="lat1" type="numeric"/>  
    <cfargument name="lon1" type="numeric"/>
    <cfargument name="lat2" type="numeric"/>  
    <cfargument name="lon2" type="numeric"/>
    
    <cfset var D = 7918*asin(sqr(
                 sin((lat1-lat2)/114.59)^2
                +sin((lon1-lon2)/114.59)^2
                *cos(lat1/57.3)*cos(lat2/57.3) ))/>
                
    <cfreturn D/>
</cffunction>

<cffunction name="getPixelColor">
    <cfargument name="imageName" />
    <cfargument name="x" />
    <cfargument name="y" />
    
    <cfset var loc = structNew() />
    <cfset var color = structNew() />
    
    <cfset imageName = expandPath("/acre-services/resourceMaps/#imageName#") />
    <cfset loc.image = imageRead(imageName) />
    
    <cfset loc.bufferedImage = imageGetBufferedImage(loc.image) /> 
    
    <cfset loc.pixelBuffer = loc.bufferedImage.getRGB(
        javaCast( "int", x ),
        javaCast( "int", y ),
        javaCast( "int", 1 ),
        javaCast( "int", 1 ),
        javaCast( "null", "" ),
        javaCast( "int", 0 ),
        javaCast( "int", 1 )
    ) />
    
    <cfset color['red'] = bitAnd(bitSHRN(loc.pixelBuffer[1], 16 ) ,255)/>
    <cfset color['green'] = bitAnd(bitSHRN(loc.pixelBuffer[1], 8 ), 255)/>
    <cfset color['blue'] = bitAnd(loc.pixelBuffer[1], 255) />
    
    <cfreturn color />
</cffunction>
    
<cffunction name="projectWinkel" >
    <cfargument name="lat" />
    <cfargument name="lon" />
    <cfargument name="alreadyRadians" required="no" default="false" />
    
    <cfset var result = structNew() />
    <cfset var alpha = 0 />
    <cfset var cosLat1 = .636619772 />
    <cfset var xScale = .097246132 />  <!---1/(4+2pi) --->
    <cfset var yScale = .159154943 />  <!---1/(2pi) --->
    
    <cfif not alreadyRadians>
    	<cfset lat = lat*pi()/180 />
        <cfset lon = lon*pi()/180 />
    </cfif>
    
    <cfset alpha = cos(lat)*cos(lon/2) />
    <cfset alpha = sqr(1-(alpha)^2)/acos(alpha) />
    
    <cfset result['x'] = xScale*(lon*cosLat1+2*cos(lat)*sin(lon/2)/alpha) />
    <cfset result['y'] = yScale*(lat+sin(lat)/alpha) />
    
    <cfreturn result />
</cffunction>

<cffunction name="queryToStructArray">
	<cfargument name="input" type="query" />
    <cfargument name="clist" type="string" required="no" default=""/>
    
    <cfset var output = arrayNew(1) />
 
	<cfset var someArray = getMetaData(input)/>
    <cfif clist is "">
        <cfloop array="#someArray#" index="i">
            <cfset clist = listAppend(clist, i.name)/>
        </cfloop>
    </cfif>
        
    <cfloop query="input">
        <cfset arrayAppend(output, structNew()) />
        <cfloop from="1" to="#listLen(clist)#" index="i">
            <cfset output[arrayLen(output)][listGetAt(clist,i)] = input[listGetAt(clist,i)][currentRow] />
        </cfloop>
    </cfloop>
    
    <cfreturn output />
</cffunction>
     
      
	<cffunction name="printCaptcha" output="true">
		<cfsilent><cfset w3="aeroplane,aircraft,carrier,airforce,airport,alphabet,backpack,balloon,barbecue,bathroom,bathtub,butterfly,cappuccino,car-race,chocolates,coffee-shop,compact,compass,computer,crystal,diamond,electricity,elephant,explosive,feather,festival,floodlight,freeway,gemstone,hieroglyph,highway,horoscope,ice-cream,fighter,kaleidoscope,kitchen,leather,library,microscope,milkshake,monster,mosquito,necklace,paintbrush,parachute,passport,pendulum,perfume,post-office,printer,pyramid,rainbow,restaurant,sandpaper,sandwich,satellite,signature,skeleton,software,shuttle,spectrum,sports-car,staircase,stomach,sunglasses,surveyor,swimming,tapestry,telescope,television,racquet,thermometer,torpedo,treadmill,triangle,typewriter,umbrella,vampire,videotape,vulture,wheelchair,becomes,necessary,dissolve,political,connected,another,separate,station,entitle,respect,opinions,mankind,requires,declare,separation,self-evident,created,endowed,creator,certain,liberty,pursuit,happiness,governments,instituted,deriving,consent,governed,whenever,government,becomes,destructive,abolish,institute,government,foundation,principles,organizing,happiness,prudence,dictate,governments,established,changed,transient,accordingly,experience,mankind,disposed,sufferable,themselves,abolishing,accustomed,usurpations,pursuing,invariably,evinces,absolute,despotism,government,provide,security,patient,sufferance,colonies,necessity,constrains,systems,government,history,present,britain,history,repeated,injuries,usurpations,establishment,absolute,tyranny,submitted,refused,wholesome,necessary,forbidden,governors,immediate,pressing,importance,suspended,operation,obtained,suspended,utterly,neglected,refused,accommodation,districts,relinquish,representation,legislature,inestimable,formidable,tyrants,together,legislative,unusual,uncomfortable,distant,depository,records,purpose,fatiguing,compliance,measures,dissolved,representative,repeatedly,opposing,firmness,invasions,refused,dissolutions,elected,whereby,legislative,incapable,annihilation,returned,exercise,remaining,exposed,dangers,invasion,without,convulsions,endeavoured,prevent,population,purpose,obstructing,naturalization,foreigners,refusing,encourage,migrations,raising,conditions,appropriations,obstructed,administration,justice,refusing,establishing,judiciary,dependent,offices,payment,salaries,erected,multitude,offices,officers,substance,standing,without,consent,legislatures,affected,military,independent,superior,combined,subject,jurisdiction,foreign,constitution,unacknowledged,pretended,legislation,quartering,protecting,punishment,murders,inhabitants,cutting,imposing,without,consent,depriving,benefit,transporting,pretended,offences,abolishing,english,neighbouring,province,establishing,therein,arbitrary,government,enlarging,boundaries,example,instrument,introducing,absolute,colonies,charters,abolishing,valuable,altering,fundamentally,governments,suspending,legislatures,declaring,themselves,invested,legislate,whatsoever,abdicated,government,declaring,protection,against,plundered,ravaged,destroyed,transporting,foreign,mercenaries,compleat,desolation,tyranny,already,circumstances,cruelty,perfidy,scarcely,paralleled,barbarous,totally,unworthy,civilized,constrained,citizens,captive,against,country,executioners,friends,brethren,themselves,excited,domestic,insurrections,amongst,endeavoured,inhabitants,frontiers,merciless,savages,warfare,destruction,conditions,oppressions,petitioned,redress,repeated,petitions,answered,repeated,character,wanting,attentions,british,brethren,attempts,legislature,unwarrantable,jurisdiction,reminded,circumstances,emigration,settlement,appealed,justice,magnanimity,conjured,kindred,disavow,usurpations,inevitably,interrupt,connections,correspondence,justice,consanguinity,therefore,acquiesce,necessity,denounces,separation,mankind,enemies,friends,therefore,america,general,congress,assembled,appealing,supreme,rectitude,intentions,authority,colonies,solemnly,publish,declare,colonies,independent,absolved,allegiance,british,political,connection,between,britain,totally,dissolved,independent,conclude,contract,alliances,establish,commerce,independent,support,declaration,reliance,protection,providence,mutually,fortunes,daughters,aluminum,cinnamon,currents,shoulder,grounds,daughters,bunkers,dirrigible,untraceable,daughters,aluminum,cinnamon,daughters,aluminum,cinnamon,daughters,underwater,aluminum,cinnamon,semipermeable,membrane,selectively,permeable,partially,permeable,differentially,permeable,certain,molecules,through,diffusion,occasionally,specialized,facilitated,diffusion,passage,depends,pressure,concentration,temperature,molecules,solutes,permeability,depending,permeability,solubility,properties,chemistry,example,permeable,membrane,bilayer,surrounds,biological,natural,synthetic,materials,thicker,example,phospholipid,bilayer,phospholipids,consisting,phosphate,arranged,hydrophilic,phosphate,exposed,content,outside,hydrophobic,phospholipid,bilayer,permeable,uncharged,solutes,protein,channels,through,phospholipids,collectively,modelin,process,reverse,osmosis,composite,membranes,semipermeable,membranes,manufactured,principally,purification,desalination,systems,chemical,applications,batteries,essence,material,molecular,constructed,layered,materials,membranes,reverse,osmosis,general,polyimide,primarily,permeability,relative,impermeability,various,dissolved,impurities,including,molecules,filtered,another,example,semipermeable,membrane,dialysis,aardvark,alligator,anteater,antelope,armadillo,basilisk,bighorn,budgerigar,buffalo,capybara,chameleon,chamois,cheetah,chimpanzee,chinchilla,chipmunk,crocodile,dormouse,dromedary,duckbill,elephant,gazelle,gemsbok,monster,giraffe,gorilla,grizzly,guanaco,hamster,hartebeest,hedgehog,hippopotamus,kangaroo,kinkajou,leopard,lovebird,mandrill,marmoset,mongoose,mountain,muskrat,mustang,opossum,orangutan,panther,parakeet,peccary,platypus,porcupine,porpoise,prairie,pronghorn,raccoon,reindeer,reptile,rhinoceros,roebuck,salamander,springbok,squirrel,stallion,warthog,waterbuck,wildcat,wolverine,woodchuck,acropora,hydrogen,lithium,beryllium,nitrogen,fluorine,magnesium,silicon,phosphorus,chlorine,potassium,calcium,scandium,titanium,vanadium,chromium,manganese,gallium,germanium,arsenic,selenium,bromine,krypton,rubidium,strontium,yttrium,zirconium,niobium,molybdenum,technetium,ruthenium,rhodium,palladium,cadmium,antimony,tellurium,caesium,lanthanum,praseodymium,neodymium,promethium,samarium,europium,gadolinium,terbium,dysprosium,holmium,thulium,lutetium,hafnium,tantalum,tungsten,rhenium,iridium,platinum,mercury,thallium,bismuth,polonium,astatine,francium,actinium,thorium,protactinium,uranium,neptunium,plutonium,americium,berkelium,californium,einsteinium,fermium,mendelevium,nobelium,lawrencium,abandoned,abomination,gatekeeper,abyssal,accumulated,aggravated,aggressive,retribution,leprechaun,aftershock,benediction,amphitheater,exterminator,researchers,protector,laboratory,architects,mongoose,prerogative,extraction,awakening,blistering,asunder,blighted,benevolent,destruction,covenant,floating,flickering,flourishing,footsteps,forbidding,presence,frenetic,interceptor,specimens,purification,incinerator,ghostly,reincarnation,mountaineer,preservation,hypochondria,crossroads,captivity,snipped,wingspan,precious,captive,clipped,rubbing,wrecked,fortress,outback,mariners,survivors,ceiling,carpeting,remember,eighteen,remember,histories,interweave,roustabout,spending,charming,debonair,widowed,disease,drunken,leaving,consumptive,disappeared,gambling,arrears,magistrate,reclaimed,fingers,splinters,clawing,ceiling,fifteen,swallow,urchins,thought,revenge,overheard,exchanging,penitent,captain,matched,cruelty,following,shipped,privateer,whistle,fingers,splinters,clawing,ceiling,fateful,starboard,getting,muskets,rumbling,beneath,captain,quailed,survived,slipped,between,providence,intelligence,survive,whisper"/>
		<cfset rnum = round(ListLen(w3)*Rand())/>
		<cfif rnum is 0><cfset rnum=6/></cfif>
		<cfset word = listgetat(w3,rnum)/></cfsilent>
		
		<cfimage action="captcha" width="454" height="45" difficulty="medium" 
			fontsize="30" text="#word#"/>
		<cfset SESSION.lastcaptcha = word/>
	</cffunction>

        
        
        

</cfcomponent>