LinkLuaModifier( "lua_modifier_great_sage_somersault_cloud", "heroes/great_sage/ability_4/lua_modifier_great_sage_somersault_cloud", LUA_MODIFIER_MOTION_NONE)

lua_ability_great_sage_somersault_cloud = class({})


function lua_ability_great_sage_somersault_cloud:OnUpgrade()

    if self:GetCaster():IsAlive() == false then return end

    if not self.modifier then
        self.modifier = self:GetCaster():AddNewModifier(
            self:GetCaster(),self,"lua_modifier_great_sage_somersault_cloud",
            {}
        )
    end

end





function lua_ability_great_sage_somersault_cloud:GetCooldown(lvl)
    return self:GetLevelSpecialValueFor("ability_cd",0)
end






function lua_ability_great_sage_somersault_cloud:OnOwnerSpawned()

    if not self.modifier then
        self.modifier = self:GetCaster():AddNewModifier(
            self:GetCaster(),self,"lua_modifier_great_sage_somersault_cloud",
            {}
        )
    end
end




function lua_ability_great_sage_somersault_cloud:OnOwnerDied()
    if not self.modifier == false then
        self.modifier:Destroy()
        self.modifier = nil
        self:EndCooldown()
    end
end
