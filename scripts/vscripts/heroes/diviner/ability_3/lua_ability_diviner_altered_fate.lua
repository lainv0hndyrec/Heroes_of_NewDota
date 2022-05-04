LinkLuaModifier( "lua_modifier_diviner_altered_fate_passive", "heroes/diviner/ability_3/lua_modifier_diviner_altered_fate", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_diviner_altered_fate_hp_regen", "heroes/diviner/ability_3/lua_modifier_diviner_altered_fate", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_diviner_altered_fate_mp_regen", "heroes/diviner/ability_3/lua_modifier_diviner_altered_fate", LUA_MODIFIER_MOTION_NONE )




lua_ability_diviner_altered_fate = class({})


function lua_ability_diviner_altered_fate:GetBehavior()
    local behaviour = DOTA_ABILITY_BEHAVIOR_NO_TARGET
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        behaviour = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_CAN_SELF_CAST
    end

    return behaviour
end




function lua_ability_diviner_altered_fate:GetCastRange(location,target)
    local cast_range = 0
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        cast_range = self:GetSpecialValueFor("shard_cast_range")
    end

    return cast_range
end



function lua_ability_diviner_altered_fate:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_diviner_altered_fate_cd_down")
    if not talent == false then
        if talent:GetLevel() > 0 then
            ability_cd = ability_cd - talent:GetSpecialValueFor("value")
        end
    end

    return ability_cd
end



function lua_ability_diviner_altered_fate:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCaster()
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        target = self:GetCursorTarget()
    end

    --target:EmitSound("Hero_Oracle.PurifyingFlames.Damage")


    if target:GetManaPercent() >= target:GetHealthPercent() then
        target:AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_diviner_altered_fate_hp_regen",
            {duration = self:GetSpecialValueFor("swap_fill_duration")}
        )
    else
        target:AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_diviner_altered_fate_mp_regen",
            {duration = self:GetSpecialValueFor("swap_fill_duration")}
        )
    end
end



function lua_ability_diviner_altered_fate:GetIntrinsicModifierName()
    if self:GetLevel() <= 0 then return end
	return "lua_modifier_diviner_altered_fate_passive"
end



function lua_ability_diviner_altered_fate:OnUnStolen()
    local passive = self:GetCaster():FindModifierByName("lua_modifier_diviner_altered_fate_passive")
    if not passive then return end
    passive:Destroy()
end
