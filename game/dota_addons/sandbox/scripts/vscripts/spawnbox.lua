function DeleteParticleBoxes(boxData)
	for k,box_particles in pairs(boxData.particles) do
		for k,particle in pairs(box_particles) do
			ParticleManager:DestroyParticle(particle, true)
		end
	end
	boxData.particles = nil
end

function CreateParticleBoxes(hero, wards, sentries, neutrals, boxData)
	local isRed = IsInBoxes(hero, wards, sentries, neutrals, boxData.boxes, boxData.name)
	if GameRules.herodemo.overlays.ShowNeutralSpawnBoxButtonPressed == true then
	--if OverlayState["cbNeutralSpawnBox"] == true then
		if boxData.particles == nil or boxData.isRed ~= isRed then
			if boxData.particles ~= nil then
				DeleteParticleBoxes(boxData)
			end
			local box_particles = {}
            for k,box in pairs(boxData.boxes) do
                --[[if boxData.name ~= "neutralcamp_good_5" then
                    table.insert(box_particles, CreateParticleBox(hero, box[1], box[2], isRed))
                else
                    table.insert(box_particles, CreateParticleBox5(hero, box[1], box[2], isRed))
                end]]
                table.insert(box_particles, CreateParticleBox(hero, box[1], box[2], isRed))
            end
			boxData.particles = box_particles
			boxData.isRed = isRed
		end
	else
		if boxData.particles ~= nil then
			DeleteParticleBoxes(boxData)
		end
	end

end

function IsInBoxes(hero, wards, sentries, neutrals, boxes, name)
    local camp_boxes = Entities:FindAllByClassname("trigger_multiple")
    for j,camp_box in pairs(camp_boxes) do
        if camp_box:GetName() == name then
            if wards ~= nil then
                for k,ent in pairs(wards) do
                    if ent ~= nil and IsValidEntity(ent) then
                        if camp_box:IsTouching(ent) then
                            camp_boxes = nil
                            return true
                        end
                    end
                end
            end
            if sentries ~= nil then
                for k,ent in pairs(sentries) do
                    if ent ~= nil and IsValidEntity(ent) then
                        if camp_box:IsTouching(ent) then
                            camp_boxes = nil
                            return true
                        end
                    end
                end
            end
            --if neutrals ~= nil and OverlayState["cbDetectNeutrals"] == true then
            if neutrals ~= nil and GameRules.herodemo.overlays.DetectNeutralsButtonPressed == true then
                for k,ent in pairs(neutrals) do
                    if ent ~= nil and IsValidEntity(ent) then
                        if camp_box:IsTouching(ent) then
                            camp_boxes = nil
                            return true
                        end
                    end
                end
            end
            if hero ~= nil then
                if camp_box:IsTouching(hero) then
                    camp_boxes = nil
                    return true
                end
            end
        end
    end
    camp_boxes = nil
	return false
end

function CreateParticleBox5(ent, min_a, max_a, isRed)
    local particles = {}
    local particle

	particle = CreateParticleLine(ent, Vector(-1728, -3520, 0), Vector(-704, -3520, 0), isRed)
	table.insert(particles, particle)

	particle = CreateParticleLine(ent, Vector(-704, -3520, 0), Vector(-704, -4480, 0), isRed)
	table.insert(particles, particle)
    
	particle = CreateParticleLine(ent, Vector(-704, -4480, 0), Vector(-1344, -4480, 0), isRed)
	table.insert(particles, particle)
    
	particle = CreateParticleLine(ent, Vector(-1344, -4480, 0), Vector(-1344, -4224, 0), isRed)
	table.insert(particles, particle)
    
	particle = CreateParticleLine(ent, Vector(-1344, -4224, 0), Vector(-1728, -4224, 0), isRed)
	table.insert(particles, particle)
    
	particle = CreateParticleLine(ent, Vector(-1728, -4224, 0), Vector(-1728, -3520, 0), isRed)
	table.insert(particles, particle)
    
    return particles
end

function CreateParticleBox(ent, min_a, max_a, isRed)
	local particles = {}
	local particle
	particle = CreateParticleLine(ent, Vector(min_a.x, min_a.y, 0), Vector(min_a.x, max_a.y, 0), isRed)
	table.insert(particles, particle)
	particle = CreateParticleLine(ent, Vector(min_a.x, min_a.y, 0), Vector(max_a.x, min_a.y, 0), isRed)
	table.insert(particles, particle)
	particle = CreateParticleLine(ent, Vector(max_a.x, min_a.y, 0), Vector(max_a.x, max_a.y, 0), isRed)
	table.insert(particles, particle)
	particle = CreateParticleLine(ent, Vector(max_a.x, max_a.y, 0), Vector(min_a.x, max_a.y, 0), isRed)
	table.insert(particles, particle)
	return particles
end

function CreateParticleLine(ent, a, b, isRed)
	local particle
	if isRed then
		particle = ParticleManager:CreateParticle("particles/custom/range_display_line_red.vpcf", PATTACH_WORLDORIGIN, ent)
	else
		particle = ParticleManager:CreateParticle("particles/custom/range_display_line.vpcf", PATTACH_WORLDORIGIN, ent)
	end
	ParticleManager:SetParticleControl(particle, 0, a)
	ParticleManager:SetParticleControl(particle, 1, b)
	return particle
end

function CreateRangeParticle(ent, radius, isRed)
	local particle
	if isRed then
		particle = ParticleManager:CreateParticle("particles/custom/range_display_red.vpcf", PATTACH_ABSORIGIN_FOLLOW, ent)
	else
		particle = ParticleManager:CreateParticle("particles/custom/range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, ent)
	end
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, 100, 100))
	return {particle, isRed}
end

function CheckAndDrawCircle(hero, towers, wards, sentries)
	CircleParticle(hero, "HeroXPRangeButtonPressed", "HeroXPRange", 1300, false)
	CircleParticle(hero, "BlinkRangeButtonPressed", "BlinkRange", 1200, false)
	if towers ~= nil then
		for k,ent in pairs(towers) do
			if ent ~= nil and IsValidEntity(ent) then
				CircleParticle(ent, "TowerDayVisionRangeButtonPressed", "TowerDayVision", 1800, (hero:GetCenter() - ent:GetCenter()):Length2D() < 1800)
				CircleParticle(ent, "TowerTrueSightRangeButtonPressed", "TowerTrueSight", 900, (hero:GetCenter() - ent:GetCenter()):Length2D() < 900)
				CircleParticle(ent, "TowerNightVisionRangeButtonPressed", "TowerNightVision", 800, (hero:GetCenter() - ent:GetCenter()):Length2D() < 800)
				CircleParticle(ent, "TowerAttackRangeButtonPressed", "TowerAttack", 700 + ent:GetHullRadius(), CalcDistanceBetweenEntityOBB(hero, ent) < 700)
			end
		end
	end
	if wards ~= nil then
		for k,ent in pairs(wards) do
			if ent ~= nil and IsValidEntity(ent) then
				CircleParticle(ent, "WardVisionButtonPressed", "WardVision", 1600, false)
			end
		end
	end
	if sentries ~= nil then
		for k,ent in pairs(sentries) do
			if ent ~= nil and IsValidEntity(ent) then
				CircleParticle(ent, "SentryVisionButtonPressed", "WardVision", 150, false)
				CircleParticle(ent, "SentryVisionButtonPressed", "TrueSightVision", 850, false)
			end
		end
	end
end

function CircleParticle(ent, overlayName, particleName, radius, isRed)
	if GameRules.herodemo.overlays[overlayName] == true then
	--if OverlayState[overlayName] == true then
		if ent._Particles[particleName] ~= nil then
			if ent._Particles[particleName][2] ~= isRed then
				ParticleManager:DestroyParticle(ent._Particles[particleName][1], true)
				ent._Particles[particleName] = CreateRangeParticle(ent, radius, isRed)
			end
		else
			ent._Particles[particleName] = CreateRangeParticle(ent, radius, isRed)
		end
	else
		if ent._Particles[particleName] ~= nil then
			ParticleManager:DestroyParticle(ent._Particles[particleName][1], true)
			ent._Particles[particleName] = nil
		end
	end
end