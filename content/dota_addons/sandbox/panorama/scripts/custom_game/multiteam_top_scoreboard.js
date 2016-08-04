"use strict";

var g_ScoreboardHandle = null;
var optionsPanels = [];

function OnPortraitClicked(playerPanel)
{
    $.Msg("OnPortraitClicked");
    var playerID = playerPanel.GetAttributeInt("player_id", -1);
    var optionsPanel = optionsPanels[playerID];
    playerPanel.ToggleClass("active");
    optionsPanel.ToggleClass("active");
    optionsPanel.SetFocus();
    optionsPanel.SetAttributeInt("player_id", playerID);
    optionsPanel.ClearActive = playerPanel.ClearActive;
}

function UpdateScoreboard()
{
	ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true );

	$.Schedule( 0.2, UpdateScoreboard );
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

	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_player.xml",
		"shouldSort" : shouldSort
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#MultiteamScoreboard" ) );

	UpdateScoreboard();
})();

