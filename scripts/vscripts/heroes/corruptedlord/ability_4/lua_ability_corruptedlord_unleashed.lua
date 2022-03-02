LinkLuaModifier( "lua_modifier_corruptedlord_unleashed_transform_animation", "heroes/corruptedlord/ability_4/lua_modifier_corruptedlord_unleashed", LUA_MODIFIER_MOTION_NONE )


lua_ability_corruptedlord_unleashed = class({})


function lua_ability_corruptedlord_unleashed:Init()
    self.caster = self:GetCaster()
end



function lua_ability_corruptedlord_unleashed:OnSpellStart()

    self.caster = self:GetCaster()

    self.team_num = self.caster:GetTeamNumber()
    self.transform_duration = self:GetSpecialValueFor("ult_duration")
    self.fear_aoe_range = self:GetSpecialValueFor("fear_aoe_range")
    self.fear_duration = self:GetSpecialValueFor("fear_duration")
    self.self_damage = self:GetSpecialValueFor("self_damage")



    if IsServer() == false then return end
    self:GetCaster():EmitSound("Hero_Terrorblade.Metamorphosis")

    --acting
    self.caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)

    local has_aghs = 1
    if self.caster:HasScepter() == true then
        has_aghs = 2
    end


    --25% self damage
    local pure_damage_self = {
        victim = self.caster,
        attacker = self.caster,
        damage = self.caster:GetHealth()*self.self_damage*0.01*has_aghs,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
        ability = self
    }
    ApplyDamage(pure_damage_self)



    --transform animation then this modifier will transform him to demon
    self.transform_modifier =  self.caster:AddNewModifier(
        self.caster,
        self,
        "lua_modifier_corruptedlord_unleashed_transform_animation",
        {duration = 0.35}
    )

    --
    local wave_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_scepter.vpcf", PATTACH_ABSORIGIN , self.caster)
    ParticleManager:SetParticleControl(wave_particle, 0, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(wave_particle, 1, Vector(200, 0, 0))
    ParticleManager:ReleaseParticleIndex(wave_particle)


    --find enemies near and fear them
    local fear_enemies = FindUnitsInRadius(
        self.team_num,
        self.caster:GetAbsOrigin(),
        nil,
        self.fear_aoe_range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )

    --the fear modifier
    for _,enemy in pairs(fear_enemies) do

        if (enemy:IsNull() == false) and (enemy:IsAlive() == true) and (IsValidEntity(enemy) == true) then

            if enemy:IsMagicImmune() == false then

                enemy:AddNewModifier(
            		self.caster,
            		self, -- ability source
            		"modifier_terrorblade_fear", -- modifier name
            		{duration = self.fear_duration}
            	)
            end

            self:aghanim_effects_damage_enemies(enemy)
            
        end
	end


    self.caster:EmitSound("Hero_Terrorblade.Metamorphosis.Scepter")

    local responses = {
		"terrorblade_terr_morph_metamorphosis_01",
		"terrorblade_terr_morph_metamorphosis_02",
		"terrorblade_terr_morph_metamorphosis_03",
		"terrorblade_terr_morph_metamorphosis_04",
		"terrorblade_terr_morph_metamorphosis_05",
		"terrorblade_terr_morph_metamorphosis_06",
		"terrorblade_terr_morph_metamorphosis_07",
		"terrorblade_terr_morph_metamorphosis_08",
		"terrorblade_terr_morph_metamorphosis_09",
		"terrorblade_terr_morph_demon_12",
		"terrorblade_terr_morph_demon_13",
		"terrorblade_terr_morph_demon_14"
	}

    self.caster:EmitSound(responses[RandomInt(1, #responses)])
end




function lua_ability_corruptedlord_unleashed:aghanim_effects_damage_enemies(enemy)
    if self.caster:HasScepter() == false then return end

    if enemy:GetName() == "npc_dota_roshan" then return end

    local enemy_damage = enemy:GetHealth()*self.self_damage*0.01*2.0
    local pure_damage = {
        victim = enemy,
        attacker = self.caster,
        damage = enemy_damage,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
        ability = self
    }
    ApplyDamage(pure_damage)

end




function lua_ability_corruptedlord_unleashed:GetCooldown(level)
    local talent = self.caster:FindAbilityByName("special_bonus_corruptedlord_unleashed_cooldown")
    self.ability_cd = self:GetSpecialValueFor("ability_cd")
    if not talent == false then
        if talent:GetLevel() > 0 then
            return self.ability_cd - talent:GetSpecialValueFor("value")
        end
    end
    return self.ability_cd
end
