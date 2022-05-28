LinkLuaModifier( "lua_modifier_hidden_one_aether_warp_invulnerable", "heroes/hidden_one/ability_3/lua_modifier_hidden_one_aether_warp", LUA_MODIFIER_MOTION_NONE )


lua_ability_hidden_one_aether_warp = class({})


function lua_ability_hidden_one_aether_warp:GetAOERadius()
    local cast_aoe = self:GetLevelSpecialValueFor("cast_aoe",0)
    return cast_aoe
end


function lua_ability_hidden_one_aether_warp:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_hidden_one_aether_warp:GetCooldown(lvl)
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


function lua_ability_hidden_one_aether_warp:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",0)
    return mana_cost
end


function lua_ability_hidden_one_aether_warp:OnSpellStart()



    local ult = self:GetCaster():FindAbilityByName("lua_ability_hidden_one_void_out")
    local aoe_damage = self:GetSpecialValueFor("aoe_damage")

    --aoe damage
    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),nil,
        self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
    )

    for i=1,#enemies do

        if not ult == false then
            if ult:GetLevel() > 0 then
                ult:ApplyVoidOutModifier(enemies[i],self)
            end
        end

        local dtable = {
            victim = enemies[i],
            attacker = self:GetCaster(),
            damage = aoe_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self
        }

        ApplyDamage(dtable)

    end

    --particle
    local particle =  ParticleManager:CreateParticle(
        "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf",
        PATTACH_ABSORIGIN,self:GetCaster()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle,1,Vector(self:GetAOERadius()-100,0,0))


    --invulnerable
    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_hidden_one_aether_warp_invulnerable",
        {
            duration = self:GetSpecialValueFor("invulnerable_time")+3.0,
            tele_x = self:GetCursorPosition().x,
            tele_y = self:GetCursorPosition().y,
            tele_z = self:GetCursorPosition().z,
            delay_damage = aoe_damage
        }
    )




end
