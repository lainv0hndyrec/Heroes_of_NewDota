LinkLuaModifier( "lua_modifier_great_sage_flurry_strikes_zoomies", "heroes/great_sage/ability_1/lua_modifier_great_sage_flurry_strikes", LUA_MODIFIER_MOTION_HORIZONTAL)


lua_ability_great_sage_flurry_strikes = class({})




function lua_ability_great_sage_flurry_strikes:OnSpellStart()
    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_flurry_strikes_timer")


    if free_mod == false then

        local dash = self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_great_sage_flurry_strikes_zoomies",
            {duration = 1.0}
        )

        dash:SetStackCount(1)
        return
    end


    if free_mod == true then

        local dash = self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_great_sage_flurry_strikes_zoomies",
            {duration = 1.0}
        )

        dash:SetStackCount(0)

        local timer_mod = self:GetCaster():FindModifierByName("lua_modifier_great_sage_flurry_strikes_timer")
        if not timer_mod then return end
        timer_mod:Destroy()
    end


end



function lua_ability_great_sage_flurry_strikes:GetCooldown(lvl)
    local cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return cd
end


function lua_ability_great_sage_flurry_strikes:GetManaCost(lvl)
    local mana = self:GetLevelSpecialValueFor("ability_mana",lvl)
    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_flurry_strikes_timer")
    if free_mod == true then
        mana = 0.0
    end

    return mana
end



function lua_ability_great_sage_flurry_strikes:GetAbilityTextureName()
    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_flurry_strikes_timer")
    if free_mod == true then
        return "great_sage_flurry_free_cast"
    end
    return "monkey_king_wukongs_command"
end
