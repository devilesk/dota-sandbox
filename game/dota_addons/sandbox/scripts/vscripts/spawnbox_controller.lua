require( "overlay" )
require( "spawnbox" )

SPAWNBOXCONTROLLER = class({})

function SPAWNBOXCONTROLLER:constructor()
  self.SpawnBoxes = {}
  self:InitBoxes()
end

function SPAWNBOXCONTROLLER:InitBoxes()
    local boxes = Entities:FindAllByClassname("trigger_multiple")
    for k,ent in pairs(boxes) do
        local name = ent:GetName()
        if string.find(name, "neutralcamp") ~= nil then
            if self.SpawnBoxes[name] == nil then
                self.SpawnBoxes[name] = SPAWNBOX(name)
            end
        end
    end
end

function SPAWNBOXCONTROLLER:UpdateIsBlockedState(heroes, wards, sentries, neutrals)
    for k, spawnBox in pairs(self.SpawnBoxes) do
        spawnBox:UpdateIsBlockedState(heroes, wards, sentries, neutrals)
    end
end

function SPAWNBOXCONTROLLER:UpdateOverlayForPlayer(hPlayer, bShowBox, bDetectNeutrals)
    for k, spawnBox in pairs(self.SpawnBoxes) do
        if bShowBox then
            local particleName = self:GetSpawnBoxParticleName(spawnBox, bDetectNeutrals)
            spawnBox:DrawBoxesForPlayer(hPlayer, particleName)
        else
            spawnBox:ClearBoxesForPlayer(hPlayer)
        end
    end
end

function SPAWNBOXCONTROLLER:GetSpawnBoxParticleName(spawnBox, bDetectNeutrals)
    if spawnBox.BlockedByNonNeutral then
        return RANGE_LINE_PARTICLE_RED
    elseif spawnBox.BlockedByNeutral and bDetectNeutrals then
        return RANGE_LINE_PARTICLE_RED
    else
        return RANGE_LINE_PARTICLE
    end
end