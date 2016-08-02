

function PortraitClicked() {
    $.GetContextPanel().OnPortraitClicked($.GetContextPanel());
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
    $.GetContextPanel().ClearActive = ClearActive;
})();