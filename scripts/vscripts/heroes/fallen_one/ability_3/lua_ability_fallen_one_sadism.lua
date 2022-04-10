LinkLuaModifier( "lua_modifier_fallen_one_sadism_aura", "heroes/fallen_one/ability_3/lua_modifier_fallen_one_sadism", LUA_MODIFIER_MOTION_NONE )


lua_ability_fallen_one_sadism = class({})



function lua_ability_fallen_one_sadism:GetAOERadius()
    local aura_range = self:GetLevelSpecialValueFor("aura_range",0)
    return aura_range
end



function lua_ability_fallen_one_sadism:GetCastRange(pos,target)
    return self:GetAOERadius()
end


function lua_ability_fallen_one_sadism:OnUpgrade()
    if self:GetLevel() == 1 then
        self:ToggleAbility()
    end
end


function lua_ability_fallen_one_sadism:OnToggle()

    if self:GetToggleState() == true then

        print(true)


    else
        print(false)
    end

end
