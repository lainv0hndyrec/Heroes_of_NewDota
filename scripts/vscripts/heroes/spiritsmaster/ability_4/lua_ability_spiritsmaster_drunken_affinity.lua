LinkLuaModifier( "lua_modifier_spiritsmaster_drunken_affinity_str", "heroes/spiritsmaster/ability_4/lua_modifier_spiritsmaster_drunken_affinity", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "lua_modifier_spiritsmaster_drunken_affinity_agi", "heroes/spiritsmaster/ability_4/lua_modifier_spiritsmaster_drunken_affinity", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "lua_modifier_spiritsmaster_drunken_affinity_int", "heroes/spiritsmaster/ability_4/lua_modifier_spiritsmaster_drunken_affinity", LUA_MODIFIER_MOTION_NONE)

lua_ability_spiritsmaster_drunken_affinity = class({})


function lua_ability_spiritsmaster_drunken_affinity:GetAbilityTextureName()

    if self:GetCaster():HasModifier("lua_modifier_spiritsmaster_drunken_affinity_str") then
        return "spiritsmaster_drunken_affinity_str"
    end

    if self:GetCaster():HasModifier("lua_modifier_spiritsmaster_drunken_affinity_agi") then
        return "spiritsmaster_drunken_affinity_agi"
    end

    if self:GetCaster():HasModifier("lua_modifier_spiritsmaster_drunken_affinity_int") then
        return "spiritsmaster_drunken_affinity_int"
    end

    return "brewmaster_drunken_brawler"

end


function lua_ability_spiritsmaster_drunken_affinity:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_spiritsmaster_drunken_affinity:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        ability_cd = ability_cd - self:GetSpecialValueFor("shard_cd_reduce")
    end
    return ability_cd
end


function lua_ability_spiritsmaster_drunken_affinity:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



function lua_ability_spiritsmaster_drunken_affinity:OnSpellStart()

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    local str_mod = self:GetCaster():FindModifierByName("lua_modifier_spiritsmaster_drunken_affinity_str")
    local str_agi = self:GetCaster():FindModifierByName("lua_modifier_spiritsmaster_drunken_affinity_agi")
    local str_int = self:GetCaster():FindModifierByName("lua_modifier_spiritsmaster_drunken_affinity_int")


    if not str_mod == false then
        str_mod:Destroy()
    end

    if not str_agi == false then
        str_agi:Destroy()
    end

    if not str_int == false then
        str_int:Destroy()
    end


    if self:GetCursorTarget():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_spiritsmaster_drunken_affinity_str",
            {target = self:GetCursorTarget():GetEntityIndex()}
        )
        return
    end

    if self:GetCursorTarget():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
        self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_spiritsmaster_drunken_affinity_agi",
            {target = self:GetCursorTarget():GetEntityIndex()}
        )
        return
    end

    if self:GetCursorTarget():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_spiritsmaster_drunken_affinity_int",
            {target = self:GetCursorTarget():GetEntityIndex()}
        )
        return
    end

end
