require( "modifier_range_base" )

modifier_range_creep_aggro = class({}, {}, modifier_range_base)

function modifier_range_creep_aggro:OnCreated(params)
    modifier_range_base.OnCreated(self, params)
    self._range = 500
    self._overlayName="CreepAggroRangeButtonPressed"
    self._showOwnerOnly = true
end
function modifier_range_creep_aggro:UpdateParticleForPlayer(i)
    modifier_range_base.UpdateParticleForPlayer(self, i)
end
function modifier_range_creep_aggro:OnIntervalThink()
    modifier_range_base.OnIntervalThink(self)
end
function modifier_range_creep_aggro:OnDestroy(params)
    modifier_range_base.OnDestroy(self, params)
end
function modifier_range_creep_aggro:RemoveOnDeath()
    return modifier_range_base.RemoveOnDeath(self)
end

function modifier_range_creep_aggro:IsAura()
	return true
end
function modifier_range_creep_aggro:GetAuraRadius()
	return self._range
end
function modifier_range_creep_aggro:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_range_creep_aggro:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP
end
function modifier_range_creep_aggro:GetModifierAura()
	return "modifier_target"
end