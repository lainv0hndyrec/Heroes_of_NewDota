LinkLuaModifier( "lua_modifier_hidden_one_aether_warp_invulnerable", "heroes/hidden_one/ability_3/lua_modifier_hidden_one_aether_warp", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_hidden_one_aether_warp_start", "heroes/hidden_one/ability_3/lua_modifier_hidden_one_aether_warp", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_hidden_one_aether_warp_end", "heroes/hidden_one/ability_3/lua_modifier_hidden_one_aether_warp", LUA_MODIFIER_MOTION_NONE )


lua_ability_hidden_one_aether_warp = class({})


function lua_ability_hidden_one_aether_warp:GetAOERadius()
    local cast_aoe = self:GetLevelSpecialValueFor("cast_aoe",0)
    return cast_aoe
end



function lua_ability_hidden_one_aether_warp:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    if self:GetCaster():HasScepter() then
        cast_range = cast_range + self:GetLevelSpecialValueFor("scepter_range",0)
    end
    return cast_range
end



function lua_ability_hidden_one_aether_warp:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",0)

    local ult = self:GetCaster():FindAbilityByName("lua_ability_hidden_one_void_out")
    if not ult == false then
        if ult:GetLevel() > 0 then
            local cdr_abilities = ult:DecreaseCoolDown(ult:GetLevel())
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

    ProjectileManager:ProjectileDodge(self:GetCaster())

    local invulnerable_time = self:GetSpecialValueFor("invulnerable_time")

    --invulnerable
    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_hidden_one_aether_warp_invulnerable",
        {
            duration = invulnerable_time,
            tele_x = self:GetCursorPosition().x,
            tele_y = self:GetCursorPosition().y,
            tele_z = self:GetCursorPosition().z
        }
    )


    --Start
    CreateModifierThinker(
        self:GetCaster(),self,
        "lua_modifier_hidden_one_aether_warp_start",
        {duration = 3.0},
        self:GetCaster():GetAbsOrigin(),
        self:GetCaster():GetTeam(),false
    )

    --End
    CreateModifierThinker(
        self:GetCaster(),self,
        "lua_modifier_hidden_one_aether_warp_end",
        {duration = 3.0},
        self:GetCursorPosition(),
        self:GetCaster():GetTeam(),false
    )

end
