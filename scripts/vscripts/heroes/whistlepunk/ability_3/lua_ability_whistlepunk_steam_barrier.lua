LinkLuaModifier( "lua_modifier_whistlepunk_steam_barrier", "heroes/whistlepunk/ability_3/lua_modifier_whistlepunk_steam_barrier", LUA_MODIFIER_MOTION_NONE )


lua_ability_whistlepunk_steam_barrier = class({})


function lua_ability_whistlepunk_steam_barrier:OnSpellStart()
    
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    self.barrier_duration = self:GetSpecialValueFor("barrier_duration")

    self.barrier = self.target:AddNewModifier(
        self.caster,
        self,
        "lua_modifier_whistlepunk_steam_barrier",
        {duration = self.barrier_duration}
    )

end
