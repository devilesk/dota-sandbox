var optionsPanel;

function PortraitClicked() {
    $.GetContextPanel().ToggleClass("active");
    optionsPanel.ToggleClass("active");
    optionsPanel.SetFocus();
    var heroEntId = Players.GetPlayerHeroEntityIndex($.GetContextPanel().GetAttributeInt("player_id", -1));
    GameUI.SelectUnit(heroEntId, false);
}

function ClearActive() {
    $.GetContextPanel().RemoveClass("active");
}

/*function PortraitDoubleClicked()
{
  var heroEntId = Players.GetPlayerHeroEntityIndex($.GetContextPanel().GetAttributeInt( "player_id", -1 ));
}*/

(function() {
    var parentPanel = $.GetContextPanel().GetParent().GetParent().GetParent();
    optionsPanel = $.CreatePanel("Panel", parentPanel, "");
    optionsPanel.SetAttributeInt("player_id", $.GetContextPanel().GetAttributeInt("player_id", -1));
    optionsPanel.BLoadLayout("file://{resources}/layout/custom_game/scoreboard_player_options.xml", false, false);
    optionsPanel.ClearActive = ClearActive;
})();