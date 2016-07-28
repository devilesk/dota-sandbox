var NUM_TABS = 5;
var playerID = Players.GetLocalPlayer();
var hostTimeScaleIndex = 1;
var hostTimeScaleValues = [0.5, 1, 2, 4, 8];
var indicator;

function SelectedPlayerToKey() {
    return (parseInt($('#PlayerDropDown').GetSelected().id.replace('player', '')) - 1).toString();
}

function IsPlayerSelected(key) {
    return key == SelectedPlayerToKey();
}

function RefreshStats() {
    var hero = Players.GetPlayerHeroEntityIndex(parseInt(SelectedPlayerToKey()));
    $('#ASValue').text = Entities.GetAttacksPerSecond(hero).toFixed(2);
    ////$.Msg( "In function RefreshStats():", {value: $('#TDTValue').text } );
    $.Schedule(0.1, RefreshStats);
}

$.Schedule(0.1, RefreshStats);

function OnPlayerDropDownChanged() {
    //$.Msg("OnPlayerDropDownChanged");
    var key = SelectedPlayerToKey();
    $('#DPSValue').text = CustomNetTables.GetTableValue("dps_nettable", key).value.toFixed(0);
    $('#DPS10Value').text = CustomNetTables.GetTableValue("dps10_nettable", key).value.toFixed(0);
    $('#LastAttackValue').text = CustomNetTables.GetTableValue("la_nettable", key).value.toFixed(0);
    $('#TotalDamageValue').text = CustomNetTables.GetTableValue("td_nettable", key).value.toFixed(0);
}

function OnCheatModeNettableChanged(table_name, key, data) {
    var v = data.value == true;
    //$.Msg( "Table ", table_name, " changed: '", key, "' = ", data, data.value == true);
    $('#RemoveSpawnsPanel').visible = v;
    $('#CheatsPanel1').visible = v;
    $('#CheatsPanel2').visible = v;
    $('#CheatsPanel3').visible = v;
    $('#CheatsPanel4').visible = v;
    $('#CheatsPanel5').visible = v;
}
CustomNetTables.SubscribeNetTableListener("cheatmode_nettable", OnCheatModeNettableChanged);

//var data = //$.Msg( CustomNetTables.GetTableValue( "dps_nettable", "0" ) );
////$.Msg( "CustomNetTables.GetTableValue ", {data: data } );
function OnNettableChanged(table_name, key, data) {
    //$.Msg( "Table ", table_name, " changed: '", key, "' = ", data );
    if (IsPlayerSelected(key)) {
        $('#DPSValue').text = data.value.toFixed(0);
    }
}
CustomNetTables.SubscribeNetTableListener("dps_nettable", OnNettableChanged);

function OnDPS10NettableChanged(table_name, key, data) {
    //$.Msg( "Table ", table_name, " changed: '", key, "' = ", data );
    if (IsPlayerSelected(key)) {
        $('#DPS10Value').text = data.value.toFixed(0);
    }
}
CustomNetTables.SubscribeNetTableListener("dps10_nettable", OnDPS10NettableChanged);

function OnLastDamageTakenNettableChanged(table_name, key, data) {
    //$.Msg( "Table ", table_name, " changed: '", key, "' = ", data, " ", $('#PlayerDropDown').GetSelected().id.replace('player', '') );
    if (IsPlayerSelected(key)) {
        $('#LastDamageTakenValue').text = data.value.toFixed(0);
    }
}
CustomNetTables.SubscribeNetTableListener("dt_nettable", OnLastDamageTakenNettableChanged);

function OnTotalDamageTakenNettableChanged(table_name, key, data) {
    //$.Msg( "Table ", table_name, " changed: '", key, "' = ", data, " ", $('#PlayerDropDown').GetSelected().id.replace('player', '') );
    if (IsPlayerSelected(key)) {
        $('#TotalDamageTakenValue').text = data.value.toFixed(0);
    }
}
CustomNetTables.SubscribeNetTableListener("tdt_nettable", OnTotalDamageTakenNettableChanged);

function OnLastAttackNettableChanged(table_name, key, data) {
    //$.Msg( "Table ", table_name, " changed: '", key, "' = ", data, " ", $('#PlayerDropDown').GetSelected().id.replace('player', '') );
    if (IsPlayerSelected(key)) {
        $('#LastAttackValue').text = data.value.toFixed(0);
    }
}
CustomNetTables.SubscribeNetTableListener("la_nettable", OnLastAttackNettableChanged);

function OnTotalDamageNettableChanged(table_name, key, data) {
    //$.Msg( "Table ", table_name, " changed: '", key, "' = ", data, " ", $('#PlayerDropDown').GetSelected().id.replace('player', '') );
    if (IsPlayerSelected(key)) {
        $('#TotalDamageValue').text = data.value.toFixed(0);
    }
}
CustomNetTables.SubscribeNetTableListener("td_nettable", OnTotalDamageNettableChanged);

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
    //$.Msg( "In function OnNeutralSpawnIntervalDropDownChanged():", {value: value } );
    GameEvents.SendCustomGameEventToServer("NeutralSpawnIntervalChange", {
        value: value
    });
}

function OnHostTimeScaleSpeedChange(dir) {
    if (dir == 0) {
        hostTimeScaleIndex = 1;
    } else if (hostTimeScaleIndex + dir >= 0 && hostTimeScaleIndex + dir < hostTimeScaleValues.length) {
        hostTimeScaleIndex += dir;
    }
    var value = hostTimeScaleValues[hostTimeScaleIndex];
    $('#HostTimeScaleValueLabel').text = value + 'X';
    //$.Msg( "In function OnHostTimeScaleSpeedChange():", {value: value } );
    GameEvents.SendCustomGameEventToServer("HostTimeScaleChange", {
        value: value
    });
}

function FireCustomGameEvent(eventName) {
    //$.Msg( "In function FireCustomGameEvent():", {eventName: eventName, selectedHero: $('#HeroDropDown').GetSelected().id, goldAmount: $('#GoldAmount').text } );
    var playerId = Players.GetLocalPlayer();
    var selectedUnits = Players.GetSelectedEntities(playerId);
    var data = {
        eventName: eventName,
        selectedHero: $('#HeroDropDown').GetSelected().id,
        selectedUnits: selectedUnits,
        goldAmount: $('#GoldAmount').text,
        selectedPlayerID: SelectedPlayerToKey()
    }
    GameEvents.SendCustomGameEventToServer(eventName, data);
    if (eventName == "TeleportButtonPressed" || eventName == "SpawnAllyButtonPressed" || eventName == "SpawnEnemyButtonPressed") {
        //$.Msg( "indicator");
        var unit = Players.GetLocalPlayerPortraitUnit();
        if (indicator) indicator.Delete();
        indicator = new GlobalTargetIndicator({}, unit);
    }
}

function FireOverlayToggleEvent(eventName) {
    //$.Msg( "In function FireOverlayToggleEvent():", {eventName: eventName, value: $('#' + eventName).checked } );
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
                    //$.Msg( "In function SetMouseCallback():", {eventName: eventName, arg: arg, pos: pos, selectedUnits: selectedUnits } );

                GameEvents.SendCustomGameEventToServer("MouseClick", {
                    "pos": pos,
                    "selectedUnits": selectedUnits
                });
                if (indicator) indicator.Delete();
            } else {
                //$.Msg("coordinates null");
            }
        }
    }

    return CONTINUE_PROCESSING_EVENT;
});

(function() {
    $('#HeroDropDown').SetSelected("npc_dota_hero_abaddon");
    $('#NeutralSpawnIntervalDropDown').SetSelected("i_60");
    UpdatePosition();
})();

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