LinkLuaModifier( "lua_modifier_boogeyman_depravity_aura", "heroes/boogeyman/ability_3/lua_modifier_boogeyman_depravity", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_boogeyman_fright_night", "heroes/boogeyman/ability_3/lua_modifier_boogeyman_depravity", LUA_MODIFIER_MOTION_NONE )


lua_ability_boogeyman_depravity = class({})



function lua_ability_boogeyman_depravity:GetAOERadius()
    local aura_range = self:GetLevelSpecialValueFor("aura_range",0)
    return aura_range
end


function lua_ability_boogeyman_depravity:GetCastRange(pos,target)
    return self:GetAOERadius()
end




function lua_ability_boogeyman_depravity:GetIntrinsicModifierName()
    if self:GetLevel() <= 0 then return end
	return "lua_modifier_boogeyman_depravity_aura"
end


function lua_ability_boogeyman_depravity:OnToggle()
    print("welp")
end


function lua_ability_boogeyman_depravity:IsStealable()
    return false
end












-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
lua_ability_boogeyman_fright_night = class({})





function lua_ability_boogeyman_fright_night:OnInventoryContentsChanged()
    if not IsServer() then return end

    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") == false then return end

    if self:IsHidden() == false then return end

    self:SetHidden(false)
    self:SetLevel(1)

    if self:GetCaster():HasModifier("lua_modifier_boogeyman_fright_night") then return end

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_boogeyman_fright_night",
        {}
    )


end



function lua_ability_boogeyman_fright_night:IsStealable()
    return false
end
