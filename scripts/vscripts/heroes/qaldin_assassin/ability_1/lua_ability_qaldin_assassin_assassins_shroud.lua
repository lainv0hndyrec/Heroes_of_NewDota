LinkLuaModifier( "lua_modifier_qaldin_assassin_assassins_shroud", "heroes/qaldin_assassin/ability_1/lua_modifier_qaldin_assassin_assassins_shroud", LUA_MODIFIER_MOTION_NONE )


lua_ability_qaldin_assassin_assassins_shroud = class({})



function lua_ability_qaldin_assassin_assassins_shroud:GetAbilityTextureName()
    if not IsClient() then return end

    if self:GetToggleState() == true then
        return "qaldin_assassin_assassins_shroud"
    end
    
    return "bounty_hunter_wind_walk"
end






function lua_ability_qaldin_assassin_assassins_shroud:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end



function lua_ability_qaldin_assassin_assassins_shroud:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



function lua_ability_qaldin_assassin_assassins_shroud:OnToggle()
    local is_on = self:GetToggleState()

    if is_on == true then

        self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_qaldin_assassin_assassins_shroud",{}
        )

        self:GetCaster():Interrupt()
        self:EndCooldown()

    else

        local mod = self:GetCaster():FindModifierByName("lua_modifier_qaldin_assassin_assassins_shroud")
        if not mod == false then
            mod:Destroy()
        end

    end

end
