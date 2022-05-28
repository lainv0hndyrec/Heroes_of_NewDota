LinkLuaModifier( "lua_modifier_hidden_one_shade_salvo_thinker", "heroes/hidden_one/ability_1/lua_modifier_hidden_one_shade_salvo", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_hidden_one_shade_salvo_damage", "heroes/hidden_one/ability_1/lua_modifier_hidden_one_shade_salvo", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_hidden_one_shade_salvo_slow", "heroes/hidden_one/ability_1/lua_modifier_hidden_one_shade_salvo", LUA_MODIFIER_MOTION_NONE )



lua_ability_hidden_one_shade_salvo = class({})


function lua_ability_hidden_one_shade_salvo:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end



function lua_ability_hidden_one_shade_salvo:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",0)

    local ult = self:GetCaster():FindAbilityByName("lua_ability_hidden_one_void_out")
    if not ult == false then
        if ult:GetLevel() > 0 then
            local cdr_abilities = ult:GetLevelSpecialValueFor("cdr_abilities",ult:GetLevel()-1)
            ability_cd = ability_cd - cdr_abilities
        end
    end

    return ability_cd
end



function lua_ability_hidden_one_shade_salvo:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



function lua_ability_hidden_one_shade_salvo:OnSpellStart()

    self:GetCaster():EmitSound("Hero_VoidSpirit.AetherRemnant.Cast")

    local diff = self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()
    local normal = diff:Normalized()
    local spacing = self:GetSpecialValueFor("salvo_spacing")

    for i=1, 5 do

        local new_pos = self:GetCaster():GetAbsOrigin() + (normal*i*spacing)

        local thinker_mod = CreateModifierThinker(
            self:GetCaster(),self,
            "lua_modifier_hidden_one_shade_salvo_thinker",
            {duration = 4.0},new_pos,
            self:GetCaster():GetTeam(),false
        )

        local ptable = {
            vSourceLoc = self:GetCaster():GetAbsOrigin(),
            Target = thinker_mod,
            iMoveSpeed = 900,
            flExpireTime = GameRules:GetGameTime() + 3.0,
            bDodgeable = false,
            bReplaceExisting = false,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
            EffectName = "particles/units/heroes/hidden_one/hidden_one_salvo.vpcf",
            Ability = self,
            Source = self:GetCaster()
        }
        ProjectileManager:CreateTrackingProjectile(ptable)

    end

end




function lua_ability_hidden_one_shade_salvo:OnProjectileHit(target,pos)

    self:GetCaster():EmitSound("Hero_VoidSpirit.Pulse.Destroy")

    local ground = GetGroundPosition(pos,self:GetCaster())
    local particle = ParticleManager:CreateParticle(
        "particles/econ/taunts/void_spirit/void_spirit_taunt_impact_shockwave.vpcf",
        PATTACH_ABSORIGIN,self:GetCaster()
    )
    ParticleManager:SetParticleControl(particle,0,ground)

    local particle_radius = ParticleManager:CreateParticle(
        "particles/units/heroes/hidden_one/hidden_one_salvo_aoe.vpcf",
        PATTACH_ABSORIGIN,self:GetCaster()
    )
    ParticleManager:SetParticleControl(particle_radius,6,ground)


    local ult = self:GetCaster():FindAbilityByName("lua_ability_hidden_one_void_out")
    local salvo_aoe = self:GetSpecialValueFor("salvo_aoe")
    local slow_time = self:GetSpecialValueFor("slow_time")


    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),pos,nil,
        salvo_aoe,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
    )

    for i=1, #enemies do
        --apply ult
        if not ult == false then
            if ult:GetLevel() > 0 then
                ult:ApplyVoidOutModifier(enemies[i],self)
            end
        end

        --slow
        enemies[i]:AddNewModifier(
            self:GetCaster(),self ,
            "lua_modifier_hidden_one_shade_salvo_slow",
            {duration = slow_time}
        )

        --damage
        enemies[i]:AddNewModifier(
            self:GetCaster(),self ,
            "lua_modifier_hidden_one_shade_salvo_damage",
            {duration = slow_time}
        )
    end

    return true
end
