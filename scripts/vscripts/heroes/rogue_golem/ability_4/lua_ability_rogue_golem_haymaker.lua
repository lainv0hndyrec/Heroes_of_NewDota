LinkLuaModifier( "lua_modifier_rogue_golem_haymaker_buff", "heroes/rogue_golem/ability_4/lua_modifier_rogue_golem_haymaker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_rogue_golem_haymaker_slow", "heroes/rogue_golem/ability_4/lua_modifier_rogue_golem_haymaker", LUA_MODIFIER_MOTION_NONE )


lua_ability_rogue_golem_haymaker = class({})



function lua_ability_rogue_golem_haymaker:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_rogue_golem_haymaker:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    if self:GetCaster():HasScepter() then
        ability_cd = ability_cd - self:GetSpecialValueFor("scepter_cd")
    end
    return ability_cd
end


function lua_ability_rogue_golem_haymaker:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



function lua_ability_rogue_golem_haymaker:OnSpellStart()

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return true end

    self:GetCaster():EmitSoundParams("Ability.TossImpact",1,3,0)
    self:GetCaster():EmitSound("Hero_Tiny.Attack.Impact")


    local direction = self:GetCursorTarget():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
    direction = direction:Normalized()
    direction.z = 0
    direction = direction*150

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf",
        PATTACH_POINT,self:GetCaster()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetCursorTarget():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle,1,self:GetCursorTarget():GetAbsOrigin()+direction)

    self:GetCursorTarget():InterruptMotionControllers(true)

    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),self,
        "modifier_stunned",
        {duration = self:GetSpecialValueFor("stun_duration")}
    )

    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_rogue_golem_haymaker_slow",
        {duration = self:GetSpecialValueFor("tapering_slow_duration")}
    )

    local str_value = 0

    if self:GetCursorTarget():IsHero() then

        local percent = self:GetSpecialValueFor("str_gain_percent")*0.01
        str_value = math.ceil(self:GetCursorTarget():GetStrength()*percent)

        local str_time = self:GetSpecialValueFor("str_gain_duration")
        if self:GetCaster():HasScepter() then
            str_time = self:GetSpecialValueFor("scepter_str_duration")
        end

        self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_rogue_golem_haymaker_buff",
            {
                duration = str_time,
                str_gain = str_value
            }
        )
    end

    local mult_dmg = self:GetSpecialValueFor("punch_damage_multiplier")
    local str_dmg = str_value*mult_dmg
    local base_dmg = self:GetSpecialValueFor("punch_damage")
    local total_dmg = base_dmg+str_dmg

    local dtable = {
        victim = self:GetCursorTarget(),
        attacker = self:GetCaster(),
        damage = total_dmg,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self
    }
    ApplyDamage(dtable)




end
