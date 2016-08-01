require( "modifier_range_base" )

modifier_range_blink = class({}, {}, modifier_range_base)

function modifier_range_blink:OnCreated(params)
    modifier_range_base.OnCreated(self, params)
    self._range = 1200
    self._overlayName="BlinkRangeButtonPressed"
    self._showOwnerOnly = true
end
function modifier_range_blink:UpdateParticleForPlayer(i)
    modifier_range_base.UpdateParticleForPlayer(self, i)
end
function modifier_range_blink:OnIntervalThink()
    modifier_range_base.OnIntervalThink(self)
end
function modifier_range_blink:OnDestroy(params)
    modifier_range_base.OnDestroy(self, params)
end
function modifier_range_blink:RemoveOnDeath()
    return modifier_range_base.RemoveOnDeath(self)
end