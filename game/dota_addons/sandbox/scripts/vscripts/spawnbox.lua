RANGE_PARTICLE = "particles/custom/range_display.vpcf"
RANGE_PARTICLE_RED = "particles/custom/range_display_red.vpcf"
RANGE_LINE_PARTICLE = "particles/custom/range_display_line.vpcf"
RANGE_LINE_PARTICLE_RED = "particles/custom/range_display_line_red.vpcf"

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
    self.particles = nil
    self.isRed = false
end

function SPAWNBOX:IsBlocked(heroes, wards, sentries, neutrals)
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
        if neutrals ~= nil then
            for k,ent in pairs(neutrals) do
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

function SPAWNBOX:GetParticleName()
    if self.isRed then
        return RANGE_LINE_PARTICLE_RED
    else
        return RANGE_LINE_PARTICLE
    end
end

function SPAWNBOX:CreateParticleBoxes(heroes, wards, sentries, neutrals)
	local isRed = self:IsBlocked(heroes, wards, sentries, neutrals)
    if self.particles == nil or self.isRed ~= isRed then
        if self.particles ~= nil then
            self:DeleteParticleBoxes()
        end
        local box_particles = {}
        local particle_name = self:GetParticleName()
        for k,box in pairs(self.boxes) do
            table.insert(box_particles, CreateParticleBox(box[1], box[2], particle_name))
        end
        self.particles = box_particles
        self.isRed = isRed
    end
end

function SPAWNBOX:DeleteParticleBoxes()
    if self.particles ~= nil then
        for k,box_particles in pairs(self.particles) do
            for k,particle in pairs(box_particles) do
                ParticleManager:DestroyParticle(particle, true)
            end
        end
        self.particles = nil
	end
end

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

function SPAWNBOXCONTROLLER:DrawBoxes(heroes, wards, sentries, neutrals)
    for k, spawnBox in pairs(self.SpawnBoxes) do
        spawnBox:CreateParticleBoxes(heroes, wards, sentries, neutrals)
    end
end

function SPAWNBOXCONTROLLER:EraseBoxes()
    for k, spawnBox in pairs(self.SpawnBoxes) do
        spawnBox:DeleteParticleBoxes()
    end
end

function CreateParticleBox(min_a, max_a, particle_name)
	local particles = {}
	local particle
	particle = CreateParticleLine(Vector(min_a.x, min_a.y, 0), Vector(min_a.x, max_a.y, 0), particle_name)
	table.insert(particles, particle)
	particle = CreateParticleLine(Vector(min_a.x, min_a.y, 0), Vector(max_a.x, min_a.y, 0), particle_name)
	table.insert(particles, particle)
	particle = CreateParticleLine(Vector(max_a.x, min_a.y, 0), Vector(max_a.x, max_a.y, 0), particle_name)
	table.insert(particles, particle)
	particle = CreateParticleLine(Vector(max_a.x, max_a.y, 0), Vector(min_a.x, max_a.y, 0), particle_name)
	table.insert(particles, particle)
	return particles
end

function CreateParticleLine(a, b, particle_name)
	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, a)
	ParticleManager:SetParticleControl(particle, 1, b)
	return particle
end

function CreateParticleCircle(ent, radius, particle_name)
	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, ent)
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, 100, 100))
	return particle
end