--[[ Events ]]

--------------------------------------------------------------------------------
-- GameEvent:OnGameRulesStateChange
--------------------------------------------------------------------------------
function CHeroDemo:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	DebugPrint( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		DebugPrint( "OnGameRulesStateChange: Custom Game Setup" )
    GameRules:EnableCustomGameSetupAutoLaunch( false )
    
	elseif nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		DebugPrint( "OnGameRulesStateChange: Hero Selection" )
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
        self.towers = Entities:FindAllByClassname("npc_dota_tower")
        self.buildings = {}
        for _, v in pairs(self.towers) do
            table.insert(self.buildings, v)
        end
        for _, v in pairs(Entities:FindAllByClassname("npc_dota_building")) do
            table.insert(self.buildings, v)
        end
        for _, v in pairs(Entities:FindAllByClassname("npc_dota_barracks")) do
            table.insert(self.buildings, v)
        end
        for _, v in pairs(Entities:FindAllByClassname("npc_dota_fort")) do
            table.insert(self.buildings, v)
        end
        
        for _, v in pairs(self.buildings) do
            if IsValidEntity(v) and v:IsAlive() then
                v:AddNewModifier(v, nil, "modifier_fountain_glyph", {duration = -1})
            end
        end
    if GameRules:IsCheatMode() then
        SendToServerConsole( "sv_cheats 1" )
    else
        CustomUI:DynamicHud_Create(-1, "cheat-popup-prompt", "file://{resources}/layout/custom_game/cheat_popup.xml", nil)
    end
		DebugPrint( "OnGameRulesStateChange: Pre Game Selection" )
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		DebugPrint( "OnGameRulesStateChange: Game In Progress" )
	end
end

--------------------------------------------------------------------------------
-- GameEvent: OnNPCSpawned
--------------------------------------------------------------------------------
function CHeroDemo:OnNPCSpawned( event )
	spawnedUnit = EntIndexToHScript( event.entindex )
    --DebugPrint ("spawnedUnit " .. tostring(spawnedUnit:GetPlayerOwnerID()))
    if spawnedUnit:GetPlayerOwnerID() >= 0 then
        DebugPrint ("spawnedUnit " .. spawnedUnit:GetName())
        spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_damage_tracking", {duration = -1})
    end
	if spawnedUnit:GetPlayerOwnerID() == 0 and spawnedUnit:IsRealHero() and not spawnedUnit:IsClone() then
		DebugPrint( "spawnedUnit is player's hero" )
		local hPlayerHero = spawnedUnit
        self.m_bPlayerDataCaptured = false
		hPlayerHero:SetContextThink( "self:Think_InitializePlayerHero", function() return self:Think_InitializePlayerHero( hPlayerHero ) end, 0 )
	end

	if spawnedUnit:GetUnitName() == "npc_dota_neutral_caster" then
		DebugPrint( "Neutral Caster spawned" )
		spawnedUnit:SetContextThink( "self:Think_InitializeNeutralCaster", function() return self:Think_InitializeNeutralCaster( spawnedUnit ) end, 0 )
	end
end

--------------------------------------------------------------------------------
-- GameEvent: OnQuit
--------------------------------------------------------------------------------
function CHeroDemo:OnQuit( event )
    DebugPrint("OnQuit")
    GameRules:Defeated()
    GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
end

--------------------------------------------------------------------------------
-- GameEvent: OnPlayerConnect
--------------------------------------------------------------------------------
function CHeroDemo:OnPlayerConnect( event )
    DebugPrint("OnPlayerConnect")
    DebugPrintTable(event, " ")
    --[[if event.bot == 1 then
    end]]
end

--------------------------------------------------------------------------------
-- GameEvent: OnPlayerFullyJoined
--------------------------------------------------------------------------------
function CHeroDemo:OnPlayerFullyJoined( event )
	DebugPrintTable(event, " ")
end

--------------------------------------------------------------------------------
-- Think_InitializePlayerHero
--------------------------------------------------------------------------------
function CHeroDemo:Think_InitializePlayerHero( hPlayerHero )
	if not hPlayerHero then
		return 0.1
	end
    
	if self.m_bPlayerDataCaptured == false then   
    self.m_bPlayerDataCaptured = true
	end

	if self.m_bInvulnerabilityEnabled then
		local hAllPlayerUnits = {}
		hAllPlayerUnits = hPlayerHero:GetAdditionalOwnedUnits()
		hAllPlayerUnits[ #hAllPlayerUnits + 1 ] = hPlayerHero

		for _, hUnit in pairs( hAllPlayerUnits ) do
            hUnit:SetHealth(hUnit:GetMaxHealth())
		end
	end

	return
end

--------------------------------------------------------------------------------
-- Think_InitializeNeutralCaster
--------------------------------------------------------------------------------
function CHeroDemo:Think_InitializeNeutralCaster( neutralCaster )
	if not neutralCaster then
		return 0.1
	end

	DebugPrint( "neutralCaster:AddAbility( \"la_spawn_enemy_at_target\" )" )
	neutralCaster:AddAbility( "la_spawn_enemy_at_target" )
    DebugPrint( "neutralCaster:AddAbility( \"la_spawn_ally_at_target\" )" )
	neutralCaster:AddAbility( "la_spawn_ally_at_target" )
	return
end

--------------------------------------------------------------------------------
-- GameEvent: OnGiveItemsToAlliesButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnGiveItemsToAlliesButtonPressed( event )
	if self.m_bGiveItemsToAllies == false then
		self.m_bGiveItemsToAllies = true
        self:BroadcastMsg( "#GiveItemsToAlliesOn_Msg" )
	elseif self.m_bGiveItemsToAllies == true then
		self.m_bGiveItemsToAllies = false
		self:BroadcastMsg( "#GiveItemsToAlliesOff_Msg" )
	end	
end

--------------------------------------------------------------------------------
-- GameEvent: OnGiveItemsToEnemiesButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnGiveItemsToEnemiesButtonPressed( event )
	if self.m_bGiveItemsToEnemies == false then
		self.m_bGiveItemsToEnemies = true
        self:BroadcastMsg( "#GiveItemsToEnemiesOn_Msg" )
	elseif self.m_bGiveItemsToEnemies == true then
		self.m_bGiveItemsToEnemies = false
		self:BroadcastMsg( "#GiveItemsToEnemiesOff_Msg" )
	end	
end

--------------------------------------------------------------------------------
-- GameEvent: OnItemPurchased
--------------------------------------------------------------------------------
function CHeroDemo:OnItemPurchased( event )
	local hBuyer = PlayerResource:GetPlayer( event.PlayerID )
	local hBuyerHero = hBuyer:GetAssignedHero()
	hBuyerHero:ModifyGold( event.itemcost, true, 0 )
  
    if self.m_bGiveItemsToAllies == true then
        for k, v in pairs( self.m_tAlliesList ) do
            local item = CreateItem(event.itemname, self.m_tAlliesList[ k ], self.m_tAlliesList[ k ])
            self.m_tAlliesList[ k ]:AddItem(item)
        end
    end
    if self.m_bGiveItemsToEnemies == true then
        for k, v in pairs( self.m_tEnemiesList ) do
            local item = CreateItem(event.itemname, self.m_tEnemiesList[ k ], self.m_tEnemiesList[ k ])
            self.m_tEnemiesList[ k ]:AddItem(item)
        end
    end
end

--------------------------------------------------------------------------------
-- GameEvent: OnSelectNewHeroButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnSelectNewHeroButtonPressed( event )
    GameRules:ResetToHeroSelection()
end

--------------------------------------------------------------------------------
-- GameEvent: OnShowDamageDealtButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnShowDamageDealtButtonPressed( event, data )
	if self.m_bShowDamageDealt[data.PlayerID] == false then
		self.m_bShowDamageDealt[data.PlayerID] = true
		self:BroadcastMsg( "#ShowDamageDealtOn_Msg" )
	elseif self.m_bShowDamageDealt[data.PlayerID] == true then
		self.m_bShowDamageDealt[data.PlayerID] = false
		self:BroadcastMsg( "#ShowDamageDealtOff_Msg" )
	end	
end

--------------------------------------------------------------------------------
-- GameEvent: OnShowTargetHealthPreAttackButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnShowTargetHealthPreAttackButtonPressed( event, data )
	if self.m_bShowTargetHealthPreAttack[data.PlayerID] == false then
		self.m_bShowTargetHealthPreAttack[data.PlayerID] = true
		self:BroadcastMsg( "#ShowTargetHealthPreAttackOn_Msg" )
	elseif self.m_bShowTargetHealthPreAttack[data.PlayerID] == true then
		self.m_bShowTargetHealthPreAttack[data.PlayerID] = false
		self:BroadcastMsg( "#ShowTargetHealthPreAttackOff_Msg" )
	end	
end

--------------------------------------------------------------------------------
-- GameEvent: OnShowTargetHealthPostAttackButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnShowTargetHealthPostAttackButtonPressed( event, data )
	if self.m_bShowTargetHealthPostAttack[data.PlayerID] == false then
		self.m_bShowTargetHealthPostAttack[data.PlayerID] = true
		self:BroadcastMsg( "#ShowTargetHealthPostAttackOn_Msg" )
	elseif self.m_bShowTargetHealthPostAttack[data.PlayerID] == true then
		self.m_bShowTargetHealthPostAttack[data.PlayerID] = false
		self:BroadcastMsg( "#ShowTargetHealthPostAttackOff_Msg" )
	end	
end

--------------------------------------------------------------------------------
-- GameEvent: OnNPCReplaced
--------------------------------------------------------------------------------
function CHeroDemo:OnNPCReplaced( event )
	local sNewHeroName = PlayerResource:GetSelectedHeroName( event.new_entindex )
	DebugPrint( "sNewHeroName == " .. sNewHeroName ) -- we fail to get in here
	self:BroadcastMsg( "Changed hero to " .. sNewHeroName )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnWelcomePanelDismissed
--------------------------------------------------------------------------------
function CHeroDemo:OnWelcomePanelDismissed( event )
	DebugPrint( "Entering CHeroDemo:OnWelcomePanelDismissed( event )" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnRefreshButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnRefreshButtonPressed( eventSourceIndex, data )
    --SendToServerConsole( "dota_dev hero_refresh" )
    --RefreshAllUnits(self.m_tAlliesList, self.m_tEnemiesList, true, true, true)
    for key,entIndex in pairs(data.selectedUnits) do
        DebugPrint(key,entIndex)
        local ent = EntIndexToHScript(entIndex)
        if ent:IsHero() then
            RefreshUnit(ent, true, true, true)
        end
    end
	self:BroadcastMsg( "#Refresh_Msg" )
end

function RefreshAllUnits(m_tAlliesList, m_tEnemiesList, bHealth, bMana, bCooldowns)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(0)
    if hPlayerHero ~= nil then
        RefreshUnit(hPlayerHero, bHealth, bMana, bCooldowns)
    end
    for k, v in pairs( m_tAlliesList ) do
        RefreshUnit(m_tAlliesList[ k ], bHealth, bMana, bCooldowns)
    end
    for k, v in pairs( m_tEnemiesList ) do
        RefreshUnit(m_tEnemiesList[ k ], bHealth, bMana, bCooldowns)
    end
end

function RefreshUnit(hUnit, bHealth, bMana, bCooldowns)
    if bHealth == true then
        hUnit:SetHealth(hUnit:GetMaxHealth())
    end
    if bMana == true then
        hUnit:SetMana(hUnit:GetMaxMana())
    end
    if bCooldowns == true then
        RefreshUnitCooldowns(hUnit)
    end

    if hUnit:IsHero() and hUnit:GetClassname() == "npc_dota_hero_meepo" and not hUnit:IsClone() then
        for k, clone in pairs(Entities:FindAllByClassname("npc_dota_hero_meepo")) do
            if clone:IsClone() and clone:GetCloneSource() == hUnit then
                RefreshUnit(clone, bHealth, bMana, bCooldowns)
            end
        end
    end
end

function RefreshUnitCooldowns(hUnit)
    for i = 0, 5 do
        local item = hUnit:GetItemInSlot(i)
        if item ~= nil then
            item:EndCooldown()
        end
    end
    for i = 0, DOTA_MAX_ABILITIES - 1 do
        local hAbility = hUnit:GetAbilityByIndex( i )
        if hAbility and hAbility:GetLevel() > 0 and not hAbility:IsHidden() then
            hAbility:EndCooldown()
        end
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnRefreshAllButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnRefreshAllButtonPressed( eventSourceIndex, data )
    if GameRules:IsCheatMode() then
        SendToServerConsole( "dota_dev hero_refresh" )
    end
	self:BroadcastMsg( "#RefreshAll_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnLevelUpButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnLevelUpButtonPressed( eventSourceIndex, data )
    --SendToServerConsole( "dota_dev hero_level 1" )
    --local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
    --hPlayerHero:HeroLevelUp( true )
    for key,entIndex in pairs(data.selectedUnits) do
        DebugPrint(key,entIndex)
        local ent = EntIndexToHScript(entIndex)
        if ent:IsHero() then
            ent:HeroLevelUp( true )
        end
    end

    --[[DebugPrint (hPlayerHero:GetCurrentXP() .."")
    hPlayerHero:AddExperience( 10400, false, false )
    DebugPrint (hPlayerHero:GetCurrentXP() .."")]]
    self:BroadcastMsg( "#LevelUp_Msg" )

  
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnMaxLevelButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnMaxLevelButtonPressed( eventSourceIndex, data )
    for key,entIndex in pairs(data.selectedUnits) do
        DebugPrint(key,entIndex)
        local ent = EntIndexToHScript(entIndex)
        if ent:IsHero() then
            LevelHeroToMax(ent)
        end
    end
    self:BroadcastMsg( "#MaxLevel_Msg" )
end

function LevelHeroToMax( hPlayerHero )
	hPlayerHero:AddExperience( 32400, false, false ) -- for some reason maxing your level this way fixes the bad interaction with OnHeroReplaced
	--while hPlayerHero:GetLevel() < 25 do
		--hPlayerHero:HeroLevelUp( false )
	--end

	for i = 0, DOTA_MAX_ABILITIES - 1 do
		local hAbility = hPlayerHero:GetAbilityByIndex( i )
		if hAbility and hAbility:CanAbilityBeUpgraded () == ABILITY_CAN_BE_UPGRADED and not hAbility:IsHidden() then
			while hAbility:GetLevel() < hAbility:GetMaxLevel() do
				hPlayerHero:UpgradeAbility( hAbility )
			end
		end
	end

	hPlayerHero:SetAbilityPoints( 0 )
	
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnFreeSpellsButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnFreeSpellsButtonPressed( eventSourceIndex )
	--SendToServerConsole( "toggle dota_ability_debug" )
	if self.m_bFreeSpellsEnabled == false then
		self.m_bFreeSpellsEnabled = true
		--SendToServerConsole( "dota_dev hero_refresh" )
        if GameRules:IsCheatMode() then
            SendToServerConsole( "dota_ability_debug 1" )
        end
		self:BroadcastMsg( "#FreeSpellsOn_Msg" )
	elseif self.m_bFreeSpellsEnabled == true then
		self.m_bFreeSpellsEnabled = false
        if GameRules:IsCheatMode() then
            SendToServerConsole( "dota_ability_debug 0" )
        end
		self:BroadcastMsg( "#FreeSpellsOff_Msg" )
	end
    self:UpdateToggleUI()
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnInvulnerabilityButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnInvulnerabilityButtonPressed( eventSourceIndex, data )
	--[[local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	local hAllPlayerUnits = {}
	hAllPlayerUnits = hPlayerHero:GetAdditionalOwnedUnits()
	hAllPlayerUnits[ #hAllPlayerUnits + 1 ] = hPlayerHero]]

	if self.m_bInvulnerabilityEnabled == false then
		self.m_bInvulnerabilityEnabled = true
		self:BroadcastMsg( "#InvulnerabilityOn_Msg" )
	elseif self.m_bInvulnerabilityEnabled == true then
		self.m_bInvulnerabilityEnabled = false
		self:BroadcastMsg( "#InvulnerabilityOff_Msg" )
	end
    self:UpdateToggleUI()
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnLevelUpAllyButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnLevelUpAllyButtonPressed( eventSourceIndex )
    if GameRules:IsCheatMode() then
        for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:GetTeam(nPlayerID) == self.m_nALLIES_TEAM and PlayerResource:GetConnectionState(nPlayerID) == 1 then
                local hPlayerHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                if hPlayerHero ~= nil and hPlayerHero:IsHero() then
                    hPlayerHero:HeroLevelUp( true )
                end
            end
        end
    else
        for k, v in pairs( self.m_tAlliesList ) do
            self.m_tAlliesList[ k ]:HeroLevelUp( false )
        end
    end

	self:BroadcastMsg( "#LevelUpAlly_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnLevelUpEnemyButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnLevelUpEnemyButtonPressed( eventSourceIndex )
    if GameRules:IsCheatMode() then
        for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:GetTeam(nPlayerID) == self.m_nENEMIES_TEAM and PlayerResource:GetConnectionState(nPlayerID) == 1 then
                local hPlayerHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                if hPlayerHero ~= nil and hPlayerHero:IsHero() then
                    hPlayerHero:HeroLevelUp( true )
                end
            end
        end
    else
        for k, v in pairs( self.m_tEnemiesList ) do
            self.m_tEnemiesList[ k ]:HeroLevelUp( false )
        end
    end
    
	self:BroadcastMsg( "#LevelUpEnemy_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnDummyTargetsButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnDummyTargetsButtonPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	self.m_nDummiesCount = self.m_nDummiesCount + 1
	DebugPrint( "Dummy team count is now: " .. self.m_nDummiesCount )
	self.m_tDummiesList[ self.m_nDummiesCount ] = CreateUnitByName( "target_dummy", hPlayerHero:GetAbsOrigin(), true, nil, nil, self.m_nDUMMIES_TEAM )
	local hUnit = self.m_tDummiesList[ self.m_nDummiesCount ]
	hUnit:SetControllableByPlayer( self.m_nPlayerID, false )
	FindClearSpaceForUnit( hUnit, hPlayerHero:GetAbsOrigin(), false )
	hUnit:Hold()
	hUnit:SetIdleAcquire( false )
	hUnit:SetAcquisitionRange( 0 )
	self:BroadcastMsg( "#SpawnDummyTarget_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnDummyTargetButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnDummyTargetButtonPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	table.insert( self.m_tEnemiesList, CreateUnitByName( "npc_dota_hero_target_dummy", hPlayerHero:GetAbsOrigin(), true, nil, nil, self.m_nENEMIES_TEAM ) )
	local hDummy = self.m_tEnemiesList[ #self.m_tEnemiesList ]
	hDummy:SetAbilityPoints( 0 )
	hDummy:SetControllableByPlayer( self.m_nPlayerID, false )
	hDummy:Hold()
	hDummy:SetIdleAcquire( false )
	hDummy:SetAcquisitionRange( 0 )
	self:BroadcastMsg( "#SpawnDummyTarget_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnRemoveSpawnedUnitsButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnRemoveSpawnedUnitsButtonPressed( eventSourceIndex )
	DebugPrint( "Entering CHeroDemo:OnRemoveSpawnedUnitsButtonPressed( eventSourceIndex )" )
	DebugPrintTable( self.m_tAlliesList, " " )
	for k, v in pairs( self.m_tAlliesList ) do
		self.m_tAlliesList[ k ]:Destroy()
		self.m_tAlliesList[ k ] = nil
	end
	DebugPrintTable( self.m_tEnemiesList, " " )
	for k, v in pairs( self.m_tEnemiesList ) do
		self.m_tEnemiesList[ k ]:Destroy()
		self.m_tEnemiesList[ k ] = nil
	end
	DebugPrintTable( self.m_tDummiesList, " " )
	for k, v in pairs( self.m_tDummiesList ) do
		self.m_tDummiesList[ k ]:Destroy()
		self.m_tDummiesList[ k ] = nil
	end

	self.m_nAlliesCount = 0
	self.m_nEnemiesCount = 0
	self.m_nDummiesCount = 0

	self:BroadcastMsg( "#RemoveSpawnedUnits_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSwitchTeamButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnSwitchTeamButtonPressed( eventSourceIndex, data )
    if PlayerResource:GetPlayerCountForTeam(self.m_nENEMIES_TEAM) >= 5 then
        self:BroadcastMsg( "#SwitchTeamFail_Msg" )
    else
        local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
        hero:SetTeam(self.m_nENEMIES_TEAM)
        PlayerResource:SetCustomTeamAssignment(data.PlayerID, self.m_nENEMIES_TEAM)
        CustomGameEventManager:Send_ServerToAllClients("update_scoreboard", {} )
        self:BroadcastMsg( "#SwitchTeam_Msg" )
        
        local mode = GameRules:GetGameModeEntity()
        mode:SetFogOfWarDisabled(not self.m_bFOWDisabled)
        Timers:CreateTimer(0.5, function()
            mode:SetFogOfWarDisabled(self.m_bFOWDisabled)
            return nil
        end)
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnResetPlayerStatsButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnResetPlayerStatsButtonPressed( eventSourceIndex, data )
    local selectedPlayerID = tonumber(data.selectedPlayerID)
    if selectedPlayerID ~= nil then
        CustomNetTables:SetTableValue( "dt_nettable", tostring(selectedPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "tdt_nettable", tostring(selectedPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "td_nettable", tostring(selectedPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "la_nettable", tostring(selectedPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "dps_nettable", tostring(selectedPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "dps10_nettable", tostring(selectedPlayerID), { value = 0 } )
        PlayerResource:ResetTotalEarnedGold(selectedPlayerID)
        self.m_tPlayerDPS[selectedPlayerID] = 0
        self.m_tPlayerDPS10[selectedPlayerID] = Queue()
        self:BroadcastMsg( "#ResetPlayerStats_Msg" )
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnGiveGoldButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnGiveGoldButtonPressed( eventSourceIndex, data )
    local goldAmount = tonumber(data.goldAmount)
    if goldAmount ~= nil then
        PlayerResource:SetGold( data.PlayerID, PlayerResource:GetUnreliableGold(data.PlayerID) + tonumber(data.goldAmount), false)
        self:BroadcastMsg( "#GiveGold_Msg" )
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnResetGoldButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnResetGoldButtonPressed( eventSourceIndex, data )
    PlayerResource:SetGold( data.PlayerID, 0, true)
    PlayerResource:SetGold( data.PlayerID, 0, false)
    self:BroadcastMsg( "#ResetGold_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnPassiveGoldButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnPassiveGoldButtonPressed( eventSourceIndex, data )
	if self.m_bPassiveGoldDisabled == false then
		self.m_bPassiveGoldDisabled = true
        GameRules:SetGoldPerTick(0)
		self:BroadcastMsg( "#PassiveGoldOff_Msg" )
	elseif self.m_bPassiveGoldDisabled == true then
		self.m_bPassiveGoldDisabled = false
        GameRules:SetGoldPerTick(1)
		self:BroadcastMsg( "#PassiveGoldOn_Msg" )
	end
    self:UpdateToggleUI()
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnLaneCreepsButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnLaneCreepsButtonPressed( eventSourceIndex )
	if self.m_bCreepsDisabled == false then
		self.m_bCreepsDisabled = true
		-- if we're disabling creep spawns, then also kill existing creep waves
		SendToServerConsole( "dota_kill_creeps radiant" )
		SendToServerConsole( "dota_kill_creeps dire" )
        SendToServerConsole( "dota_creeps_no_spawning 1" )
		self:BroadcastMsg( "#LaneCreepsOff_Msg" )
	elseif self.m_bCreepsDisabled == true then
        SendToServerConsole( "dota_creeps_no_spawning 0" )
		self.m_bCreepsDisabled = false
		self:BroadcastMsg( "#LaneCreepsOn_Msg" )
	end
    self:UpdateToggleUI()
end

--------------------------------------------------------------------------------
-- GameEvent: OnChangeCosmeticsButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnChangeCosmeticsButtonPressed( eventSourceIndex )
	-- currently running the command directly in XML, should run it here if possible
	-- can use GetSelectedHeroID
end

--------------------------------------------------------------------------------
-- GameEvent: OnChangeHeroButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnChangeHeroButtonPressed( eventSourceIndex, data )
    -- currently running the command directly in XML, should run it here if possible
    local nHeroID = PlayerResource:GetSelectedHeroID( data.pID )
    if nHeroID == -1 then
        CreateHeroForPlayer(data.selectedHero, PlayerResource:GetPlayer(data.pID))
    else
        PlayerResource:ReplaceHeroWith(data.pID, data.selectedHero, PlayerResource:GetGold(data.pID), 0)
    end
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "select_hero", {entId=PlayerResource:GetSelectedHeroEntity(data.pID):GetEntityIndex()} )

end

--------------------------------------------------------------------------------
-- GameEvent: OnShopItemButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnShopItemButtonPressed( eventSourceIndex, data )
    DebugPrint ("data.pID", data.pID)
    DebugPrint ("data.item", data.item)
    local hero = PlayerResource:GetSelectedHeroEntity(data.pID)
    local item = CreateItem(data.item, hero, hero)
    hero:AddItem(item)
end

--------------------------------------------------------------------------------
-- GameEvent: OnStartGameButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnStartGameButtonPressed( eventSourceIndex )
	SendToServerConsole( "dota_dev forcegamestart" )
    self:BroadcastMsg( "#StartGame_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnPauseButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnPauseButtonPressed( eventSourceIndex )
	SendToServerConsole( "dota_pause" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnLeaveButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnLeaveButtonPressed( eventSourceIndex )
	SendToServerConsole( "disconnect" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnAllyButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnSpawnAllyButtonPressed( eventSourceIndex, data )
    CHeroDemo.OnTargetButtonPress(self, eventSourceIndex, data)
end

function CHeroDemo:OnSpawnAllyButtonPressedHandler( eventSourceIndex, data )
	if self.m_nAlliesCount >= 100 then
		DebugPrint( "#self.m_tAlliesList == " .. #self.m_tAlliesList )

		self:BroadcastMsg( "#MaxAllies_Msg" )
		return
	end

    if GameRules:IsCheatMode() then
        if PlayerResource:GetPlayerCountForTeam(self.m_nALLIES_TEAM) < 5 then
            SendToServerConsole("dota_create_unit " .. data.selectedHero)
        else
            self:BroadcastMsg( "#MaxAllies_Msg" )
        end
    else
        self.m_sSelectedHero = data.selectedHero
        
        local hAbility = self._hNeutralCaster:FindAbilityByName( "la_spawn_ally_at_target" )
        self._hNeutralCaster:CastAbilityImmediately( hAbility, -1 )
        self.m_nAlliesCount = self.m_nAlliesCount + 1
        local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
        local hAbilityTestSearch = hPlayerHero:FindAbilityByName( "la_spawn_ally_at_target" )
        if hAbilityTestSearch then -- Testing whether AddAbility worked successfully on the lua-based ability
            DebugPrint( "hPlayerHero:AddAbility( \"la_spawn_ally_at_target\" ) was successful" )
        end
    end
	self:BroadcastMsg( "#SpawnAlly_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: SpawnEnemyButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnSpawnEnemyButtonPressed( eventSourceIndex, data )
    CHeroDemo.OnTargetButtonPress(self, eventSourceIndex, data)
end

function CHeroDemo:OnSpawnEnemyButtonPressedHandler( eventSourceIndex, data )
    DebugPrint ("GetPlayerCountForTeam", PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS))
	if self.m_nEnemiesCount >= 100 then
		DebugPrint( "#self.m_tEnemiesList == " .. #self.m_tEnemiesList )

		self:BroadcastMsg( "#MaxEnemies_Msg" )
		return
	end

    if GameRules:IsCheatMode() then
        if PlayerResource:GetPlayerCountForTeam(self.m_nENEMIES_TEAM) < 5 then
            SendToServerConsole("dota_create_unit " .. data.selectedHero .. " enemy")
        else
            self:BroadcastMsg( "#MaxEnemies_Msg" )
        end
    else
        self.m_sSelectedHero = data.selectedHero
        
        local hAbility = self._hNeutralCaster:FindAbilityByName( "la_spawn_enemy_at_target" )
        self._hNeutralCaster:CastAbilityImmediately( hAbility, -1 )
        self.m_nEnemiesCount = self.m_nEnemiesCount + 1
        local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
        local hAbilityTestSearch = hPlayerHero:FindAbilityByName( "la_spawn_enemy_at_target" )
        if hAbilityTestSearch then -- Testing whether AddAbility worked successfully on the lua-based ability
            DebugPrint( "hPlayerHero:AddAbility( \"la_spawn_enemy_at_target\" ) was successful" )
        end
	end

	self:BroadcastMsg( "#SpawnEnemy_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnClearInventoryButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnClearInventoryButtonPressed( eventSourceIndex, data )
    for key,entIndex in pairs(data.selectedUnits) do
        DebugPrint(key,entIndex)
        local ent = EntIndexToHScript(entIndex)
        if ent:IsHero() then
            for i = 0, 11 do
                local item = ent:GetItemInSlot(i)
                if item ~= nil then
                    ent:RemoveItem(item);
                end
            end
        end
    end
    self:BroadcastMsg( "#ClearInventory_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnRespawnHeroButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnRespawnHeroButtonPressed( eventSourceIndex, data )
    for key,entIndex in pairs(data.selectedUnits) do
        DebugPrint(key,entIndex)
        local ent = EntIndexToHScript(entIndex)
        if ent:IsHero() and PlayerResource:GetRespawnSeconds(ent:GetPlayerOwnerID()) > 0 then
            ent:RespawnHero(false, false, false)
        end
    end
    self:BroadcastMsg( "#RespawnHero_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnTeleportButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnTeleportButtonPressed( eventSourceIndex, data )
	DebugPrint( "teleport hero" )
    CHeroDemo.OnTargetButtonPress(self, eventSourceIndex, data)
end

function CHeroDemo:OnTeleportButtonPressedHandler( eventSourceIndex, data )
    for key,value in pairs(data.pos) do DebugPrint(key,value) end
    DebugPrint (data.pos.x)

    for key,entIndex in pairs(data.selectedUnits) do
        DebugPrint(key,entIndex)
        local ent = EntIndexToHScript(entIndex)
        local point = GetGroundPosition(Vector(data.pos.x, data.pos.y, 0), nil)
        FindClearSpaceForUnit(ent, point, false)
        -- Stop the hero, so he doesn't move
        ent:Stop()
        SendToConsole("dota_camera_center")
    end
end

function CHeroDemo:OnTargetButtonPress( eventSourceIndex, data )
    DebugPrint( "OnTargetButtonPress" )
    DeepDebugPrintTable(data)
    self.m_tCurrentMouseClick[data.PlayerID] = {
        data = data,
        eventSourceIndex = eventSourceIndex
    }
end

--------------------------------------------------------------------------------
-- GameEvent: OnMouseClick
--------------------------------------------------------------------------------
function CHeroDemo:OnMouseClick( eventSourceIndex, data )
    if self.m_tCurrentMouseClick[data.PlayerID] ~= nil then
        local clickEvent = self.m_tCurrentMouseClick[data.PlayerID].data.eventName
        if clickEvent == "TeleportButtonPressed" then
            CHeroDemo.OnTeleportButtonPressedHandler(self, eventSourceIndex, data)
        elseif clickEvent == "SpawnAllyButtonPressed" then
            data.selectedHero = self.m_tCurrentMouseClick[data.PlayerID].data.selectedHero
            CHeroDemo.OnSpawnAllyButtonPressedHandler(self, eventSourceIndex, data)
        elseif clickEvent == "SpawnEnemyButtonPressed" then
            data.selectedHero = self.m_tCurrentMouseClick[data.PlayerID].data.selectedHero
            CHeroDemo.OnSpawnEnemyButtonPressedHandler(self, eventSourceIndex, data)
        end
        self.m_tCurrentMouseClick[data.PlayerID] = nil
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnInstantRespawnEnabledButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnInstantRespawnEnabledButtonPressed( eventSourceIndex )
	if self.m_bInstantRespawnEnabled == false then
		self.m_bInstantRespawnEnabled = true
        self:BroadcastMsg( "#InstantRespawnEnabledOn_Msg" )
	else
		self.m_bInstantRespawnEnabled = false
        self:BroadcastMsg( "#InstantRespawnEnabledOff_Msg" )
	end
    local mode = GameRules:GetGameModeEntity()
    if self.m_bInstantRespawnEnabled then
        mode:SetFixedRespawnTime(0)
    else
        mode:SetFixedRespawnTime(-1)
    end
    self:UpdateToggleUI()
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnFOWButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnFOWButtonPressed( eventSourceIndex )
	if self.m_bFOWDisabled == false then
		self.m_bFOWDisabled = true
        self:BroadcastMsg( "#FOWOff_Msg" )
	else
		self.m_bFOWDisabled = false
        self:BroadcastMsg( "#FOWOn_Msg" )
	end
    local mode = GameRules:GetGameModeEntity()      
    mode:SetFogOfWarDisabled(self.m_bFOWDisabled)
    self:UpdateToggleUI()
end

--------------------------------------------------------------------------------
-- GameEvent: OnRemoveWardsButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnRemoveWardsButtonPressed( eventSourceIndex )
	--SendToServerConsole("dota_dev killwards")
    if GameRules:IsCheatMode() then
        SendToServerConsole("dota_dev killwards")
    else
        local wards = Entities:FindAllByClassname("npc_dota_ward_base")
        local sentries = Entities:FindAllByClassname("npc_dota_ward_base_truesight")
        if wards ~= nil then
            for k,ent in pairs(wards) do
                ent:RemoveSelf()
            end
        end
        if sentries ~= nil then
            for k,ent in pairs(sentries) do
                ent:RemoveSelf()
            end
        end
    end
    self:BroadcastMsg( "#RemoveWards_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnNeutralSpawnIntervalChange
--------------------------------------------------------------------------------
function CHeroDemo:OnNeutralSpawnIntervalChange( eventSourceIndex, data )
    SendToServerConsole("dota_neutral_spawn_interval " .. data.value)
    self:BroadcastMsg( "#NeutralSpawnInterval_Msg" )
    CustomGameEventManager:Send_ServerToAllClients("update_neutral_spawn_interval_ui", data )
end

--------------------------------------------------------------------------------
-- GameEvent: OnSpawnNeutralsButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnSpawnNeutralsButtonPressed( eventSourceIndex, data )
	SendToServerConsole("dota_spawn_neutrals")
    self:BroadcastMsg( "#SpawnNeutrals_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnHostTimeScaleChange
--------------------------------------------------------------------------------
function CHeroDemo:OnHostTimeScaleChange( eventSourceIndex, data )
    DebugPrint ("host_timescale " .. data.value)
	SendToServerConsole("host_timescale " .. data.value)
    self:BroadcastMsg( "#HostTimeScale_Msg" )
    CustomGameEventManager:Send_ServerToAllClients("update_host_time_scale_ui", data )
end

--------------------------------------------------------------------------------
-- GameEvent: OnRegrowTreesButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnRegrowTreesButtonPressed( eventSourceIndex, data )
	GridNav:RegrowAllTrees()
    self:BroadcastMsg( "#RegrowTrees_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnSpawnCreepsButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnSpawnCreepsButtonPressed( eventSourceIndex, data )
	SendToServerConsole("dota_spawn_creeps")
    self:BroadcastMsg( "#SpawnCreeps_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnSpawnRunesButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnSpawnRunesButtonPressed( eventSourceIndex, data )
	SendToServerConsole("dota_spawn_rune")
    self:BroadcastMsg( "#SpawnRunes_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnIncrementTimeOfDayButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnIncrementTimeOfDayButtonPressed( eventSourceIndex, data )
	GameRules:SetTimeOfDay(GameRules:GetTimeOfDay() + .1)
    self:BroadcastMsg( "#IncrementTimeOfDay_Msg" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnResetHeroButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnResetHeroButtonPressed( eventSourceIndex, data )
    for key,entIndex in pairs(data.selectedUnits) do
        DebugPrint(key,entIndex)
        local ent = EntIndexToHScript(entIndex)
        if ent:IsHero() and not ent:IsClone() then
            ResetHero(ent)
            local owner = ent:GetPlayerOwnerID()
            local hero = PlayerResource:ReplaceHeroWith(owner, PlayerResource:GetSelectedHeroName(owner), PlayerResource:GetGold(owner), 0)
            ResetHero(hero)
        end
    end
    self:BroadcastMsg( "#ResetHero_Msg" )
end

function ResetHero( hPlayerHero )
    for i = 0, DOTA_MAX_ABILITIES - 1 do
        local hAbility = hPlayerHero:GetAbilityByIndex( i )
        DebugPrint (i, hAbility, hAbility ~= nil)
        if hAbility ~= nil and hAbility:GetLevel() > 0 and not hAbility:IsHidden() then
            DebugPrint ("setting level", hAbility:GetLevel(), hAbility:IsHidden())
            hAbility:SetLevel(0)
            if hAbility:GetName() == "earth_spirit_stone_caller" then
                hAbility:SetLevel(1)
            end
        end
    end
  
    hPlayerHero:SetAbilityPoints( 1 )
end

--------------------------------------------------------------------------------
-- GameEvent: OnBuildingHealButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnBuildingHealButtonPressed( eventSourceIndex, data )
    for _, v in pairs(self.buildings) do
        if IsValidEntity(v) and v:IsAlive() then
            v:SetHealth(v:GetMaxHealth())
        end
    end
    self:BroadcastMsg( "#BuildingHeal_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnBuildingInvulnerabilityButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnBuildingInvulnerabilityButtonPressed( eventSourceIndex, data )
	if self.m_bBuildingInvulnerabilityEnabled == false then
		self.m_bBuildingInvulnerabilityEnabled = true
        for _, v in pairs(self.buildings) do
            if IsValidEntity(v) and v:IsAlive() then
                v:AddNewModifier(v, nil, "modifier_fountain_glyph", {duration = -1})
            end
        end
		self:BroadcastMsg( "#BuildingInvulnerabilityOn_Msg" )
	elseif self.m_bBuildingInvulnerabilityEnabled == true then
		self.m_bBuildingInvulnerabilityEnabled = false
        for _, v in pairs(self.buildings) do
            if IsValidEntity(v) and v:IsAlive() then
                v:RemoveModifierByName("modifier_fountain_glyph")
            end
        end
		self:BroadcastMsg( "#BuildingInvulnerabilityOff_Msg" )
	end
    self:UpdateToggleUI()
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnAllyInvulnerabilityButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnAllyInvulnerabilityButtonPressed( eventSourceIndex, data )
	if self.m_bAllyInvulnerabilityEnabled == false then
		self.m_bAllyInvulnerabilityEnabled = true
		self:BroadcastMsg( "#AllyInvulnerabilityOn_Msg" )
	elseif self.m_bAllyInvulnerabilityEnabled == true then
		self.m_bAllyInvulnerabilityEnabled = false
		self:BroadcastMsg( "#AllyInvulnerabilityOff_Msg" )
	end
    self:UpdateToggleUI()
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnEnemyInvulnerabilityButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnEnemyInvulnerabilityButtonPressed( eventSourceIndex, data )
	if self.m_bEnemyInvulnerabilityEnabled == false then
		self.m_bEnemyInvulnerabilityEnabled = true
		self:BroadcastMsg( "#EnemyInvulnerabilityOn_Msg" )
	elseif self.m_bEnemyInvulnerabilityEnabled == true then
		self.m_bEnemyInvulnerabilityEnabled = false
		self:BroadcastMsg( "#EnemyInvulnerabilityOff_Msg" )
	end
    self:UpdateToggleUI()
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnOverlayToggleButtonPressed
--------------------------------------------------------------------------------
function CHeroDemo:OnOverlayToggleButtonPressed( eventSourceIndex, data )
	if data.value == 1 then
		self.overlays[data.PlayerID][data.overlayName] = true
        self:BroadcastMsg( "#" .. data.overlayName .. "On_Msg" )
	else
		self.overlays[data.PlayerID][data.overlayName] = false
        self:BroadcastMsg( "#" .. data.overlayName .. "Off_Msg" )
	end
end