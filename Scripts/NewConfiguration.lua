--[[ 
	by Northern_Strike
	29.07.2019
 ]]
local base_char,keywords=128,{"and","break","do","else","elseif","end","false","for","function","if","in","local","nil","not","or","repeat","return","then","true","until","while","NewConfiguration","ConfigurationUtil","g_configurationManager","getNewConfigurations","name","configurations","self","registerEventListener","addConfigurationType","currentModDirectory","SpecializationUtil","\"configuration_\"","type","getXMLString","getNoNil","xmlFile","getText","g_i18n","ipairs","\"option\"",}; function prettify(code) return code:gsub("["..string.char(base_char).."-"..string.char(base_char+#keywords).."]", 
	function (c) return keywords[c:byte()-base_char]; end) end return assert(loadstring(prettify[===[ñ={}ñ.ü=g_currentModDirectory
â ñ.ô()å t={}å e=loadXMLFile("modDesc",ñ.ü.."modDesc.xml")å i=0
ï ì É
å o=string.format("modDesc.newConfigurations.newConfiguration(%d)",i)ä é hasXMLProperty(e,o)í
Ç
Ü
å n={}n.ö=Utils.§(£(e,o.."#name"),"")n.¢=Utils.§(£(e,o.."#type"),"")ä n.ö~=""í
table.insert(t,n)Ü
i=i+1
Ü
ë t
Ü
â ñ.prerequisitesPresent(n)ë ì
Ü
â ñ.registerEventListeners(n)†.ù(n,"initSpecialization",ñ)†.ù(n,"onLoad",ñ)Ü
â ñ.initSpecialization()å n=ñ.ô()à i,n ã ®(n)É
ä ò:getConfigurationDescByName(n.ö)==ç í
ä n.¢=="color"í
ò:û(n.ö,ß:¶(°..n.ö),ç,ç,ó.getConfigColorSingleItemLoad,ó.getConfigColorPostLoad,ó.SELECTOR_COLOR)Ö n.¢==©í
ò:û(n.ö,ß:¶(°..n.ö),ç,ç,ç,ç,ó.SELECTOR_MULTIOPTION)Ü
Ü
Ü
Ü
â ñ:onLoad(n)å n=ñ.ô()à i,n ã ®(n)É
ä ú.õ[n.ö]~=ç í
ä n.¢=="color"í
ú:applyBaseMaterialConfiguration(ú.•,n.ö,ú.õ[n.ö])Ö n.¢==©í
ObjectChangeUtil.updateObjectChanges(ú.•,"vehicle."..n.ö.."Configurations."..n.ö.."Configuration",ú.õ[n.ö],ú.components,ú)Ü
Ü
Ü
ú:applyBaseMaterial()Ü
]===], '@NewConfiguration.lua'))()