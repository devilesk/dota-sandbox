require( "modifier_range_base" )

modifier_range_xp = class({}, {}, modifier_range_base)

function modifier_range_xp:OnCreated(params)
    modifier_range_base.OnCreated(self, params)
    self._range = 1300
    self._overlayName="HeroXPRangeButtonPressed"
    self._showOwnerOnly = true
end
function modifier_range_xp:UpdateParticleForPlayer(i)
    modifier_range_base.UpdateParticleForPlayer(self, i)
end
function modifier_range_xp:OnIntervalThink()
    modifier_range_base.OnIntervalThink(self)
end
function modifier_range_xp:OnDestroy(params)
    modifier_range_base.OnDestroy(self, params)
end
function modifier_range_xp:RemoveOnDeath()
    return modifier_range_base.RemoveOnDeath(self)
end
function modifier_range_xp:IsHidden()
    return true
end