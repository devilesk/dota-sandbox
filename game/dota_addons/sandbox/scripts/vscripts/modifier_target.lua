modifier_target = class({})

local AGGRO_COLOR = Vector(255, 0, 0)
local NO_AGGRO_COLOR = Vector(0, 255, 0)

function modifier_target:OnCreated(params)   
    if not IsServer() then
        return
    end
    self._color = {}
    self._particles = {}
    self:StartIntervalThink (.01)
end

function modifier_target:UpdateParticleForPlayer(i)
    local player = PlayerResource:GetPlayer(i)
    if player ~= nil then
        if GameRules.herodemo.overlays[i]["CreepAggroRangeButtonPressed"] == true then
            if self._particles[i] ~= nil then
                if self:GetParent():GetAggroTarget() ~= nil and self:GetParent():GetAggroTarget():GetPlayerOwnerID() == i then
                   if self._color[i] ~= AGGRO_COLOR then
                        ParticleManager:DestroyParticle(self._particles[i], true)
                        ParticleManager:ReleaseParticleIndex(self._particles[i])
                        self._particles[i] = nil
                    end
                    self._color[i] = AGGRO_COLOR
                else
                    if self._color[i] ~= NO_AGGRO_COLOR then
                        ParticleManager:DestroyParticle(self._particles[i], true)
                        ParticleManager:ReleaseParticleIndex(self._particles[i])
                        self._particles[i] = nil
                    end
                    self._color[i] = NO_AGGRO_COLOR
                end
            end
            
            if self._particles[i] == nil then
                self._particles[i] = CreateParticleTarget(self:GetParent(), player)
                if self._color[i] == nil then
                    self._color[i] = NO_AGGRO_COLOR
                end
            end

            ParticleManager:SetParticleControl(self._particles[i], 1, self._color[i])
        elseif self._particles[i] ~= nil then
            ParticleManager:DestroyParticle(self._particles[i], true)
            ParticleManager:ReleaseParticleIndex(self._particles[i])
            self._particles[i] = nil
        end
    elseif self._particles[i] ~= nil then
        ParticleManager:DestroyParticle(self._particles[i], true)
        ParticleManager:ReleaseParticleIndex(self._particles[i])
        self._particles[i] = nil
    end
end

function modifier_target:OnIntervalThink()
    if not IsServer() then
        return
    end
    if self:GetCaster():IsHero() then
        self:UpdateParticleForPlayer(self:GetCaster():GetPlayerID())
    end
end

function modifier_target:OnDestroy(params)
    if not IsServer() then
        return
    end
    for _, particle in pairs(self._particles) do
        ParticleManager:DestroyParticle(particle, true)
        ParticleManager:ReleaseParticleIndex(particle)
    end
    self._particles = {}
end

function modifier_target:RemoveOnDeath()
    return true
end

--effect attached position the Buff effect attachment position
function modifier_target:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_target:IsHidden()
    return true
end