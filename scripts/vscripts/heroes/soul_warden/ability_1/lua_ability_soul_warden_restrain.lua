LinkLuaModifier( "lua_modifier_soul_warden_restrain", "heroes/soul_warden/ability_1/lua_modifier_soul_warden_restrain", LUA_MODIFIER_MOTION_NONE )


lua_ability_soul_warden_restrain = class({})


function lua_ability_soul_warden_restrain:OnSpellStart()

    self:GetCaster():EmitSound("Ability.static.start")

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_soul_warden_restrain",
        {duration = self:GetSpecialValueFor("hold_time")}
    )

end



function lua_ability_soul_warden_restrain:GetCastRange(ps,target)
    local range = self:GetSpecialValueFor("cast_range")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_soul_warden_restrain_add_range")
    if not talent == false then
        if talent:GetLevel() > 0 then
            range = range+talent:GetSpecialValueFor("value")
        end
    end
    return range
end
