modifier_range_circle = class ({})

function modifier_range_circle:OnCreated (params)
    if IsClient() then
        self._client_range = params.range
    end
    
    --NOTE:These functions will be performed while the server and client, so please judge (usually a key operation on the server, only the prompts on the client!)
    if not IsServer() then
        return
    end
   --set interval of think sets the timer interval
    for k,v in pairs(params) do
        print (tostring(k) .. " " .. tostring(v))
    end
    self._range = params.range
    self:StartIntervalThink (.01)
end
--[[function modifier_range_circle:DeclareFunctions()
    local funcs = {
        --MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end]]
function modifier_range_circle:OnDestroy(params)
    if IsClient() then
        print ("client OnDestroy")
        for k,v in pairs(self) do
            print ("client " .. tostring(k) .. " " .. tostring(v))
        end
    end
    if not IsServer() then
        return
    end
    for k,v in pairs(self) do
        print (tostring(k) .. " " .. tostring(v))
    end
    print ("OnDestroy")
    if self._RangeCircleParticle ~= nil then
        ParticleManager:DestroyParticle(self._RangeCircleParticle, true)
    end
    PrintTable(params, " ")
end
function modifier_range_circle:RemoveOnDeath()
    print ("RemoveOnDeath")
    return true
end

--think callback timer callback function
function modifier_range_circle:OnIntervalThink()
    if not IsServer() then
        return
    end
    if self._RangeCircleParticle == nil then
        self._RangeCircleParticle = CreateParticleCircle(self:GetParent(), self._range, RANGE_PARTICLE)
    end
    ----print ( "modifier_range_circle:OnIntervalThink")
end

--effect attached position the Buff effect attachment position
function modifier_range_circle:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_range_circle:IsHidden()
    return false
end