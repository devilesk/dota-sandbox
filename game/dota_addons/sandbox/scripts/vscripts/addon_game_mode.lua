print( "Hero Demo game mode loaded." )

_G.NEUTRAL_TEAM = 4 -- global const for neutral team int
_G.DOTA_MAX_ABILITIES = 16
_G.HERO_MAX_LEVEL = 25

LinkLuaModifier( "modifier_damage_tracking", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_range_base", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_range_blink", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_range_xp", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_range_creep_aggro", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_target", LUA_MODIFIER_MOTION_NONE )

if CHeroDemo == nil then
    _G.CHeroDemo = class({}) -- put CHeroDemo in the global scope
    --refer to: http://stackoverflow.com/questions/6586145/lua-require-with-global-local
end

require( "libraries/timers" )
require( "libraries/util" )
require( "libraries/queue" )
require( "events" )
require( "overlay" )
require( "spawnbox_controller" )

local DEBUG = false
_G.DebugPrint = function(...)
  if DEBUG then
    print(...)
  end
end
_G.DeepDebugPrintTable = function(...)
  if DEBUG then
    DeepPrintTable(...)
  end
end
_G.DebugPrintTable = function(...)
  if DEBUG then
    PrintTable(...)
  end
end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Precache files and folders
------------------------------------------------------------------------------------------------------------------------------------------------------
function Precache( context )
    PrecacheResource( "particle", RANGE_PARTICLE, context )
    PrecacheResource( "particle", RANGE_PARTICLE_RED, context )
    PrecacheResource( "particle", RANGE_LINE_PARTICLE, context )
    PrecacheResource( "particle", RANGE_LINE_PARTICLE_RED, context )
    PrecacheResource( "particle", RANGE_TARGET, context )
    PrecacheUnitByNameSync( "npc_dota_hero_abaddon", context )
    PrecacheUnitByNameSync( "npc_dota_hero_abyssal_underlord", context )
    PrecacheUnitByNameSync( "npc_dota_hero_alchemist", context )
    PrecacheUnitByNameSync( "npc_dota_hero_ancient_apparition", context )
    PrecacheUnitByNameSync( "npc_dota_hero_antimage", context )
    PrecacheUnitByNameSync( "npc_dota_hero_arc_warden", context )
    PrecacheUnitByNameSync( "npc_dota_hero_axe", context )
    PrecacheUnitByNameSync( "npc_dota_hero_bane", context )
    PrecacheUnitByNameSync( "npc_dota_hero_batrider", context )
    PrecacheUnitByNameSync( "npc_dota_hero_beastmaster", context )
    PrecacheUnitByNameSync( "npc_dota_hero_bloodseeker", context )
    PrecacheUnitByNameSync( "npc_dota_hero_bounty_hunter", context )
    PrecacheUnitByNameSync( "npc_dota_hero_brewmaster", context )
    PrecacheUnitByNameSync( "npc_dota_hero_bristleback", context )
    PrecacheUnitByNameSync( "npc_dota_hero_broodmother", context )
    PrecacheUnitByNameSync( "npc_dota_hero_centaur", context )
    PrecacheUnitByNameSync( "npc_dota_hero_chaos_knight", context )
    PrecacheUnitByNameSync( "npc_dota_hero_chen", context )
    PrecacheUnitByNameSync( "npc_dota_hero_clinkz", context )
    PrecacheUnitByNameSync( "npc_dota_hero_rattletrap", context )
    PrecacheUnitByNameSync( "npc_dota_hero_crystal_maiden", context )
    PrecacheUnitByNameSync( "npc_dota_hero_dark_seer", context )
    PrecacheUnitByNameSync( "npc_dota_hero_dazzle", context )
    PrecacheUnitByNameSync( "npc_dota_hero_death_prophet", context )
    PrecacheUnitByNameSync( "npc_dota_hero_disruptor", context )
    PrecacheUnitByNameSync( "npc_dota_hero_doom_bringer", context )
    PrecacheUnitByNameSync( "npc_dota_hero_dragon_knight", context )
    PrecacheUnitByNameSync( "npc_dota_hero_drow_ranger", context )
    PrecacheUnitByNameSync( "npc_dota_hero_earth_spirit", context )
    PrecacheUnitByNameSync( "npc_dota_hero_earthshaker", context )
    PrecacheUnitByNameSync( "npc_dota_hero_elder_titan", context )
    PrecacheUnitByNameSync( "npc_dota_hero_ember_spirit", context )
    PrecacheUnitByNameSync( "npc_dota_hero_enchantress", context )
    PrecacheUnitByNameSync( "npc_dota_hero_enigma", context )
    PrecacheUnitByNameSync( "npc_dota_hero_faceless_void", context )
    PrecacheUnitByNameSync( "npc_dota_hero_gyrocopter", context )
    PrecacheUnitByNameSync( "npc_dota_hero_huskar", context )
    PrecacheUnitByNameSync( "npc_dota_hero_invoker", context )
    PrecacheUnitByNameSync( "npc_dota_hero_wisp", context )
    PrecacheUnitByNameSync( "npc_dota_hero_jakiro", context )
    PrecacheUnitByNameSync( "npc_dota_hero_juggernaut", context )
    PrecacheUnitByNameSync( "npc_dota_hero_keeper_of_the_light", context )
    PrecacheUnitByNameSync( "npc_dota_hero_kunkka", context )
    PrecacheUnitByNameSync( "npc_dota_hero_legion_commander", context )
    PrecacheUnitByNameSync( "npc_dota_hero_leshrac", context )
    PrecacheUnitByNameSync( "npc_dota_hero_lich", context )
    PrecacheUnitByNameSync( "npc_dota_hero_life_stealer", context )
    PrecacheUnitByNameSync( "npc_dota_hero_lina", context )
    PrecacheUnitByNameSync( "npc_dota_hero_lion", context )
    PrecacheUnitByNameSync( "npc_dota_hero_lone_druid", context )
    PrecacheUnitByNameSync( "npc_dota_hero_luna", context )
    PrecacheUnitByNameSync( "npc_dota_hero_lycan", context )
    PrecacheUnitByNameSync( "npc_dota_hero_magnataur", context )
    PrecacheUnitByNameSync( "npc_dota_hero_medusa", context )
    PrecacheUnitByNameSync( "npc_dota_hero_meepo", context )
    PrecacheUnitByNameSync( "npc_dota_hero_mirana", context )
    PrecacheUnitByNameSync( "npc_dota_hero_morphling", context )
    PrecacheUnitByNameSync( "npc_dota_hero_naga_siren", context )
    PrecacheUnitByNameSync( "npc_dota_hero_furion", context )
    PrecacheUnitByNameSync( "npc_dota_hero_necrolyte", context )
    PrecacheUnitByNameSync( "npc_dota_hero_night_stalker", context )
    PrecacheUnitByNameSync( "npc_dota_hero_nyx_assassin", context )
    PrecacheUnitByNameSync( "npc_dota_hero_ogre_magi", context )
    PrecacheUnitByNameSync( "npc_dota_hero_omniknight", context )
    PrecacheUnitByNameSync( "npc_dota_hero_oracle", context )
    PrecacheUnitByNameSync( "npc_dota_hero_obsidian_destroyer", context )
    PrecacheUnitByNameSync( "npc_dota_hero_phantom_assassin", context )
    PrecacheUnitByNameSync( "npc_dota_hero_phantom_lancer", context )
    PrecacheUnitByNameSync( "npc_dota_hero_phoenix", context )
    PrecacheUnitByNameSync( "npc_dota_hero_puck", context )
    PrecacheUnitByNameSync( "npc_dota_hero_pudge", context )
    PrecacheUnitByNameSync( "npc_dota_hero_pugna", context )
    PrecacheUnitByNameSync( "npc_dota_hero_queenofpain", context )
    PrecacheUnitByNameSync( "npc_dota_hero_razor", context )
    PrecacheUnitByNameSync( "npc_dota_hero_riki", context )
    PrecacheUnitByNameSync( "npc_dota_hero_rubick", context )
    PrecacheUnitByNameSync( "npc_dota_hero_sand_king", context )
    PrecacheUnitByNameSync( "npc_dota_hero_shadow_demon", context )
    PrecacheUnitByNameSync( "npc_dota_hero_nevermore", context )
    PrecacheUnitByNameSync( "npc_dota_hero_shadow_shaman", context )
    PrecacheUnitByNameSync( "npc_dota_hero_silencer", context )
    PrecacheUnitByNameSync( "npc_dota_hero_skywrath_mage", context )
    PrecacheUnitByNameSync( "npc_dota_hero_slardar", context )
    PrecacheUnitByNameSync( "npc_dota_hero_slark", context )
    PrecacheUnitByNameSync( "npc_dota_hero_sniper", context )
    PrecacheUnitByNameSync( "npc_dota_hero_spectre", context )
    PrecacheUnitByNameSync( "npc_dota_hero_spirit_breaker", context )
    PrecacheUnitByNameSync( "npc_dota_hero_storm_spirit", context )
    PrecacheUnitByNameSync( "npc_dota_hero_sven", context )
    PrecacheUnitByNameSync( "npc_dota_hero_techies", context )
    PrecacheUnitByNameSync( "npc_dota_hero_templar_assassin", context )
    PrecacheUnitByNameSync( "npc_dota_hero_terrorblade", context )
    PrecacheUnitByNameSync( "npc_dota_hero_tidehunter", context )
    PrecacheUnitByNameSync( "npc_dota_hero_shredder", context )
    PrecacheUnitByNameSync( "npc_dota_hero_tinker", context )
    PrecacheUnitByNameSync( "npc_dota_hero_tiny", context )
    PrecacheUnitByNameSync( "npc_dota_hero_treant", context )
    PrecacheUnitByNameSync( "npc_dota_hero_troll_warlord", context )
    PrecacheUnitByNameSync( "npc_dota_hero_tusk", context )
    PrecacheUnitByNameSync( "npc_dota_hero_undying", context )
    PrecacheUnitByNameSync( "npc_dota_hero_ursa", context )
    PrecacheUnitByNameSync( "npc_dota_hero_vengefulspirit", context )
    PrecacheUnitByNameSync( "npc_dota_hero_venomancer", context )
    PrecacheUnitByNameSync( "npc_dota_hero_viper", context )
    PrecacheUnitByNameSync( "npc_dota_hero_visage", context )
    PrecacheUnitByNameSync( "npc_dota_hero_warlock", context )
    PrecacheUnitByNameSync( "npc_dota_hero_weaver", context )
    PrecacheUnitByNameSync( "npc_dota_hero_windrunner", context )
    PrecacheUnitByNameSync( "npc_dota_hero_winter_wyvern", context )
    PrecacheUnitByNameSync( "npc_dota_hero_witch_doctor", context )
    PrecacheUnitByNameSync( "npc_dota_hero_skeleton_king", context )
    PrecacheUnitByNameSync( "npc_dota_hero_zuus", context )
end

--------------------------------------------------------------------------------
-- Activate HeroDemo mode
--------------------------------------------------------------------------------
function Activate()
    -- When you don't have access to 'self', use 'GameRules.herodemo' instead
    -- example Function call: GameRules.herodemo:Function()
    -- example Var access: GameRules.herodemo.m_Variable = 1
    GameRules.herodemo = CHeroDemo()
    GameRules.herodemo:InitGameMode()
end

--------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------
function CHeroDemo:InitGameMode()
    DebugPrint( "Initializing Hero Demo mode" )
    local GameMode = GameRules:GetGameModeEntity()
    
    self.spawnBoxController = SPAWNBOXCONTROLLER()
    
    --GameMode:SetCustomGameForceHero( sHeroSelection ) -- sHeroSelection string gets piped in by dashboard's demo button
    GameMode:SetTowerBackdoorProtectionEnabled(true)
    --GameMode:SetFixedRespawnTime(4)
    --GameMode:SetBotThinkingEnabled( true ) -- the ConVar is currently disabled in C++
    -- Set bot mode difficulty: can try GameMode:SetCustomGameDifficulty( 1 )

    GameRules:SetUseUniversalShopMode(true)
    --GameRules:SetPreGameTime(30)
    GameRules:SetPostGameTime(0)
    --GameRules:SetCustomGameSetupTimeout( 0 ) -- skip the custom team UI with 0, or do indefinite duration with -1

    GameMode:SetContextThink( "HeroDemo:GameThink", function() return self:GameThink() end, 0 )
    GameMode:SetContextThink( "HeroDemo:SpawnBoxThink", function() return self:SpawnBoxThink() end, 0 )

    -- Events
    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHeroDemo, 'OnGameRulesStateChange' ), self )
    ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHeroDemo, "OnNPCSpawned" ), self )
    ListenToGameEvent( "dota_item_purchased", Dynamic_Wrap( CHeroDemo, "OnItemPurchased" ), self )
    ListenToGameEvent( "npc_replaced", Dynamic_Wrap( CHeroDemo, "OnNPCReplaced" ), self )
    ListenToGameEvent( "player_fullyjoined", Dynamic_Wrap( CHeroDemo, "OnPlayerFullyJoined" ), self )
    ListenToGameEvent( "player_connect", Dynamic_Wrap( CHeroDemo, "OnPlayerConnect" ), self )
    
    CustomGameEventManager:RegisterListener( "AllyInvulnerabilityButtonPressed", function(...) return self:OnAllyInvulnerabilityButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "BlinkRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ChangeCosmeticsButtonPressed", function(...) return self:OnChangeCosmeticsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ChangeHeroButtonPressed", function(...) return self:OnChangeHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ClearInventoryButtonPressed", function(...) return self:OnClearInventoryButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "CreepAggroRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "DetectNeutralsButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "DummyTargetButtonPressed", function(...) return self:OnDummyTargetButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "DummyTargetsButtonPressed", function(...) return self:OnDummyTargetsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "EnemyInvulnerabilityButtonPressed", function(...) return self:OnEnemyInvulnerabilityButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "FOWButtonPressed", function(...) return self:OnFOWButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "FreeSpellsButtonPressed", function(...) return self:OnFreeSpellsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "GiveGoldButtonPressed", function(...) return self:OnGiveGoldButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "GiveItemsToAlliesButtonPressed", function(...) return self:OnGiveItemsToAlliesButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "GiveItemsToEnemiesButtonPressed", function(...) return self:OnGiveItemsToEnemiesButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "HeroXPRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "HostTimeScaleChange", function(...) return self:OnHostTimeScaleChange( ... ) end )
    CustomGameEventManager:RegisterListener( "IncrementTimeOfDayButtonPressed", function(...) return self:OnIncrementTimeOfDayButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "InstantRespawnEnabledButtonPressed", function(...) return self:OnInstantRespawnEnabledButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "InvulnerabilityButtonPressed", function(...) return self:OnInvulnerabilityButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LaneCreepsButtonPressed", function(...) return self:OnLaneCreepsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LeaveButtonPressed", function(...) return self:OnLeaveButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LevelUpAllyButtonPressed", function(...) return self:OnLevelUpAllyButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LevelUpButtonPressed", function(...) return self:OnLevelUpButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LevelUpEnemyButtonPressed", function(...) return self:OnLevelUpEnemyButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "MaxLevelButtonPressed", function(...) return self:OnMaxLevelButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "MouseClick", function(...) return self:OnMouseClick( ... ) end )
    CustomGameEventManager:RegisterListener( "NeutralSpawnIntervalChange", function(...) return self:OnNeutralSpawnIntervalChange( ... ) end )
    CustomGameEventManager:RegisterListener( "PauseButtonPressed", function(...) return self:OnPauseButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RefreshButtonPressed", function(...) return self:OnRefreshButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RegrowTreesButtonPressed", function(...) return self:OnRegrowTreesButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RemoveSpawnedUnitsButtonPressed", function(...) return self:OnRemoveSpawnedUnitsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SwitchTeamButtonPressed", function(...) return self:OnSwitchTeamButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RemoveWardsButtonPressed", function(...) return self:OnRemoveWardsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ResetGoldButtonPressed", function(...) return self:OnResetGoldButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "PassiveGoldButtonPressed", function(...) return self:OnPassiveGoldButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ResetHeroButtonPressed", function(...) return self:OnResetHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ResetPlayerStatsButtonPressed", function(...) return self:OnResetPlayerStatsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RespawnHeroButtonPressed", function(...) return self:OnRespawnHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SelectNewHeroButtonPressed", function(...) return self:OnSelectNewHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SentryVisionButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ShopItemButtonPressed", function(...) return self:OnShopItemButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ShowDamageDealtButtonPressed", function(...) return self:OnShowDamageDealtButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ShowNeutralSpawnBoxButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ShowTargetHealthPostAttackButtonPressed", function(...) return self:OnShowTargetHealthPostAttackButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ShowTargetHealthPreAttackButtonPressed", function(...) return self:OnShowTargetHealthPreAttackButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnAllyButtonPressed", function(...) return self:OnSpawnAllyButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnCreepsButtonPressed", function(...) return self:OnSpawnCreepsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnEnemyButtonPressed", function(...) return self:OnSpawnEnemyButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnNeutralsButtonPressed", function(...) return self:OnSpawnNeutralsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnRunesButtonPressed", function(...) return self:OnSpawnRunesButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "StartGameButtonPressed", function(...) return self:OnStartGameButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TeleportButtonPressed", function(...) return self:OnTeleportButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TowerAttackRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TowerDayVisionRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TowerNightVisionRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TowerTrueSightRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "WardVisionButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "WelcomePanelDismissed", function(...) return self:OnWelcomePanelDismissed( ... ) end )

    CustomGameEventManager:RegisterListener( "quit", function(...) return self:OnQuit( ... ) end )
    --SendToServerConsole( "dota_hero_god_mode 0" )
    --SendToServerConsole( "dota_ability_debug 0" )
    --SendToServerConsole( "dota_creeps_no_spawning 0" )
    --SendToServerConsole( "dota_bot_mode 1" )

    --self.m_sHeroSelection = sHeroSelection -- this seems redundant, but events.lua doesn't seem to know about sHeroSelection
    self.m_bPlayerDataCaptured = false
    self.m_nPlayerID = 0

    self.m_nALLIES_TEAM = 2
    self.m_tAlliesList = {}
    self.m_nAlliesCount = 0

    self.m_nENEMIES_TEAM = 3
    self.m_tEnemiesList = {}
    self.m_nEnemiesCount = 0

    self.m_nDUMMIES_TEAM = 4
    self.m_tDummiesList = {}
    self.m_nDummiesCount = 0
    self.m_bDummiesEnabled = false
    
    self.m_tCurrentMouseClick = {}
    
    self.m_bFreeSpellsEnabled = false
    self.m_bInvulnerabilityEnabled = false
    self.m_bAllyInvulnerabilityEnabled = false
    self.m_bEnemyInvulnerabilityEnabled = false
    self.m_bPassiveGoldDisabled = false
    self.m_bInstantRespawnEnabled = false
    self.m_bFOWDisabled = false
    self.m_bCreepsDisabled = false
    self.m_bGiveItemsToAllies = false
    self.m_bGiveItemsToEnemies = false
    self.m_bShowDamageDealt = {}
    self.m_bShowTargetHealthPreAttack = {}
    self.m_bShowTargetHealthPostAttack = {}

    self._hNeutralCaster = CreateUnitByName( "npc_dota_neutral_caster", Vector(0, 0, 0), false, nil, nil, NEUTRAL_TEAM )

    self.m_tPlayerDPS = {}
    self.m_tPlayerDPS10 = {}
    self.overlays = {}
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        CustomNetTables:SetTableValue( "dt_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "tdt_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "td_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "la_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "dps_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "dps10_nettable", tostring(nPlayerID), { value = 0 } )
        self.m_tPlayerDPS[nPlayerID] = 0
        self.m_tPlayerDPS10[nPlayerID] = Queue()
        
        self.m_bShowDamageDealt[nPlayerID] = false
        self.m_bShowTargetHealthPreAttack[nPlayerID] = false
        self.m_bShowTargetHealthPostAttack[nPlayerID] = false
        
        self.overlays[nPlayerID] = {
            TowerDayVisionRangeButtonPressed = false,
            TowerNightVisionRangeButtonPressed = false,
            TowerTrueSightRangeButtonPressed = false,
            TowerAttackRangeButtonPressed = false,
            ShowNeutralSpawnBoxButtonPressed = false,
            DetectNeutralsButtonPressed = false,
            SentryVisionButtonPressed = false,
            WardVisionButtonPressed = false,
            HeroXPRangeButtonPressed = false,
            BlinkRangeButtonPressed = false,
        }
    end
    GameRules:GetGameModeEntity():SetThink("CalculateDPS", self)
end

function CHeroDemo:UpdateToggleUI()
    local data = {
        FreeSpells_Button = self.m_bFreeSpellsEnabled,
        Invulnerability_Button = self.m_bInvulnerabilityEnabled,
        AllyInvulnerability_Button = self.m_bAllyInvulnerabilityEnabled,
        EnemyInvulnerability_Button = self.m_bEnemyInvulnerabilityEnabled,
        PassiveGold_Button = self.m_bPassiveGoldDisabled,
        InstantRespawnEnabled_Button = self.m_bInstantRespawnEnabled,
        FOW_Button = self.m_bFOWDisabled,
        LaneCreeps_Button = self.m_bCreepsDisabled,
    }
    CustomGameEventManager:Send_ServerToAllClients("update_toggle_ui", data )
end

function CHeroDemo:BroadcastMsg( sMsg )
	-- Display a message about the button action that took place
	local buttonEventMessage = sMsg
	--print( buttonEventMessage )
	local centerMessage = {
		message = buttonEventMessage,
		duration = 1.0,
		clearQueue = true -- this doesn't seem to work
	}
	FireGameEvent( "show_center_message", centerMessage )
end

function CHeroDemo:CalculateDPS()
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        CustomNetTables:SetTableValue( "dps_nettable", tostring(nPlayerID), { value = self.m_tPlayerDPS[nPlayerID] } )
        self.m_tPlayerDPS10[nPlayerID]:PushRight(self.m_tPlayerDPS[nPlayerID])
        if self.m_tPlayerDPS10[nPlayerID].last - self.m_tPlayerDPS10[nPlayerID].first > 10 then
            self.m_tPlayerDPS10[nPlayerID]:PopLeft()
        end

        local dps10 = 0
        local k = -1
        for i = self.m_tPlayerDPS10[nPlayerID].first, self.m_tPlayerDPS10[nPlayerID].last do
            dps10 = dps10 + self.m_tPlayerDPS10[nPlayerID][i]
            if k == -1 and self.m_tPlayerDPS10[nPlayerID][i] > 0 then
                k = i
            end
        end
        if k == -1 then k = self.m_tPlayerDPS10[nPlayerID].first end
        if k == self.m_tPlayerDPS10[nPlayerID].last then k = self.m_tPlayerDPS10[nPlayerID].last - 1 end

        dps10 = dps10 / (self.m_tPlayerDPS10[nPlayerID].last - k)
        CustomNetTables:SetTableValue( "dps10_nettable", tostring(nPlayerID), { value = dps10 } )

        self.m_tPlayerDPS[nPlayerID] = 0
    end
    return 1
end

--------------------------------------------------------------------------------
-- Main Think
--------------------------------------------------------------------------------
function CHeroDemo:GameThink()
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_HERO_SELECTION then
        self.m_nALLIES_TEAM = PlayerResource:GetTeam(0)
        if PlayerResource:GetTeam(0) == 2 then
            self.m_nENEMIES_TEAM = 3
        elseif PlayerResource:GetTeam(0) == 3 then
            self.m_nENEMIES_TEAM = 2
        end
    end

    if self.m_bFreeSpellsEnabled == true then
        if not GameRules:IsCheatMode() then
            RefreshAllUnits(self.m_tAlliesList, self.m_tEnemiesList, false, true, true)
        end
    end
  
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:GetConnectionState(nPlayerID) ~= 1 then
            local hPlayerHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
            if hPlayerHero ~= nil then
                local hAllPlayerUnits = {}
                hAllPlayerUnits = hPlayerHero:GetAdditionalOwnedUnits()
                hAllPlayerUnits[ #hAllPlayerUnits + 1 ] = hPlayerHero

                for _, hUnit in pairs( hAllPlayerUnits ) do
                    if not hUnit:HasModifier("modifier_damage_tracking") then
                        hUnit:AddNewModifier(hUnit, nil, "modifier_damage_tracking", {duration = -1})
                    end
                    if self.m_bInvulnerabilityEnabled == true then
                        hUnit:SetHealth( hUnit:GetMaxHealth() )
                    end
                end
            end
        end
    end
    
    if self.m_bEnemyInvulnerabilityEnabled == true then
        if GameRules:IsCheatMode() then
            for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
                if PlayerResource:GetTeam(nPlayerID) == self.m_nENEMIES_TEAM and PlayerResource:GetConnectionState(nPlayerID) == 1 then
                    local hPlayerHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                    if hPlayerHero ~= nil then
                        hPlayerHero:SetHealth( hPlayerHero:GetMaxHealth() )
                    end
                end
            end
        else
            for k, v in pairs( self.m_tEnemiesList ) do
                self.m_tEnemiesList[ k ]:SetHealth( self.m_tEnemiesList[ k ]:GetMaxHealth() )
            end
        end
    end
    if self.m_bAllyInvulnerabilityEnabled == true then
        if GameRules:IsCheatMode() then
            for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
                if PlayerResource:GetTeam(nPlayerID) == self.m_nALLIES_TEAM and PlayerResource:GetConnectionState(nPlayerID) == 1 then
                    local hPlayerHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                    if hPlayerHero ~= nil then
                        hPlayerHero:SetHealth( hPlayerHero:GetMaxHealth() )
                    end
                end
            end
        else
            for k, v in pairs( self.m_tAlliesList ) do
                self.m_tAlliesList[ k ]:SetHealth( self.m_tAlliesList[ k ]:GetMaxHealth() )
            end
        end
    end
    
    return 0.1
end

function IsInRangeFuncGenerator(entB, distance)
    return function (entA)
        return (entA:GetCenter() - entB:GetCenter()):Length2D() < distance
    end
end

function IsDistBetweenEntOBBFuncGenerator(entB, distance)
    return function (entA)
        return CalcDistanceBetweenEntityOBB(entA, entB) < distance
    end
end

function CreateTowerRangeOverlayForPlayer(player, heroes, towers)
	if towers ~= nil then
		for k, tower in pairs(towers) do
			if tower ~= nil and IsValidEntity(tower) then
				CreateRangeOverlayForPlayer(player, tower, "TowerDayVisionRangeButtonPressed", "TowerDayVision", 1800, tower._isRed.TowerDayVision)
				CreateRangeOverlayForPlayer(player, tower, "TowerTrueSightRangeButtonPressed", "TowerTrueSight", 900, tower._isRed.TowerTrueSight)
				CreateRangeOverlayForPlayer(player, tower, "TowerNightVisionRangeButtonPressed", "TowerNightVision", 800, tower._isRed.TowerNightVision)
				CreateRangeOverlayForPlayer(player, tower, "TowerAttackRangeButtonPressed", "TowerAttack", 700 + tower:GetHullRadius(), tower._isRed.TowerAttack)
			end
		end
	end
end

function CreateHeroRangeOverlayForPlayer(player, hero)
	CreateRangeOverlayForPlayer(player, hero, "HeroXPRangeButtonPressed", "HeroXPRange", 1300, false)
	CreateRangeOverlayForPlayer(player, hero, "BlinkRangeButtonPressed", "BlinkRange", 1200, false)
end

function CreateWardRangeOverlayForPlayer(player, wards, sentries)
	if wards ~= nil then
		for k,ent in pairs(wards) do
			if ent ~= nil and IsValidEntity(ent) then
				CreateRangeOverlayForPlayer(player, ent, "WardVisionButtonPressed", "WardVision", 1600, false)
			end
		end
	end
	if sentries ~= nil then
		for k,ent in pairs(sentries) do
			if ent ~= nil and IsValidEntity(ent) then
				CreateRangeOverlayForPlayer(player, ent, "SentryVisionButtonPressed", "WardVision", 150, false)
				CreateRangeOverlayForPlayer(player, ent, "SentryVisionButtonPressed", "TrueSightVision", 850, false)
			end
		end
	end
end

function CreateRangeOverlayForPlayer(player, ent, overlayName, particleOverlay, radius, isRed)
    local playerID = player:GetPlayerID()
	if GameRules.herodemo.overlays[playerID][overlayName] == true then
        local particle_name = RANGE_PARTICLE
        if isRed then
            particle_name = RANGE_PARTICLE_RED
        end
		if ent._Particles[playerID][particleOverlay] ~= nil then
			if ent._Particles[playerID][particleOverlay][2] ~= isRed then
				ParticleManager:DestroyParticle(ent._Particles[playerID][particleOverlay][1], true)
				ent._Particles[playerID][particleOverlay] = {CreateParticleCircle(ent, radius, particle_name, player), isRed}
			end
		else
			ent._Particles[playerID][particleOverlay] = {CreateParticleCircle(ent, radius, particle_name, player), isRed}
		end
	else
		if ent._Particles[playerID][particleOverlay] ~= nil then
			ParticleManager:DestroyParticle(ent._Particles[playerID][particleOverlay][1], true)
			ent._Particles[playerID][particleOverlay] = nil
		end
	end
end

function CHeroDemo:SpawnBoxThink()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
        local heroes = HeroList:GetAllHeroes()
        local wards = Entities:FindAllByClassname("npc_dota_ward_base")
        local sentries = Entities:FindAllByClassname("npc_dota_ward_base_truesight")
        local neutrals = Entities:FindAllByClassname("npc_dota_creep_neutral")
        local towers = self.towers
        
        if wards ~= nil then
            for k,ent in pairs(wards) do
                if ent:IsAlive() then
                    ent:SetHealth(1)
                end
                if ent:GetHealth() <= 0 then
                    ent:RemoveSelf()
                end
                if ent._Particles == nil then
                    ent._Particles = {}
                    for i = 0, 9, 1 do
                        ent._Particles[i] = {WardVision=nil}
                    end
                end
            end
        end
        if sentries ~= nil then
            for k,ent in pairs(sentries) do
                if ent:IsAlive() then
                    ent:SetHealth(1)
                end
                if ent:GetHealth() <= 0 then
                    ent:RemoveSelf()
                end
                if ent._Particles == nil then
                    ent._Particles = {}
                    for i = 0, 9, 1 do
                        ent._Particles[i] = {WardVision=nil, TrueSightVision=nil}
                    end
                end
            end
        end
        if heroes ~= nil then
            for k,ent in pairs(heroes) do
                if not ent:HasModifier("modifier_range_blink") then
                    ent:AddNewModifier(ent, nil, "modifier_range_blink", {duration = -1})
                end
                if not ent:HasModifier("modifier_range_xp") then
                    ent:AddNewModifier(ent, nil, "modifier_range_xp", {duration = -1})
                end
                if not ent:HasModifier("modifier_range_creep_aggro") then
                    ent:AddNewModifier(ent, nil, "modifier_range_creep_aggro", {duration = -1})
                end
            end
        end
        if towers ~= nil then
            for k,ent in pairs(towers) do
                if IsValidEntity(ent) then
                    if ent._Particles == nil then
                        ent._Particles = {}
                        for i = 0, 9, 1 do
                            ent._Particles[i] = {TowerDayVision=nil, TowerNightVision=nil, TowerTrueSight=nil, TowerAttack=nil}
                        end
                    end
                    ent._isRed = {
                        TowerDayVision = any(IsInRangeFuncGenerator(ent, 1800), heroes),
                        TowerTrueSight = any(IsInRangeFuncGenerator(ent, 900), heroes),
                        TowerNightVision = any(IsInRangeFuncGenerator(ent, 800), heroes),
                        TowerAttack = any(IsDistBetweenEntOBBFuncGenerator(ent, 700), heroes),
                    }
                end
            end
        end
        
        self.spawnBoxController:UpdateIsBlockedState(heroes, wards, sentries, neutrals)
        
        for i = 0, 9, 1 do
            local player = PlayerResource:GetPlayer(i)
            if player ~= nil then
                local hero = player:GetAssignedHero()
                if hero ~= nil then
                    if hero._Particles == nil then
                        hero._Particles = {HeroXPRange=nil, BlinkRange=nil}
                    end

                    local bShowBox = self.overlays[i].ShowNeutralSpawnBoxButtonPressed
                    local bDetectNeutrals = self.overlays[i].DetectNeutralsButtonPressed
                    self.spawnBoxController:UpdateOverlayForPlayer(player, bShowBox, bDetectNeutrals)
                    
                    CreateTowerRangeOverlayForPlayer(player, heroes, towers)
                    CreateWardRangeOverlayForPlayer(player, wards, sentries)
                end            
            end
        end
    end
    return .01
end