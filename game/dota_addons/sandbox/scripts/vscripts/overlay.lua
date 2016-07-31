RANGE_PARTICLE = "particles/custom/range_display.vpcf"
RANGE_PARTICLE_RED = "particles/custom/range_display_red.vpcf"
RANGE_LINE_PARTICLE = "particles/custom/range_display_line.vpcf"
RANGE_LINE_PARTICLE_RED = "particles/custom/range_display_line_red.vpcf"

function CreateParticleBox(min_a, max_a, particle_name, hPlayer)
	local particles = {}
	local particle
	particle = CreateParticleLine(Vector(min_a.x, min_a.y, 0), Vector(min_a.x, max_a.y, 0), particle_name, hPlayer)
	table.insert(particles, particle)
	particle = CreateParticleLine(Vector(min_a.x, min_a.y, 0), Vector(max_a.x, min_a.y, 0), particle_name, hPlayer)
	table.insert(particles, particle)
	particle = CreateParticleLine(Vector(max_a.x, min_a.y, 0), Vector(max_a.x, max_a.y, 0), particle_name, hPlayer)
	table.insert(particles, particle)
	particle = CreateParticleLine(Vector(max_a.x, max_a.y, 0), Vector(min_a.x, max_a.y, 0), particle_name, hPlayer)
	table.insert(particles, particle)
	return particles
end

function CreateParticleLine(a, b, particle_name, hPlayer)
    local particle
    if hPlayer == nil then
        particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, nil)
    else
        particle = ParticleManager:CreateParticleForPlayer(particle_name, PATTACH_WORLDORIGIN, nil, hPlayer)
    end
	ParticleManager:SetParticleControl(particle, 0, a)
	ParticleManager:SetParticleControl(particle, 1, b)
	return particle
end

function CreateParticleCircle(ent, radius, particle_name, hPlayer)
    print ("CreateParticleCircle")
	local particle
    if hPlayer == nil then
        particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, ent)
    else
        particle = ParticleManager:CreateParticleForPlayer(particle_name, PATTACH_ABSORIGIN_FOLLOW, ent, hPlayer)
    end
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, 100, 100))
	return particle
end