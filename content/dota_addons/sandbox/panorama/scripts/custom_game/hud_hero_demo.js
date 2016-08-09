var NUM_TABS = 5;
var playerID = Players.GetLocalPlayer();
var hostTimeScaleIndex = 1;
var hostTimeScaleValues = [0.5, 1, 2, 4, 8];
var indicator;
var selectedHero = 'npc_dota_hero_abaddon';

function SelectedPlayerToKey() {
    return (parseInt($('#PlayerDropDown').GetSelected().id.replace('player', '')) - 1).toString();
}

function IsPlayerSelected(key) {
    return key == SelectedPlayerToKey();
}

function RefreshStats() {
    var selectedPlayer = parseInt(SelectedPlayerToKey());
    var hero = Players.GetPlayerHeroEntityIndex(selectedPlayer);
    $('#ASValue').text = Entities.GetAttacksPerSecond(hero).toFixed(2);
    $('#TotalGoldEarnedValue').text = Players.GetTotalEarnedGold(selectedPlayer);
    $('#GPMValue').text = Players.GetGoldPerMin(selectedPlayer).toFixed(2);
    $('#XPMValue').text = Players.GetXPPerMin(selectedPlayer).toFixed(2);
    $.Schedule(0.1, RefreshStats);
}

$.Schedule(0.1, RefreshStats);

function OnPlayerDropDownChanged() {
    var key = SelectedPlayerToKey();
    for (var netTable in netTableLabelMap) {
        if (netTableLabelMap.hasOwnProperty(netTable)) {
            netTableLabelMap[netTable].text = CustomNetTables.GetTableValue(netTable, key).value.toFixed(0);
        }
    }
}

function NetTableChangedLabelUpdater(netTable, labelElement) {
    return function (table_name, key, data) {
        if (IsPlayerSelected(key)) {
            labelElement.text = data.value.toFixed(0);
        }
    }
}

function NetTableListenerInit(netTable, labelElement) {
    CustomNetTables.SubscribeNetTableListener(netTable, NetTableChangedLabelUpdater(netTable, labelElement));
}

var netTableLabelMap = {
    "dps_nettable": $('#DPSValue'),
    "dps10_nettable": $('#DPS10Value'),
    "dt_nettable": $('#LastDamageTakenValue'),
    "tdt_nettable": $('#TotalDamageTakenValue'),
    "la_nettable": $('#LastAttackValue'),
    "td_nettable": $('#TotalDamageValue')
}

for (var netTable in netTableLabelMap) {
    if (netTableLabelMap.hasOwnProperty(netTable)) {
        NetTableListenerInit(netTable, netTableLabelMap[netTable]);
    }
}

function ToggleTab(index) {
    for (var i = 1; i <= NUM_TABS; i++) {
        $('#TabButton' + i).RemoveClass('TabActive');
        $('#TabContent' + i).RemoveClass('TabContentActive');
    }
    $('#TabButton' + index).AddClass('TabActive');
    $('#TabContent' + index).AddClass('TabContentActive');

    $.GetContextPanel().RemoveClass('Minimized');
}

ToggleTab(1);

function OnNeutralSpawnIntervalDropDownChanged() {
    var value = parseInt($('#NeutralSpawnIntervalDropDown').GetSelected().id.split('_')[1]);
    GameEvents.SendCustomGameEventToServer("NeutralSpawnIntervalChange", {
        value: value
    });
}

function UpdateNeutralSpawnIntervalUI(data) {
    $('#NeutralSpawnIntervalDropDown').SetSelected('i_' + data.value.toString());
}

function OnHostTimeScaleSpeedChange(dir) {
    if (dir == 0) {
        hostTimeScaleIndex = 1;
    } else if (hostTimeScaleIndex + dir >= 0 && hostTimeScaleIndex + dir < hostTimeScaleValues.length) {
        hostTimeScaleIndex += dir;
    }
    var value = hostTimeScaleValues[hostTimeScaleIndex];
    $('#HostTimeScaleValueLabel').text = value + 'X';
    GameEvents.SendCustomGameEventToServer("HostTimeScaleChange", {
        value: value,
        hostTimeScaleIndex: hostTimeScaleIndex
    });
}

function UpdateHostTimeScaleUI(data) {
    $('#HostTimeScaleValueLabel').text = data.value.toString() + 'X';
    hostTimeScaleIndex = parseInt(data.hostTimeScaleIndex);
}

function FireCustomGameEvent(eventName) {
    var playerId = Players.GetLocalPlayer();
    var selectedUnits = Players.GetSelectedEntities(playerId);
    var data = {
        eventName: eventName,
        selectedHero: selectedHero,
        selectedUnits: selectedUnits,
        goldAmount: $('#GoldAmount').text,
        selectedPlayerID: SelectedPlayerToKey()
    }
    GameEvents.SendCustomGameEventToServer(eventName, data);
    if (eventName == "TeleportButtonPressed" || eventName == "SpawnAllyButtonPressed" || eventName == "SpawnEnemyButtonPressed") {
        var unit = Players.GetLocalPlayerPortraitUnit();
        if (indicator) indicator.Delete();
        indicator = new GlobalTargetIndicator({}, unit);
    }
}

function FireOverlayToggleEvent(eventName) {
    GameEvents.SendCustomGameEventToServer(eventName, {
        overlayName: eventName,
        value: $('#' + eventName).checked
    });
}

// This is an example of how to use the GameUI.SetMouseCallback function
GameUI.SetMouseCallback(function(eventName, arg) {
    var CONSUME_EVENT = true;
    var CONTINUE_PROCESSING_EVENT = false;
    if (eventName == "pressed") {
        // Left-click is move to position
        if (arg === 0) {
            var playerId = Players.GetLocalPlayer();
            var selectedUnits = Players.GetSelectedEntities(playerId);
            var coordinates = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
            if (coordinates != null) {
                var pos = {
                        x: coordinates[0],
                        y: coordinates[1],
                        z: coordinates[2]
                    }
                GameEvents.SendCustomGameEventToServer("MouseClick", {
                    "pos": pos,
                    "selectedUnits": selectedUnits
                });
                if (indicator) indicator.Delete();
            }
        }
    }
    return CONTINUE_PROCESSING_EVENT;
});

function UpdateToggleUI(data) {
    for (var i in data) {
        if (data.hasOwnProperty(i)) {
            var toggleElement = $('#' + i);
            if (toggleElement) {
                toggleElement.checked = data[i] == 1;
            }
        }
    }
}

(function() {
    $('#BuildingInvulnerability_Button').checked = true;
    $('#NeutralSpawnIntervalDropDown').SetSelected("i_60");
    UpdatePosition();
    GameEvents.Subscribe( "update_toggle_ui", UpdateToggleUI );
    GameEvents.Subscribe( "update_neutral_spawn_interval_ui", UpdateNeutralSpawnIntervalUI );
    GameEvents.Subscribe( "update_host_time_scale_ui", UpdateHostTimeScaleUI );
})();

function OpenCustomDropDown() {
    GameUI.CustomUIConfig().CustomDropDown.OpenFor = $.GetContextPanel();
    var CustomDropDown = GameUI.CustomUIConfig().CustomDropDown;
    var pos = CustomDropDown.GetAbsoluteOffset($.GetContextPanel(), $("#HeroCustomDropDown"));
    CustomDropDown.SetPos(pos);
    CustomDropDown.OnHeroSelected = OnHeroSelected;
    CustomDropDown.OnClose = OnClose;
    CustomDropDown.Open();
}

function CloseCustomDropDown() {
    GameUI.CustomUIConfig().CustomDropDown.Close();
}

function OnClose() {
    $("#HeroCustomDropDown").SetFocus();
}

function OnHeroSelected(heroId, heroName) {
    selectedHero = heroId;
    $("#HeroCustomDropDownLabel").text = heroName;
    $("#HeroCustomDropDown").SetFocus();
}

function GlobalTargetIndicator(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(cursor) {
        var to = UpdateLine(this.particle, this.unit, this.data, cursor);
        var result = to.minus(Vector.FromArray(Entities.GetAbsOrigin(unit))).normalize().add(to);
        Particles.SetParticleControl(this.particle, 2, result);
    }

    this.Delete = function() {
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

function UpdatePosition() {
    var cursor = GameUI.GetCursorPosition();
    var position = GameUI.GetScreenWorldPosition(cursor);

    if (position && indicator) {
        indicator.Update(position);
    }
    $.Schedule(0.01, UpdatePosition);
}

function GetNumber(value, or, unit) {
    if (!value) {
        return or;
    }

    if (IsNumeric(value)) {
        return value;
    }

    return eval(value);
}

function Clamp(num, min, max) {
    return num < min ? min : num > max ? max : num;
}

function UpdateLine(particle, unit, data, cursor) {
    var pos = Vector.FromArray(Entities.GetAbsOrigin(unit));
    var to = Vector.FromArray(cursor);

    var length = to.minus(pos).length();
    var newLength = Clamp(length, GetNumber(data.MinLength, 0, unit), GetNumber(data.MaxLength, Number.MAX_VALUE, unit));

    if (length != newLength) {
        length = newLength;
        to = to.minus(pos).normalize().scale(length).add(pos);
    }

    Particles.SetParticleControl(particle, 1, to);

    return to;
}