LinkLuaModifier( "lua_modifier_spiritsmaster_fire_spirit_dash", "heroes/spiritsmaster/ability_2/lua_modifier_spiritsmaster_fire_spirit", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "lua_modifier_spiritsmaster_fire_spirit_transform", "heroes/spiritsmaster/ability_2/lua_modifier_spiritsmaster_fire_spirit", LUA_MODIFIER_MOTION_NONE )


lua_ability_spiritsmaster_fire_spirit = class({})



function lua_ability_spiritsmaster_fire_spirit:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_spiritsmaster_fire_spirit:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_spiritsmaster_fire_spirit:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



function lua_ability_spiritsmaster_fire_spirit:OnSpellStart()

    self:GetCaster():EmitSound("Hero_Brewmaster.PrimalSplit.Cast")

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_spiritsmaster_fire_spirit_transform",
        {duration = self:GetSpecialValueFor("hero_effect_time")}
    )

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_spiritsmaster_fire_spirit_dash",
        {
            duration = self:GetSpecialValueFor("dmg_steal_time"),
            target = self:GetCursorTarget():GetEntityIndex()
        }
    )
end
