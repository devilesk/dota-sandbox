la_spawn_ally_at_target = class({})

--LinkLuaModifier( "lm_spawn_ally_at_target", LUA_MODIFIER_MOTION_NONE )

function la_spawn_ally_at_target:OnSpellStart()
	Msg( "la_spawn_ally_at_target:OnSpellStart\n")

	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( 0 )

	local vTargetPos = hPlayerHero:GetAbsOrigin()
	vTargetPos.z = 0
	Msg( tostring( vTargetPos ) .. "\n")
	table.insert( GameRules.herodemo.m_tAlliesList, CreateUnitByName( GameRules.herodemo.m_sSelectedHero, vTargetPos, true, nil, nil, GameRules.herodemo.m_nALLIES_TEAM ) )

	local hUnit = GameRules.herodemo.m_tAlliesList[ #GameRules.herodemo.m_tAlliesList ] -- the unit we want a handle on is in the last index of the table
	hUnit:SetControllableByPlayer( GameRules.herodemo.m_nPlayerID, false )
	FindClearSpaceForUnit( hUnit, vTargetPos, false )
	hUnit:Hold()
	hUnit:SetIdleAcquire( false )
	hUnit:SetAcquisitionRange( 0 )
  
  --hUnit:ModifyGold( 99999, true, 0 )
end

function la_spawn_ally_at_target:GetCastRange( vLocation, hTarget )
	Msg( "la_spawn_ally_at_target:GetCastRange\n" )
	return 5000
end