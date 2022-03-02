--LinkLuaModifier( "lua_modifier_whistlepunk_oil_spill_slowburn", "heroes/whistlepunk/ability_2/lua_modifier_whistlepunk_oil_spill", LUA_MODIFIER_MOTION_NONE )

lua_modifier_whistlepunk_sawprise_thinker = class({})


function lua_modifier_whistlepunk_sawprise_thinker:IsHidden()return true end

function lua_modifier_whistlepunk_sawprise_thinker:IsPurgable() return false end

function lua_modifier_whistlepunk_sawprise_thinker:IsPurgeException() return false end




function lua_modifier_whistlepunk_sawprise_thinker:OnCreated(params)

    if not IsServer() then return end

    self.cast_position = Vector(params.cp_x,params.cp_y,params.cp_z)
    self.vector_direction = Vector(params.vd_x,params.vd_y,0)
    self.saw_duration = params.saw_duration
    self.init_damage = params.init_damage
    self.saw_dot = params.saw_dot
    self.saw_aoe = params.saw_aoe
    self.tick_interval = params.tick_interval

    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability  = self:GetAbility()
    self.team_num = self.caster:GetTeamNumber()

    self.has_scepter_upgrade = self.caster:HasScepter()

    self.damage_points = {}
    self.saw_particles = {}


    local temp_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_sandking/sandking_burrowstrike_eruption.vpcf",
        PATTACH_ABSORIGIN,
        self.parent
    )

    ParticleManager:SetParticleControl(temp_particle,0,self.cast_position)
    ParticleManager:SetParticleControl(temp_particle,1,self.cast_position)
    ParticleManager:ReleaseParticleIndex(temp_particle)


    for i = -8,8,1 do

        local new_position = self.cast_position+(self.vector_direction*50*i)
        self.damage_points[i] = new_position

        local abs_val = math.abs(i)
        if abs_val ~= 8 then
            --provide vision
            AddFOWViewer(
                self.team_num,
                new_position,
                self.saw_aoe,
                self.saw_duration,
                true
            )

            --destroy trees
            GridNav:DestroyTreesAroundPoint(
                new_position,
                self.saw_aoe,
                false
            )

            --particle placements
            if math.fmod(abs_val,2) ~= 0 then
                --place eruption
                temp_particle = ParticleManager:CreateParticle(
                   "particles/units/heroes/hero_sandking/sandking_burrowstrike_eruption.vpcf",
                   PATTACH_ABSORIGIN,
                   self.parent
                )
                ParticleManager:SetParticleControl(temp_particle,0,new_position)
                ParticleManager:SetParticleControl(temp_particle,1,new_position)
                ParticleManager:ReleaseParticleIndex(temp_particle)


                --place the saws
                self.saw_particles[i] = ParticleManager:CreateParticle(
                    "particles/units/heroes/whisltepunk/ability_4/spinner_stay.vpcf",
                    PATTACH_ABSORIGIN,
                    self.parent
                )

                ParticleManager:SetParticleControl(self.saw_particles[i],0,GetGroundPosition(new_position,nil))
                ParticleManager:SetParticleControl(self.saw_particles[i],15,Vector(255,0,0))

            end

        end

    end

    --debug
    --[[
    DebugDrawLine(
        self.damage_points[-8],
        self.damage_points[8],
        255,
        0,
        0,
        false,
        self.saw_duration
    )]]

    --damage enemies
    self:damage_enemies_near(self.init_damage)

    self:StartIntervalThink(self.tick_interval)

    self.parent:EmitSound("Hero_Shredder.WhirlingDeath.Cast")
    self.parent:EmitSound("Hero_Shredder.Chakram")
end




function lua_modifier_whistlepunk_sawprise_thinker:OnIntervalThink()
    if not IsServer() then return end

    self:damage_enemies_near(self.saw_dot)
    self.saw_duration = self.saw_duration - self.tick_interval
    if self.saw_duration <= 0 then
        self:StartIntervalThink(-1)
        self.parent:StopSound("Hero_Shredder.Chakram")
        self:Destroy()
    end
end




function lua_modifier_whistlepunk_sawprise_thinker:OnDestroy()
    if not IsServer() then return end

    for _,particle in pairs(self.saw_particles) do
        ParticleManager:DestroyParticle(particle,false)
        ParticleManager:ReleaseParticleIndex(particle)
    end

    self.saw_particles = nil
    UTIL_Remove(self.parent)
end




function lua_modifier_whistlepunk_sawprise_thinker:damage_enemies_near(dmg)

    if not IsServer() then return end

    local dflags = DOTA_UNIT_TARGET_FLAG_NONE
    if self.has_scepter_upgrade == true then
        dflags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local enemies = FindUnitsInLine(
		self.team_num,
		self.damage_points[-8],
        self.damage_points[8],
		nil,
		self.saw_aoe,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		dflags
	)

    local enemy_present = false


	for _,enemy in pairs(enemies) do
        enemy_present = true
        local dtable = {
            victim = enemy,
            attacker = self.caster,
            damage = dmg,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = dflags,
            ability = self.ability
        }

        ApplyDamage(dtable)
	end



    if enemy_present == true then
        self.parent:EmitSound("Hero_Shredder.Chakram.Target")
    end

    self:has_scepter_upgrade_oil_spill()
end




function lua_modifier_whistlepunk_sawprise_thinker:has_scepter_upgrade_oil_spill()

    if self.has_scepter_upgrade == false then return end

    local oil_ability = self.caster:FindAbilityByName("lua_ability_whistlepunk_oil_spill")

    if not oil_ability then return end

    if oil_ability:GetLevel() == 0 then return end

    if not IsServer() then return end

    for num,pos in pairs(self.damage_points) do

        if math.fmod(num,3) == 0 then

            local splat = ParticleManager:CreateParticle(
                "particles/units/heroes/whisltepunk/ability_2/whistlepunk_sludge_splat_endcap.vpcf",
                PATTACH_ABSORIGIN,
                self.caster
            )

            local aboveground = GetGroundPosition(pos,nil)
            ParticleManager:SetParticleControl(splat,0,aboveground)
            ParticleManager:ReleaseParticleIndex(splat)

            --AddFOWViewer(self.teamnumber,location,self.ability_aoe,1.0,false)
            --DebugDrawCircle(location,Vector(255,0,0),1,self.ability_aoe,true,1.0)

            --oil near enemies
            local oiled_enemies = FindUnitsInRadius(
                self.caster:GetTeamNumber(),
                pos,
                nil,
                oil_ability:GetSpecialValueFor("ability_aoe"),
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
            )

            --loop enemies
            for _,enemy in pairs(oiled_enemies) do
                enemy:AddNewModifier(
            		self.caster,
            		oil_ability, -- ability source
            		"lua_modifier_whistlepunk_oil_spill_slowburn", -- modifier name
            		{duration = oil_ability:GetSpecialValueFor("slow_duration")}
            	)
        	end

        end

    end

    self.caster:EmitSound("Hero_Alchemist.AcidSpray.Damage")
end
