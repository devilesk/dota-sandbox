function ShowAttackDamage(event)
    --PrintTable( event, " " )
    if GameRules.herodemo.m_bShowUnreducedDamageDealt == true then
      SendOverheadEventMessage(event.caster:GetOwner(), 16, event.attacker, event.attack_damage, event.attacker:GetOwner())
    end
    --print (event.attack_damage)
end

function ShowDamageDealt(event)
    --PrintTable( event, " " )
    if GameRules.herodemo.m_bShowDamageDealt == true then
      SendOverheadEventMessage(event.caster:GetOwner(), 16, event.attacker, event.attack_damage, event.attacker:GetOwner())
    end
    
    --print (event.attack_damage)
    local player = event.caster:GetOwner()
    local playerID = player:GetPlayerID()
    local m_tPlayerDPS = GameRules.herodemo.m_tPlayerDPS
    m_tPlayerDPS[playerID] = m_tPlayerDPS[playerID] + event.attack_damage
end