var optionsPanel;

function PortraitClicked()
{
  // TODO: ctrl and alt click support
  /*Players.PlayerPortraitClicked( $.GetContextPanel().GetAttributeInt( "player_id", -1 ), false, false );
  var parentPanel = $.GetContextPanel().GetParent().GetParent().GetParent();
  var optionsPanel = $.CreatePanel( "Panel", parentPanel, "" );
  optionsPanel.SetAttributeInt( "player_id", $.GetContextPanel().GetAttributeInt( "player_id", -1 ) );
  optionsPanel.BLoadLayout( "file://{resources}/layout/custom_game/scoreboard_player_options.xml", false, false );
  optionsPanel.SetFocus();
  //$.Msg("click", $.GetContextPanel().GetAttributeInt( "player_id", -1 ));
  //$.Msg($.GetContextPanel());
  optionsPanel.style.x = $.GetContextPanel().actualxoffset + "px";*/
  //$.Msg("PortraitClicked");
  //optionsPanel.style.x = $.GetContextPanel().actualxoffset + "px";
  $.GetContextPanel().ToggleClass("active");
  optionsPanel.ToggleClass("active");
  optionsPanel.SetFocus();
  var heroEntId = Players.GetPlayerHeroEntityIndex($.GetContextPanel().GetAttributeInt( "player_id", -1 ));
  GameUI.SelectUnit(heroEntId, false);
}

function ClearActive() {
    $.GetContextPanel().RemoveClass("active");
}

function PortraitDoubleClicked()
{
  //$.Msg("PortraitDoubleClicked", $.GetContextPanel().GetAttributeInt( "player_id", -1 ));
  var heroEntId = Players.GetPlayerHeroEntityIndex($.GetContextPanel().GetAttributeInt( "player_id", -1 ));
}

(function () {
  var parentPanel = $.GetContextPanel().GetParent().GetParent().GetParent();
  optionsPanel = $.CreatePanel( "Panel", parentPanel, "" );
  optionsPanel.SetAttributeInt( "player_id", $.GetContextPanel().GetAttributeInt( "player_id", -1 ) );
  optionsPanel.BLoadLayout( "file://{resources}/layout/custom_game/scoreboard_player_options.xml", false, false );
  optionsPanel.ClearActive = ClearActive;
  //$.Msg("click", $.GetContextPanel().GetAttributeInt( "player_id", -1 ));
  //$.Msg($.GetContextPanel());
})();