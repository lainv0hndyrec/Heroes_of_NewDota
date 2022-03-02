LinkLuaModifier( "lua_modifier_unfathomed_ethereal_order", "heroes/unfathomed/ability_3/lua_modifier_unfathomed_ethereal_order", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_unfathomed_ethereal_order_status_color", "heroes/unfathomed/ability_3/lua_modifier_unfathomed_ethereal_order", LUA_MODIFIER_MOTION_NONE )

lua_ability_unfathomed_ethereal_order = class({})



function lua_ability_unfathomed_ethereal_order:GetAbilityTextureName()
    local texture = "unfathomed_ethereal_order_pull"

    local caster = self:GetCaster()

    if not caster then return texture end

    local ability = caster:FindAbilityByName("lua_ability_unfathomed_ethereal_order")

    if not ability then return texture end

    if ability:GetToggleState() == true then
        texture = "unfathomed_ethereal_order_push"
    end

    return texture
end




function lua_ability_unfathomed_ethereal_order:OnUpgrade()
    --create modifier
    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_unfathomed_ethereal_order",
        {}
    )

end




function lua_ability_unfathomed_ethereal_order:OnToggle()

    if self:GetToggleState() == true  then
        self.color_status = self:GetCaster():AddNewModifier(
            self:GetCaster(),
            self,
            "lua_modifier_unfathomed_ethereal_order_status_color",
            {}
        )
    else
        if not self.color_status then return end

        self.color_status:Destroy()
        self.color_status = nil
    end

end



function lua_ability_unfathomed_ethereal_order:IsStealable()
    return false
end



function lua_ability_unfathomed_ethereal_order:ProcsMagicStick()
    return false
end
