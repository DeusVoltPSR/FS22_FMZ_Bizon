--[[

Game:    Farming Simulator 19
Script:  ExtendedExhaust
Author:  ThundR
Created: 12/15/2020

original script by modelleicher
www.schwabenmodding.bplaced.net

Notes:
    - Adds exhaust features
    - Adds dynamic exhaust particleSystem effects

--]]

-- luacheck: ignore 111 112 113 212 631

local g_modName = g_currentModName
local g_specName = "spec_"..g_modName..".extendedExhaust"

ExtendedExhaust = {}

-- <<[Initialization]>> ---------------------------------------------------------------------------

-- <<prerequisitesPresent>>
function ExtendedExhaust.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Motorized, specializations)
end

-- <<registerOverwrittenFunctions>>
function ExtendedExhaust.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "loadExhaustEffects", ExtendedExhaust.loadExhaustEffects)
end

-- <<registerEventListeners>>
function ExtendedExhaust.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onStartMotor", ExtendedExhaust)
    SpecializationUtil.registerEventListener(vehicleType, "onStopMotor", ExtendedExhaust)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", ExtendedExhaust)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", ExtendedExhaust)
end

-- <<[Event Functions]>> --------------------------------------------------------------------------

-- <<onUpdateTick>>
function ExtendedExhaust:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local spec = self[g_specName]

    if self.isClient then
        if self:getIsMotorStarted() then
            if spec.particleSystems ~= nil then
                local motorIsStarting = false
                local motorLoad = self:getMotorLoadPercentage()
                local motorRpm = self:getMotorRpmPercentage()

                if spec.psMotorStartTime > 0 then
                    spec.psMotorStartTime = math.max(0, spec.psMotorStartTime - dt)
                    motorIsStarting = true
                end

                if spec.particleSystems ~= nil then
                    for _, ps in ipairs(spec.particleSystems) do
                        local emitScale, speedScale -- placeholders

                        if motorIsStarting then
                            local startInfo = ps.startInfo
                            emitScale = startInfo.emitScale
                            speedScale = startInfo.speedScale
                        else
                            local loadInfo = ps.loadInfo
                            local rpmInfo = ps.rpmInfo

                            local adjustedLoad = motorLoad * loadInfo.threshold
                            local totalEmitScale = loadInfo.emitScale * rpmInfo.emitScale

                            emitScale = MathUtil.lerp(1, totalEmitScale, adjustedLoad)
                            speedScale = MathUtil.lerp(1, rpmInfo.speedScale, motorRpm)
                        end

                        ParticleUtil.setEmitCountScale(ps, emitScale)
                        ParticleUtil.setParticleSystemTimeScale(ps, speedScale)
                    end
                end
            end
        end
    end
end

-- <<onStartMotor>>
function ExtendedExhaust:onStartMotor()
    local spec = self[g_specName]

    if self.isClient then
        if spec.particleSystems ~= nil then
            spec.psMotorStartTime = spec.psMotorStartDuration
            for _, ps in ipairs(spec.particleSystems) do
                ParticleUtil.setEmittingState(ps, true)
            end
        end
    end
end

-- <<onStopMotor>>
function ExtendedExhaust:onStopMotor()
    local spec = self[g_specName]

    if self.isClient then
        if spec.particleSystems ~= nil then
            for _, ps in ipairs(spec.particleSystems) do
                ParticleUtil.setEmittingState(ps, false)
            end
        end
    end
end

-- <<onDelete>>
function ExtendedExhaust:onDelete()
    local spec = self[g_specName]
    if self.isClient then
        if spec.particleSystems ~= nil then
            ParticleUtil.deleteParticleSystems(spec.particleSystems)
        end
    end
end

-- <<[Specialization Overrides]>> -----------------------------------------------------------------

-- <<loadExhaustEffects>>
function ExtendedExhaust:loadExhaustEffects(superFunc, xmlFile)
    local spec = self[g_specName]
    superFunc(self, xmlFile)

    local extendedExhaustKey = "vehicle.motorized.extendedExhaust"

    spec.psMotorStartDuration = Utils.getNoNil(getXMLFloat(xmlFile, extendedExhaustKey.."#motorStartDuration"), 0)
    spec.psMotorStartTime = 0
    spec.particleSystems = {}

    local idx = 0
    while true do
        local psKey = string.format("%s.particleSystems.particleSystem(%d)", extendedExhaustKey, idx)
        if not hasXMLProperty(xmlFile, psKey) then
            break
        end

        local ps = {}
        local rpmInfo = {
            emitScale  = math.max(0, Utils.getNoNil(getXMLFloat(xmlFile, psKey..".rpmInfo#emitScale"), 1)),
            speedScale = math.max(0, Utils.getNoNil(getXMLFloat(xmlFile, psKey..".rpmInfo#speedScale"), 1))
        }
        local loadInfo = {
            emitScale = math.max(0, Utils.getNoNil(getXMLFloat(xmlFile, psKey..".loadInfo#emitScale"), 1)),
            threshold = MathUtil.clamp(Utils.getNoNil(getXMLFloat(xmlFile, psKey..".loadInfo#threshold"), 1), 0, 1)
        }
        local startInfo = {
            emitScale  = math.max(0, Utils.getNoNil(getXMLFloat(xmlFile, psKey..".startInfo#emitScale"), 1)),
            speedScale = math.max(0, Utils.getNoNil(getXMLFloat(xmlFile, psKey..".startInfo#speedScale"), 1))
        }

        ParticleUtil.loadParticleSystem(xmlFile, ps, psKey, self.components, false, nil, self.baseDirectory)
        ps.rpmInfo = rpmInfo
        ps.loadInfo = loadInfo
        ps.startInfo = startInfo

        table.insert(spec.particleSystems, ps)
        idx = idx + 1
    end

    if #spec.particleSystems == 0 then
        spec.particleSystems = nil
    end
end
