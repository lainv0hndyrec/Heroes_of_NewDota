LinkLuaModifier( "lua_modifier_whistlepunk_sawprise_thinker", "heroes/whistlepunk/ability_4/lua_modifier_whistlepunk_sawprise", LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "lua_modifier_whistlepunk_sawprise_vt", "heroes/whistlepunk/ability_4/lua_modifier_whistlepunk_sawprise", LUA_MODIFIER_MOTION_NONE )


lua_ability_whistlepunk_sawprise = class({})




function lua_ability_whistlepunk_sawprise:OnUpgrade()

    self.caster = self:GetCaster()
    self.cast_position = Vector(0,0,0)
    self.vector_position = Vector(0,0,0)
    self.vector_direction = Vector(0,0,0)

end




function lua_ability_whistlepunk_sawprise:CastFilterResultLocation(pos)
    if not IsServer() then return end
    self.vector_position = self.cast_position
    self.cast_position = pos
    return UF_SUCCESS
end




function lua_ability_whistlepunk_sawprise:OnAbilityPhaseStart()
    if not IsServer() then return end

    self.vector_direction = (self.vector_position - self.cast_position):Normalized()
    self.vector_direction.z = 0

    if self.vector_direction:Length2D() == 0 then
        return false
    end

    return true
end




function lua_ability_whistlepunk_sawprise:OnSpellStart()
    if not IsServer() then return end

    self.thinker = CreateModifierThinker(
        self.caster,
        self,
        "lua_modifier_whistlepunk_sawprise_thinker",
        {
            cp_x = self.cast_position.x,
            cp_y = self.cast_position.y,
            cp_z = self.cast_position.z,
            vd_x = self.vector_direction.x,
            vd_y = self.vector_direction.y,
            saw_duration = self:GetSpecialValueFor("saw_duration"),
            init_damage = self:GetSpecialValueFor("init_damage"),
            saw_dot = self:GetSpecialValueFor("saw_dot"),
            saw_aoe = self:GetSpecialValueFor("saw_aoe"),
            tick_interval = self:GetSpecialValueFor("tick_interval")
        },
        self.cast_position,
        self.caster:GetTeamNumber(),
        false
    )

    self.cast_position = Vector(0,0,0)
    self.vector_position = Vector(0,0,0)
    self.vector_direction = Vector(0,0,0)


end
