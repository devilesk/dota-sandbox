--The class name, the file name is consistent with
modifier_damage_tracking = class ({})
--when a modifier created when the Modifier is created
function modifier_damage_tracking:OnCreated (table)
    --print ("modifier_damage_tracking:OnCreated")
    --NOTE:These functions will be performed while the server and client, so please judge (usually a key operation on the server, only the prompts on the client!)
    if not IsServer() then
        return
    end
   --set interval of think sets the timer interval
   self:StartIntervalThink (1)
end
function modifier_damage_tracking:DeclareFunctions()
    local funcs = {
        --MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end
function modifier_damage_tracking:OnAttackStart(params)
    if not IsServer() then
        return
    end
    --[[if params.attacker == self:GetParent() then
        --print ( "modifier_damage_tracking:OnAttackStart attacker")
        --printTable(params, " ")
    end]]
end
function modifier_damage_tracking:OnAttack(params)
    if not IsServer() then
        return
    end
    if params.attacker == self:GetParent() then
        --print ( "modifier_damage_tracking:OnAttack attacker")
        -- params.target:GetHealth() target health at time attack is launched (after attack point)
        --print (params.target:GetName() .. " " .. tostring(params.target:IsAlive()) .. " " .. tostring(params.target:GetHealth()) )
        if GameRules.herodemo.m_bShowTargetHealthPreAttack == true then
            SendOverheadEventMessage(nil, 3, params.target, params.target:GetHealth(), nil)
        end
    end
end
function modifier_damage_tracking:OnAttackFail(params)
    if not IsServer() then
        return
    end
    if params.attacker == self:GetParent() then
        --print ( "modifier_damage_tracking:OnAttackFail attacker")
        ----printTable(params, " ")
    end
end
-- OnAttackLanded before damage from attacker
-- if target:IsAlive() == false and/or target:GetHealth() == 0 then did not get last hit
function modifier_damage_tracking:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    if params.attacker == self:GetParent() then
        --print ( "modifier_damage_tracking:OnAttackLanded attacker")
        -- params.target:GetHealth() target health before damage from landed attack
        --print (params.target:GetName() .. " " .. tostring(params.target:IsAlive()) .. " " .. tostring(params.target:GetHealth()) )
    end
end
-- OnTakeDamage after damage is dealt/taken
function modifier_damage_tracking:OnTakeDamage(params)
    if not IsServer() then
        return
    end
    if params.attacker == self:GetParent() then
        --print ( "modifier_damage_tracking:OnTakeDamage attacker")
        --print (tostring(params.damage) .. " " .. tostring(params.original_damage))
        --print (params.unit:GetClassname())
        --print (params.unit:GetName() .. " " .. tostring(params.unit:IsAlive()) .. " " .. tostring(params.unit:GetHealth()) )
        if GameRules.herodemo.m_bShowTargetHealthPostAttack == true then
            SendOverheadEventMessage(nil, 6, params.unit, params.unit:GetHealth(), nil)
        end
        if GameRules.herodemo.m_bShowDamageDealt == true then
            SendOverheadEventMessage(nil, 10, params.unit, params.damage, nil)
        end
        ----printTable(params, " ")
        
        local playerID = params.attacker:GetPlayerOwnerID()
        local m_tPlayerDPS = GameRules.herodemo.m_tPlayerDPS
        m_tPlayerDPS[playerID] = m_tPlayerDPS[playerID] + params.damage
        CustomNetTables:SetTableValue( "la_nettable", tostring(playerID), { value = params.damage } )
        local total_damage = CustomNetTables:GetTableValue( "td_nettable", tostring(playerID)).value + params.damage
        CustomNetTables:SetTableValue( "td_nettable", tostring(playerID), { value = total_damage } )
    end
    if params.unit == self:GetParent() then
        local playerID = params.unit:GetPlayerOwnerID()
        CustomNetTables:SetTableValue( "dt_nettable", tostring(playerID), { value = params.damage } )
        local total_damage = CustomNetTables:GetTableValue( "tdt_nettable", tostring(playerID)).value + params.damage
        CustomNetTables:SetTableValue( "tdt_nettable", tostring(playerID), { value = total_damage } )
    end
end
--think callback timer callback function
function modifier_damage_tracking:OnIntervalThink()
    if not IsServer() then
        return
    end
    ----print ( "modifier_damage_tracking:OnIntervalThink")
end
--return modifier's texture name returns the Buff icon resource name (here with Abaddon first skill icon)
--[[function modifier_damage_tracking:GetTexture()
    return "abaddon_death_coil"
end]]
--return modifier's effect name carries the Buff effect
--[[function modifier_damage_tracking:GetEffectName()
    return "particles / generic_gameplay / generic_stunned.vpcf"
end]]
--effect attached position the Buff effect attachment position
function modifier_damage_tracking:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_damage_tracking:IsHidden()
    return true
end