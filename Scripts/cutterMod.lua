cutterMod = {};
cutterMod.modDir = g_currentModDirectory;
cutterMod.currentModName = g_currentModName;

function cutterMod.prerequisitesPresent(specializations, vehicles)
	return true
end;

function cutterMod.registerEventListeners(vehicleType)
	for _, spec in pairs({"onLoad", "onUpdate", "OnDelete","onRegisterActionEvents", "actionEvent_reelFaster"}) do
		SpecializationUtil.registerEventListener(vehicleType, spec, cutterMod)
	end
end

function cutterMod.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "actionEvent_reelFaster", cutterMod.actionEvent_reelFaster)
end;



function cutterMod:onLoad(savegame)
	local spec= self.spec_cutter
	isAnimReelPlaying = false
	localSpeed=1
	self.newReelSpeed = 0.5
	print("Loaded for" .. cutterMod.currentModName)


	local schema = Vehicle.xmlSchema
	schema:setXMLSpecializationType("cutterReel")
	schema:register(XMLValueType.STRING, "vehicle.cutter.reel#reelAnimLoop", "Animation name")
	self.changeReelAnim = {}
	self.changeReelAnim.anim1 = self.xmlFile:getValue("vehicle.cutter.reel#reelAnimLoop")

end;


function cutterMod:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)

	if self.isClient then
		local spec = self.spec_cylindered

		if isActiveForInputIgnoreSelection then
			local _, actionEventId1 = self:addPoweredActionEvent(spec.actionEvents, InputAction.reelActionFaster, self, cutterMod.actionEvent_reelFaster, false, true, true, true, nil)
			g_inputBinding:setActionEventTextPriority(actionEventId1, GS_PRIO_VERY_HIGH)
			g_inputBinding:setActionEventTextVisibility(actionEventId1, true)
		end
	end
end;

function cutterMod:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected )
	if self.isClient then
	local spec= self.spec_cutter
	self.isWorking = self:getIsTurnedOn()
	
		localSpeed = self:getAnimationSpeed(self.changeReelAnim.anim1)
		self:setAnimationSpeed(self.changeReelAnim.anim1, self.newReelSpeed)
		if self.newReelSpeed < 0.15 then
			self.newReelSpeed = 0.16
		end
		if self.newReelSpeed > 1.01 then
			self.newReelSpeed = 1
		end
    end

end;


function cutterMod.actionEvent_reelFaster(self, actionName, inputValue)
	if self.isClient then
	reelModifyValue = inputValue/100
	
	self.newReelSpeed = self.newReelSpeed + reelModifyValue
	
	--print("Last Reel Speed: " .. localSpeed)
	--print("inputValue: " .. inputValue)
	--print("New Reel Speed" .. self.newReelSpeed)
	end
end;
