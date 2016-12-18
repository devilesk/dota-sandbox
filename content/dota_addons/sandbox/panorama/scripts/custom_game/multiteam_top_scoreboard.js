"use strict";

var g_ScoreboardHandle = null;
var optionsPanels = [];
var scoreboardConfig;

function OnPortraitClicked(playerPanel)
{
    var playerID = playerPanel.GetAttributeInt("player_id", -1);
    var optionsPanel = optionsPanels[playerID];
    playerPanel.ToggleClass("active");
    optionsPanel.ToggleClass("active");
    optionsPanel.SetFocus();
    optionsPanel.SetAttributeInt("player_id", playerID);
    optionsPanel.ClearActive = playerPanel.ClearActive;
    
    /*for (var i = 0; i < 10; i++) {
        var playerPanelName = "_dynamic_player_" + i;
        var playerPanel = $.GetContextPanel().FindChild( playerPanelName );
        $.Msg("playerPanel i", i, $.GetContextPanel());
        if ( playerPanel !== null ) {
            $.Msg("playerPanel", playerPanel);
            if (i !== playerID) {
                playerPanel.RemoveClass("active");
                var optionsPanel = optionsPanels[i];
                optionsPanel.RemoveClass("active");
            }
        }
    }*/
    
    var teamsContainer = $( "#MultiteamScoreboard" );
	var teamsList = [];
	for ( var teamId of Game.GetAllTeamIDs() )
	{
		teamsList.push( Game.GetTeamDetails( teamId ) );
	}

	// update/create team panels
	var teamsInfo = { max_team_players: 0 };
	var panelsByTeam = [];
	for ( var i = 0; i < teamsList.length; ++i )
	{
        if ( !teamsContainer )
            return;
        var teamDetails = teamsList[i];
        var teamId = teamDetails.team_id;
        //	$.Msg( "_ScoreboardUpdater_UpdateTeamPanel: ", teamId );

        var teamPanelName = "_dynamic_team_" + teamId;
        var teamPanel = teamsContainer.FindChild( teamPanelName );
		if ( teamPanel )
		{
            var teamPlayers = Game.GetPlayerIDsOnTeam( teamId )
            var playersContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );
            if ( playersContainer )
            {
                for ( var playerId of teamPlayers )
                {
                    var playerPanelName = "_dynamic_player_" + playerId;
                    var playerPanel = playersContainer.FindChild( playerPanelName );
                    
                    if (playerId !== playerID) {
                        playerPanel.RemoveClass("active");
                        var optionsPanel = optionsPanels[playerId];
                        optionsPanel.RemoveClass("active");
                    }
                
                }
            }
		}
	}
}

function UpdateScoreboard()
{
	ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true );

	$.Schedule( 0.2, UpdateScoreboard );
}

function DeleteTeamPanel(teamId) {
    var teamPanelName = "_dynamic_team_" + teamId;
    var teamPanel = $( "#MultiteamScoreboard" ).FindChild( teamPanelName );
    if (teamPanel != null) {
        teamPanel.DeleteAsync(0);
    }
}

function ReinitializeScoreboard() {
    DeleteTeamPanel(2);
    DeleteTeamPanel(3);
    //g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#MultiteamScoreboard" ) );
}

(function()
{
    $.GetContextPanel().OnPortraitClicked = OnPortraitClicked;
    for (var i = 0; i < 10; i++) {
        var optionsPanel = $.CreatePanel("Panel", $.GetContextPanel(), "");
        optionsPanel.SetAttributeInt("player_id", i);
        optionsPanel.BLoadLayout("file://{resources}/layout/custom_game/scoreboard_player_options.xml", false, false);
        optionsPanels.push(optionsPanel);
    }

	var shouldSort = false;

	if ( GameUI.CustomUIConfig().multiteam_top_scoreboard )
	{
		var cfg = GameUI.CustomUIConfig().multiteam_top_scoreboard;
		if ( cfg.LeftInjectXMLFile )
		{
			$( "#LeftInjectXMLFile" ).BLoadLayout( cfg.LeftInjectXMLFile, false, false );
		}
		if ( cfg.RightInjectXMLFile )
		{
			$( "#RightInjectXMLFile" ).BLoadLayout( cfg.RightInjectXMLFile, false, false );
		}

		if ( typeof(cfg.shouldSort) !== 'undefined')
		{
			shouldSort = cfg.shouldSort;
		}
	}
	
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_player.xml",
		"shouldSort" : shouldSort
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#MultiteamScoreboard" ) );

	UpdateScoreboard();
    
    GameEvents.Subscribe( "update_scoreboard", ReinitializeScoreboard );
})();

