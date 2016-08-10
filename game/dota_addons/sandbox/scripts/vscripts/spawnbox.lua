require( "overlay" )

SPAWNBOX = class({})

function SPAWNBOX:constructor(name)
    self.entities = Entities:FindAllByName(name)
    self.name = name
    self.boxes = {}
    for k, ent in pairs(self.entities) do
        table.insert(self.boxes, {
            ent:GetOrigin() + ent:GetBounds().Mins,
            ent:GetOrigin() + ent:GetBounds().Maxs
        })
    end
    self.particles = {}
    self.BlockedByNeutral = false
    self.BlockedByNonNeutral = false
end

function SPAWNBOX:UpdateIsBlockedState(heroes, wards, sentries, neutrals)
    self.BlockedByNeutral = self:IsBlockedByNeutral(neutrals)
    self.BlockedByNonNeutral = self:IsBlockedByNonNeutral(heroes, wards, sentries)
end

function SPAWNBOX:IsBlockedByNeutral(neutrals)
    for j, spawnBoxEnt in pairs(self.entities) do
        if neutrals ~= nil then
            for k,ent in pairs(neutrals) do
                if ent ~= nil and IsValidEntity(ent) then
                    if spawnBoxEnt:IsTouching(ent) then
                        return true
                    end
                end
            end
        end
    end
	return false
end

function SPAWNBOX:IsBlockedByNonNeutral(heroes, wards, sentries)
    for j, spawnBoxEnt in pairs(self.entities) do
        if wards ~= nil then
            for k,ent in pairs(wards) do
                if ent ~= nil and IsValidEntity(ent) then
                    if spawnBoxEnt:IsTouching(ent) then
                        return true
                    end
                end
            end
        end
        if sentries ~= nil then
            for k,ent in pairs(sentries) do
                if ent ~= nil and IsValidEntity(ent) then
                    if spawnBoxEnt:IsTouching(ent) then
                        return true
                    end
                end
            end
        end
        if heroes ~= nil then
            for k,ent in pairs(heroes) do
                if ent ~= nil and IsValidEntity(ent) then
                    if spawnBoxEnt:IsTouching(ent) then
                        return true
                    end
                end
            end
        end
    end
	return false
end

function SPAWNBOX:DrawBoxesForPlayer(hPlayer, particleName)
    local playerID = hPlayer:GetPlayerID()
    if self.particles[playerID] == nil or self.particles[playerID].particleName ~= particleName then
        self:ClearBoxesForPlayer(hPlayer)
        local particles = {}
        for k,box in pairs(self.boxes) do
            table.insert(particles, CreateParticleBox(box[1], box[2], particleName, hPlayer))
        end
        self.particles[playerID] = { particles = particles, particleName = particleName }
    end
end

function SPAWNBOX:ClearBoxesForPlayer(hPlayer)
    local playerID = hPlayer:GetPlayerID()
    if self.particles[playerID] ~= nil then
        for k, box_particles in pairs(self.particles[playerID].particles) do
            for k, particle in pairs(box_particles) do
                ParticleManager:DestroyParticle(particle, true)
                ParticleManager:ReleaseParticleIndex(particle)
            end
        end
        self.particles[playerID] = nil
	end
end