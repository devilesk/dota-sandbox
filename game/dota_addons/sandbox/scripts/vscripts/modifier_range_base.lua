modifier_range_base = class({})

function modifier_range_base:OnCreated(params)   
    if not IsServer() then
        return
    end
    self._range = params.range
    self._particles = {}
    self._overlayName = params.overlayName
    self._showOwnerOnly = params.showOwnerOnly
    self:StartIntervalThink (.01)
end

function modifier_range_base:UpdateParticleForPlayer(i)
    local player = PlayerResource:GetPlayer(i)
    if player ~= nil then
        if GameRules.herodemo.overlays[i][self._overlayName] == true then
            if self._particles[i] == nil then
                self._particles[i] = CreateParticleCircle(self:GetParent(), self._range, RANGE_PARTICLE, player)
            end
        elseif self._particles[i] ~= nil then
            ParticleManager:DestroyParticle(self._particles[i], true)
            self._particles[i] = nil
        end
    elseif self._particles[i] ~= nil then
        ParticleManager:DestroyParticle(self._particles[i], true)
        self._particles[i] = nil
    end
end

function modifier_range_base:OnIntervalThink()
    if not IsServer() then
        return
    end
    if self._showOwnerOnly then
        self:UpdateParticleForPlayer(self:GetParent():GetPlayerID())
    else
        for i = 0, 9 do
            self:UpdateParticleForPlayer(i)
        end
    end
end

function modifier_range_base:OnDestroy(params)
    if not IsServer() then
        return
    end
    for _, particle in pairs(self._particles) do
        ParticleManager:DestroyParticle(particle, true)
    end
    self._particles = {}
end

function modifier_range_base:RemoveOnDeath()
    return true
end

--effect attached position the Buff effect attachment position
function modifier_range_base:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_range_base:IsHidden()
    return true
end