LinkLuaModifier( "lua_modifier_great_sage_flurry_strike_dash", "heroes/great_sage/ability_1/lua_modifier_great_sage_flurry_strike", LUA_MODIFIER_MOTION_HORIZONTAL)


lua_ability_great_sage_flurry_strike = class({})




function lua_ability_great_sage_flurry_strike:OnSpellStart()
    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_flurry_strike_timer")





    if free_mod == false then

        self:GetCaster():AddNewModifier(
            self:GetCaster(),
            self,
            "lua_modifier_great_sage_flurry_strike_dash",
            {
                duration = self:GetSpecialValueFor("flurry_duration"),
                additional_dash = 1
            }
        )

        -- self:EndCooldown()
        -- self:StartCooldown(0.2)
        return
    end


    if free_mod == true then

        self:GetCaster():AddNewModifier(
            self:GetCaster(),
            self,
            "lua_modifier_great_sage_flurry_strike_dash",
            {
                duration = self:GetSpecialValueFor("flurry_duration"),
                additional_dash = 0
            }
        )

        local timer_mod = self:GetCaster():FindModifierByName("lua_modifier_great_sage_flurry_strike_timer")

        if not timer_mod then return end

        timer_mod:Destroy()
    end


end



function lua_ability_great_sage_flurry_strike:GetCooldown(lvl)
    local cd = self:GetLevelSpecialValueFor("ability_cd",lvl)

    return cd
end


function lua_ability_great_sage_flurry_strike:GetManaCost(lvl)
    local mana = self:GetLevelSpecialValueFor("ability_mana",lvl)
    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_flurry_strike_timer")
    if free_mod == true then
        mana = 0.0
    end

    return mana
end





function lua_ability_great_sage_flurry_strike:GetAbilityTextureName()
    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_flurry_strike_timer")
    if free_mod == true then
        return "great_sage_flurry_free_cast"
    end
    return "monkey_king_wukongs_command"
end
