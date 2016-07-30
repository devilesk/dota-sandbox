function PortraitClicked() {
    // TODO: ctrl and alt click support
    Players.PlayerPortraitClicked($.GetContextPanel().GetAttributeInt("player_id", -1), false, false);
    //$.Msg("click", $.GetContextPanel().GetAttributeInt( "player_id", -1 ));
}

function Destroy() {
    $.GetContextPanel().RemoveClass("active");
    $.GetContextPanel().ClearActive();
}

function OnHeroChanged() {
    GameEvents.SendCustomGameEventToServer("ChangeHeroButtonPressed", {
        pID: $.GetContextPanel().GetAttributeInt("player_id", -1),
        PlayerID: $.GetContextPanel().GetAttributeInt("player_id", -1),
        selectedHero: $('#HeroDropDown').GetSelected().id
    });
}

function ItemClick(item) {
    GameEvents.SendCustomGameEventToServer("ShopItemButtonPressed", {
        pID: $.GetContextPanel().GetAttributeInt("player_id", -1),
        item: item
    });
}

function SelectHero(data) {
    GameUI.SelectUnit(data.entId, false);
}

(function() {
    $('#HeroDropDown').SetSelected(Players.GetPlayerSelectedHero($.GetContextPanel().GetAttributeInt("player_id", -1)));
    $('#HeroDropDown').SetSelected(undefined);
    GameEvents.Subscribe("select_hero", SelectHero);
})();