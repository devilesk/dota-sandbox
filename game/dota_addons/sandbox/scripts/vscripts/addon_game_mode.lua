--[[ Hero Demo game mode ]]
-- Note: Hero Demo makes use of some mode-specific Dota2 C++ code for its activation from the main Dota2 UI.  Regular custom games can't do this.

print( "Hero Demo game mode loaded." )

_G.NEUTRAL_TEAM = 4 -- global const for neutral team int
_G.DOTA_MAX_ABILITIES = 16
_G.HERO_MAX_LEVEL = 25

LinkLuaModifier( "modifier_damage_tracking", LUA_MODIFIER_MOTION_NONE )

-- "demo_hero_name" is a magic term, "default_value" means no string was passed, so we'd probably want to put them in hero selection
--sHeroSelection = GameRules:GetGameSessionConfigValue( "demo_hero_name", "default_value" )
--DebugPrint( "sHeroSelection: " .. sHeroSelection )

------------------------------------------------------------------------------------------------------------------------------------------------------
-- HeroDemo class
------------------------------------------------------------------------------------------------------------------------------------------------------
if CHeroDemo == nil then
    _G.CHeroDemo = class({}) -- put CHeroDemo in the global scope
    --refer to: http://stackoverflow.com/questions/6586145/lua-require-with-global-local
end

NeutralCampCoords = {}

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Required .lua files, which just exist to help organize functions contained in our addon.  Make sure to call these beneath the mode's class creation.
------------------------------------------------------------------------------------------------------------------------------------------------------
require( "libraries/timers" )
require( "events" )
require( "utility_functions" )
require( "queue" )
require( "spawnbox" )

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
    PrecacheResource( "particle", "particles/custom/range_display.vpcf", context )
    PrecacheResource( "particle", "particles/custom/range_display_red.vpcf", context )
    PrecacheResource( "particle", "particles/custom/range_display_line.vpcf", context )
    PrecacheResource( "particle", "particles/custom/range_display_line_red.vpcf", context )
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
function InitBoxes()
    local boxes = Entities:FindAllByClassname("trigger_multiple")
    for k,ent in pairs(boxes) do
        if string.find(ent:GetName(), "neutralcamp") ~= nil then
            local box = {
                name = ent:GetName(),
                boxes = {
                    {
                    ent:GetOrigin() + ent:GetBounds().Mins,
                    ent:GetOrigin() + ent:GetBounds().Maxs
                    }
                },
                particles=nil,
                isRed=false
            }
            table.insert(NeutralCampCoords, box)
        end
    end
end

function CHeroDemo:InitGameMode()
    DebugPrint( "Initializing Hero Demo mode" )
    local GameMode = GameRules:GetGameModeEntity()
    
    InitBoxes()
    
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

    CustomGameEventManager:RegisterListener( "WelcomePanelDismissed", function(...) return self:OnWelcomePanelDismissed( ... ) end )
    CustomGameEventManager:RegisterListener( "RefreshButtonPressed", function(...) return self:OnRefreshButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LevelUpButtonPressed", function(...) return self:OnLevelUpButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "MaxLevelButtonPressed", function(...) return self:OnMaxLevelButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "FreeSpellsButtonPressed", function(...) return self:OnFreeSpellsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "InvulnerabilityButtonPressed", function(...) return self:OnInvulnerabilityButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnAllyButtonPressed", function(...) return self:OnSpawnAllyButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnEnemyButtonPressed", function(...) return self:OnSpawnEnemyButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LevelUpAllyButtonPressed", function(...) return self:OnLevelUpAllyButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LevelUpEnemyButtonPressed", function(...) return self:OnLevelUpEnemyButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "DummyTargetsButtonPressed", function(...) return self:OnDummyTargetsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "GiveItemsToAlliesButtonPressed", function(...) return self:OnGiveItemsToAlliesButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "GiveItemsToEnemiesButtonPressed", function(...) return self:OnGiveItemsToEnemiesButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RemoveSpawnedUnitsButtonPressed", function(...) return self:OnRemoveSpawnedUnitsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "GiveGoldButtonPressed", function(...) return self:OnGiveGoldButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ResetGoldButtonPressed", function(...) return self:OnResetGoldButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LaneCreepsButtonPressed", function(...) return self:OnLaneCreepsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ChangeHeroButtonPressed", function(...) return self:OnChangeHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ChangeCosmeticsButtonPressed", function(...) return self:OnChangeCosmeticsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "PauseButtonPressed", function(...) return self:OnPauseButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LeaveButtonPressed", function(...) return self:OnLeaveButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ClearInventoryButtonPressed", function(...) return self:OnClearInventoryButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RespawnHeroButtonPressed", function(...) return self:OnRespawnHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TeleportButtonPressed", function(...) return self:OnTeleportButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SelectNewHeroButtonPressed", function(...) return self:OnSelectNewHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "InstantRespawnEnabledButtonPressed", function(...) return self:OnInstantRespawnEnabledButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "FOWButtonPressed", function(...) return self:OnFOWButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "StartGameButtonPressed", function(...) return self:OnStartGameButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RemoveWardsButtonPressed", function(...) return self:OnRemoveWardsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnCreepsButtonPressed", function(...) return self:OnSpawnCreepsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnRunesButtonPressed", function(...) return self:OnSpawnRunesButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RegrowTreesButtonPressed", function(...) return self:OnRegrowTreesButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "IncrementTimeOfDayButtonPressed", function(...) return self:OnIncrementTimeOfDayButtonPressed( ... ) end )
  
    CustomGameEventManager:RegisterListener( "NeutralSpawnIntervalChange", function(...) return self:OnNeutralSpawnIntervalChange( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnNeutralsButtonPressed", function(...) return self:OnSpawnNeutralsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "HostTimeScaleChange", function(...) return self:OnHostTimeScaleChange( ... ) end )
  
    CustomGameEventManager:RegisterListener( "ResetHeroButtonPressed", function(...) return self:OnResetHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "MouseClick", function(...) return self:OnMouseClick( ... ) end )
    CustomGameEventManager:RegisterListener( "AllyInvulnerabilityButtonPressed", function(...) return self:OnAllyInvulnerabilityButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "EnemyInvulnerabilityButtonPressed", function(...) return self:OnEnemyInvulnerabilityButtonPressed( ... ) end )

    CustomGameEventManager:RegisterListener( "ShowDamageDealtButtonPressed", function(...) return self:OnShowDamageDealtButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ShowTargetHealthPreAttackButtonPressed", function(...) return self:OnShowTargetHealthPreAttackButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ShowTargetHealthPostAttackButtonPressed", function(...) return self:OnShowTargetHealthPostAttackButtonPressed( ... ) end )

    CustomGameEventManager:RegisterListener( "TowerDayVisionRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TowerNightVisionRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TowerTrueSightRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TowerAttackRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ShowNeutralSpawnBoxButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "DetectNeutralsButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SentryVisionButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "WardVisionButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "HeroXPRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "BlinkRangeButtonPressed", function(...) return self:OnOverlayToggleButtonPressed( ... ) end )

    CustomGameEventManager:RegisterListener( "ShopItemButtonPressed", function(...) return self:OnShopItemButtonPressed( ... ) end )

    CustomGameEventManager:RegisterListener( "DummyTargetButtonPressed", function(...) return self:OnDummyTargetButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ResetPlayerStatsButtonPressed", function(...) return self:OnResetPlayerStatsButtonPressed( ... ) end )

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

    self.m_bInstantRespawnEnabled = false
    self.m_bFreeSpellsEnabled = false
    self.m_bInvulnerabilityEnabled = false
    self.m_bAllyInvulnerabilityEnabled = false
    self.m_bEnemyInvulnerabilityEnabled = false
    self.m_bCreepsEnabled = true
    self.m_bGiveItemsToAllies = false
    self.m_bGiveItemsToEnemies = false
    self.m_bShowDamageDealt = false
    self.m_bShowTargetHealthPreAttack = false
    self.m_bShowTargetHealthPostAttack = false

    self.overlays = {
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

    --local hNeutralSpawn = Entities:FindByName( nil, "neutral_caster_spawn" )
    --self._hNeutralCaster = CreateUnitByName( "npc_dota_neutral_caster", hNeutralSpawn:GetAbsOrigin(), false, nil, nil, NEUTRAL_TEAM )
    self._hNeutralCaster = CreateUnitByName( "npc_dota_neutral_caster", Vector(0, 0, 0), false, nil, nil, NEUTRAL_TEAM )

    self.m_tPlayerDPS = {}
    self.m_tPlayerDPS10 = {}
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        CustomNetTables:SetTableValue( "dt_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "tdt_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "td_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "la_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "dps_nettable", tostring(nPlayerID), { value = 0 } )
        CustomNetTables:SetTableValue( "dps10_nettable", tostring(nPlayerID), { value = 0 } )
        self.m_tPlayerDPS[nPlayerID] = 0
        self.m_tPlayerDPS10[nPlayerID] = List.new()
    end
    GameRules:GetGameModeEntity():SetThink("CalculateDPS", self)
end

function CHeroDemo:CalculateDPS()
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        CustomNetTables:SetTableValue( "dps_nettable", tostring(nPlayerID), { value = self.m_tPlayerDPS[nPlayerID] } )
        List.pushright(self.m_tPlayerDPS10[nPlayerID], self.m_tPlayerDPS[nPlayerID])
        if self.m_tPlayerDPS10[nPlayerID].last - self.m_tPlayerDPS10[nPlayerID].first > 10 then
            List.popleft(self.m_tPlayerDPS10[nPlayerID])
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

function CHeroDemo:SpawnBoxThink()
    local boxes = Entities:FindAllByClassname("trigger_multiple")
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
        local wards = Entities:FindAllByClassname("npc_dota_ward_base")
        local sentries = Entities:FindAllByClassname("npc_dota_ward_base_truesight")
        local towers = Entities:FindAllByClassname("npc_dota_tower")
        local neutrals = Entities:FindAllByClassname("npc_dota_creep_neutral")
        if towers ~= nil then
            for k,ent in pairs(towers) do
                if ent._Particles == nil then
                    ent._Particles = {TowerDayVision=nil, TowerNightVision=nil, TowerTrueSight=nil, TowerAttack=nil}
                end
            end
        end
        if wards ~= nil then
            for k,ent in pairs(wards) do
                if ent:IsAlive() then
                    ent:SetHealth(1)
                end
                if ent:GetHealth() <= 0 then
                    ent:RemoveSelf()
                end
                if ent._Particles == nil then
                    ent._Particles = {WardVision=nil}
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
                    ent._Particles = {WardVision=nil, TrueSightVision=nil}
                end
            end
        end
        for i = 0, 9, 1 do
            local player = PlayerResource:GetPlayer(i)
            if player ~= nil then
                local hero = player:GetAssignedHero()
                if hero ~= nil then
                    if hero._Particles == nil then
                        hero._Particles = {HeroXPRange=nil, BlinkRange=nil}
                    end
                    CheckAndDrawCircle(hero, towers, wards, sentries)
                    for k,boxData in pairs(NeutralCampCoords) do
                        CreateParticleBoxes(hero, wards, sentries, neutrals, boxData)
                    end
                end            
            end
        end
        wards = nil
        sentries = nil
        towers = nil
        neutrals = nil
        boxes = nil
    elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        boxes = nil
        return nil
    end
    return .01
end