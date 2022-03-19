LinkLuaModifier( "lua_modifier_kalligromancer_stroked_inspiration", "heroes/kalligromancer/ability_2/lua_modifier_kalligromancer_stroked_inspiration", LUA_MODIFIER_MOTION_NONE )


lua_ability_kalligromancer_stroked_inspiration = class({})




function lua_ability_kalligromancer_stroked_inspiration:GetCooldown(lvl)

    local self_ability = self:GetCaster():FindAbilityByName("lua_ability_kalligromancer_stroked_inspiration")
    local cd = 0

    if not self_ability then return 0 end

    cd = self_ability:GetSpecialValueFor("cast_cd")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_kalligromancer_stroked_inspiration_minus_cd")
    local add_cd = 0

    if not talent == false then
        if talent:GetLevel() > 0 then
            add_cd = talent:GetSpecialValueFor("value")
        end
    end

    return cd - add_cd
end





function lua_ability_kalligromancer_stroked_inspiration:GetAOERadius()
    self.scan_range = self:GetSpecialValueFor("scan_range")
    return self.scan_range
end





function lua_ability_kalligromancer_stroked_inspiration:OnSpellStart()

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end


    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_kalligromancer_stroked_inspiration",
        {duration = self:GetSpecialValueFor("crazy_time")}
    )

    self:GetCursorTarget():EmitSound("Hero_Grimstroke.InkCreature.Spawn")
end
