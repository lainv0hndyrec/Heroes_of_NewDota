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
        self.toggle = true
        self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_fallen_one_sadism_aura",
            {}
        )

    else
        self.toggle = false
        local aura = self:GetCaster():FindModifierByName("lua_modifier_fallen_one_sadism_aura")
        if not aura == false then
            aura:Destroy()
        end

    end

end


function lua_ability_fallen_one_sadism:OnOwnerSpawned()
    self:ToggleAbility()
end
