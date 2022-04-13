
LinkLuaModifier( "lua_modifier_fallen_one_eternal_suffering", "heroes/fallen_one/ability_4/lua_modifier_fallen_one_eternal_suffering", LUA_MODIFIER_MOTION_NONE )

lua_ability_fallen_one_eternal_suffering = class({})



function lua_ability_fallen_one_eternal_suffering:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_fallen_one_eternal_suffering:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_fallen_one_eternal_suffering:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



function lua_ability_fallen_one_eternal_suffering:OnSpellStart()

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end


    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_fallen_one_eternal_suffering",
        {duration = self:GetSpecialValueFor("dot_time")}
    )

end
