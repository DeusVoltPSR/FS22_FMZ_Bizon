--[[ 
	by Northern_Strike
	29.07.2019
 ]]
local base_char,keywords=128,{"and","break","do","else","elseif","end","false","for","function","if","in","local","nil","not","or","repeat","return","then","true","until","while","NewConfiguration","ConfigurationUtil","g_configurationManager","getNewConfigurations","name","configurations","self","registerEventListener","addConfigurationType","currentModDirectory","SpecializationUtil","\"configuration_\"","type","getXMLString","getNoNil","xmlFile","getText","g_i18n","ipairs","\"option\"",}; function prettify(code) return code:gsub("["..string.char(base_char).."-"..string.char(base_char+#keywords).."]", 
	function (c) return keywords[c:byte()-base_char]; end) end return assert(loadstring(prettify[===[�={}�.�=g_currentModDirectory
� �.�()� t={}� e=loadXMLFile("modDesc",�.�.."modDesc.xml")� i=0
� � �
� o=string.format("modDesc.newConfigurations.newConfiguration(%d)",i)� � hasXMLProperty(e,o)�
�
�
� n={}n.�=Utils.�(�(e,o.."#name"),"")n.�=Utils.�(�(e,o.."#type"),"")� n.�~=""�
table.insert(t,n)�
i=i+1
�
� t
�
� �.prerequisitesPresent(n)� �
�
� �.registerEventListeners(n)�.�(n,"initSpecialization",�)�.�(n,"onLoad",�)�
� �.initSpecialization()� n=�.�()� i,n � �(n)�
� �:getConfigurationDescByName(n.�)==� �
� n.�=="color"�
�:�(n.�,�:�(�..n.�),�,�,�.getConfigColorSingleItemLoad,�.getConfigColorPostLoad,�.SELECTOR_COLOR)� n.�==��
�:�(n.�,�:�(�..n.�),�,�,�,�,�.SELECTOR_MULTIOPTION)�
�
�
�
� �:onLoad(n)� n=�.�()� i,n � �(n)�
� �.�[n.�]~=� �
� n.�=="color"�
�:applyBaseMaterialConfiguration(�.�,n.�,�.�[n.�])� n.�==��
ObjectChangeUtil.updateObjectChanges(�.�,"vehicle."..n.�.."Configurations."..n.�.."Configuration",�.�[n.�],�.components,�)�
�
�
�:applyBaseMaterial()�
]===], '@NewConfiguration.lua'))()