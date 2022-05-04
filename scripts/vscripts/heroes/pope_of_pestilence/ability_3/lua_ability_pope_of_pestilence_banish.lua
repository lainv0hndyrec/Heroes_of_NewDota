LinkLuaModifier( "lua_modifier_pope_of_pestilence_banish_skull", "heroes/pope_of_pestilence/ability_3/lua_modifier_pope_of_pestilence_banish", LUA_MODIFIER_MOTION_NONE )



lua_ability_pope_of_pestilence_banish = class({})


function lua_ability_pope_of_pestilence_banish:OnUpgrade()
    if self:GetCaster():IsIllusion() then return end

    local mod = self:GetCaster():FindModifierByName("lua_modifier_pope_of_pestilence_banish_skull")

    if not mod then
        self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_pope_of_pestilence_banish_skull",
            {}
        )

        self:ToggleAbility()
    end
end



function lua_ability_pope_of_pestilence_banish:OnToggle()
end


function lua_ability_pope_of_pestilence_banish:ProcsMagicStick()
    return false
end


function lua_ability_pope_of_pestilence_banish:IsStealable()
    return false
end


function lua_ability_pope_of_pestilence_banish:OnOwnerSpawned()
    self:ToggleAbility()
end
