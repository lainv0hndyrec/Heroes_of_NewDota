LinkLuaModifier( "lua_modifier_fallen_one_soul_tap_slow", "heroes/fallen_one/ability_2/lua_modifier_fallen_one_soul_tap", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_fallen_one_soul_tap_buff", "heroes/fallen_one/ability_2/lua_modifier_fallen_one_soul_tap", LUA_MODIFIER_MOTION_NONE )


lua_ability_fallen_one_soul_tap = class({})



function lua_ability_fallen_one_soul_tap:GetAOERadius()
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end



function lua_ability_fallen_one_soul_tap:GetCastRange(pos,target)
    return self:GetAOERadius()
end


function lua_ability_fallen_one_soul_tap:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_fallen_one_soul_tap:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end





function lua_ability_fallen_one_soul_tap:OnSpellStart()

    self:GetCaster():EmitSound("Hero_DoomBringer.InfernalBlade.PreAttack")

    local shock = ParticleManager:CreateParticle(
        "particles/econ/items/centaur/centaur_ti6/centaur_ti6_warstomp.vpcf",
        PATTACH_ABSORIGIN,self:GetCaster()
    )

    ParticleManager:SetParticleControl(shock,0,self:GetAbsOrigin())
    ParticleManager:SetParticleControl(shock,1,Vector(self:GetAOERadius(),0,0))

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),
        nil,self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,false
    )

    for i=1, #enemies do
        enemies[i]:AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_fallen_one_soul_tap_slow",
            {duration = self:GetSpecialValueFor("aoe_slow_time")}
        )
    end

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_fallen_one_soul_tap_buff",
        {duration = self:GetSpecialValueFor("buff_time")}
    )

end
