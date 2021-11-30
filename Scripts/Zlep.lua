Zlep = {};

Zlep.debug = false --true --

Zlep.myCurrentModDirectory = g_currentModDirectory;
Zlep.modName = g_currentModName

-- @TEST:
-- [x] Start threshing without cutter
-- [x] Start threshing with cutter attached
-- [x] Start threshing with cutter attached & activated
-- [x] Start threshing with combine folded
-- [x] Start threshing with cutter folded
-- [x] Start Worker without cutter
-- [x] Start Worker with cutter attached
-- [x] Start Worker with cutter attached & activated
-- [x] Start Worker with combine folded
-- [x] Start Worker with cutter folded
-- [x] Try harvesting with cutter deactivated
-- [x] Manual attach compatibility
-- [x] Waiting worker compatibility
-- [x] Try other Combine type vehicles
-- [x]  - sugarBeet
-- [x]  - maize
-- [x]  - potatoe

function Zlep.prerequisitesPresent(specializations)
    return	true
end

function Zlep.registerFunctions(vehicleType)
    if Zlep.debug then print("Zlep:registerFunctions") end
    SpecializationUtil.registerFunction(vehicleType, "getTimeDependantSpeed", Zlep.getTimeDependantSpeed)
end

function Zlep.registerOverwrittenFunctions(vehicleType)
    if Zlep.debug then print("Zlep:registerOverwrittenFunctions") end
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "addCutterArea", Zlep.addCutterArea)
    -- SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanBeTurnedOn", Zlep.getCanBeTurnedOn)  -- Error if used
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "startThreshing", Zlep.startThreshing)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "stopThreshing", Zlep.stopThreshing)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getIsThreshingAllowed", Zlep.getIsThreshingAllowed)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "removeActionEvents", Zlep.removeActionEvents)
end

function Zlep.registerEventListeners(vehicleType)
    if Zlep.debug then print("Zlep:registerEventListeners") end
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", Zlep)
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", Zlep)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", Zlep)
    SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", Zlep)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", Zlep)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", Zlep)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", Zlep)
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", Zlep)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", Zlep)
end

-- Prevent cutter to start and move down when starting the combine threshing
function Zlep:startThreshing(superfunc)
    if Zlep.debug then print("Zlep:startThreshing") end
    local spec_combine = self.spec_combine

    local isAIActive = self:getIsAIActive()
    if spec_combine.numAttachedCutters > 0 and isAIActive then
        -- Only start cutter if threshing started by AI
        local allowLowering = not self:getIsAIActive() or not self:getRootVehicle():getAIIsTurning()

        for _, cutter in pairs(spec_combine.attachedCutters) do
            if allowLowering and cutter ~= self then
                local jointDescIndex = self:getAttacherJointIndexFromObject(cutter)

                self:setJointMoveDown(jointDescIndex, true, true)
            end

            cutter:setIsTurnedOn(true, true)
        end
    end

    if spec_combine.threshingStartAnimation ~= nil and self.playAnimation ~= nil then
        self:playAnimation(spec_combine.threshingStartAnimation, spec_combine.threshingStartAnimationSpeedScale, self:getAnimationTime(spec_combine.threshingStartAnimation), true)
    end

    if self.isClient then
        g_soundManager:stopSamples(spec_combine.samples)
        g_soundManager:playSample(spec_combine.samples.start)
        g_soundManager:playSample(spec_combine.samples.work, 0, spec_combine.samples.start)
    end

    SpecializationUtil.raiseEvent(self, "onStartThreshing")
end

-- Prevent cutter to stop and move up when stoping the combine threshing
function Zlep:stopThreshing(superfunc)
    if Zlep.debug then print("Zlep:stopThreshing") end
    local spec_combine = self.spec_combine

    if self.isClient then
        g_soundManager:stopSamples(spec_combine.samples)
        g_soundManager:playSample(spec_combine.samples.stop)
    end

    self:setCombineIsFilling(false, false, true)

    -- for cutter, _ in pairs(spec_combine.attachedCutters) do
    --     if cutter ~= self then
    --         local jointDescIndex = self:getAttacherJointIndexFromObject(cutter)

    --         self:setJointMoveDown(jointDescIndex, false, true)
    --     end

    --     cutter:setIsTurnedOn(false, true)
    -- end

    if spec_combine.threshingStartAnimation ~= nil and spec_combine.playAnimation ~= nil then
        self:playAnimation(spec_combine.threshingStartAnimation, -spec_combine.threshingStartAnimationSpeedScale, self:getAnimationTime(spec_combine.threshingStartAnimation), true)
    end

    SpecializationUtil.raiseEvent(self, "onStopThreshing")
end

-- Display warning when trying to harvest with threshing off + HUD values
function Zlep:onDraw(superFunc, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    -- if Zlep.debug then print("Zlep:onDraw") end
    local spec = self.spec_Zlep
    local spec_combine = self.spec_combine
    local spec_aiVehicle = self.spec_aiVehicle
    -- if spec_aiVehicle and spec_aiVehicle.getIsAIActive and spec_aiVehicle:getIsAIActive() then
    --     return
    -- end
    if spec and self:getIsTurnedOn() then
        local hud = g_combinexp.hud
        hud:setVehicle(self)
        hud:drawText()
    else
        if spec_combine.numAttachedCutters > 0 then
            local cutterIsTurnedOn = false
            for _, cutter in pairs(spec_combine.attachedCutters) do
                if cutter.getIsTurnedOn ~= nil and cutter:getIsTurnedOn() then
                    local spec_cutter = cutter.spec_cutter
                    local isEffectActive = self.movingDirection == spec_cutter.movingDirection and self:getLastSpeed() > 0.5 and (spec_cutter.allowCuttingWhileRaised or cutter:getIsLowered(true))
                    cutterIsTurnedOn = isEffectActive
                    break
                end
            end
            if cutterIsTurnedOn then
                g_currentMission:showBlinkingWarning(g_i18n:getText("warning_firstStartThreshing"), 2000)
            end
        end
    end
end

-- Disable harvesting if combine threshing is off
function Zlep:getIsThreshingAllowed(superFunc, earlyWarning)
    -- if Zlep.debug then print("Zlep:getIsThreshingAllowed") end
    local isAIActive = self:getIsAIActive()
    if not self:getIsTurnedOn() and not isAIActive then
        return false
    end
    return superFunc(self, earlyWarning)
end