LinkLuaModifier( "lua_modifier_vagabond_phantom_charge", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_phantom_charge_invi", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_phantom_charge_invi_frame", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )


lua_ability_vagabond_phantom_charge = class({})






function lua_ability_vagabond_phantom_charge:GetCastRange(location,target)

    local self_ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge")
    local range = 0

    if not self_ability then return 0 end

    range = self_ability:GetSpecialValueFor("cast_range")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_charge_range")
    local add_range = 0

    if not talent == false then
        if talent:GetLevel() > 0 then
            add_range = talent:GetSpecialValueFor("value")
        end
    end

    return range + add_range
end





function lua_ability_vagabond_phantom_charge:GetCooldown(lvl)

    local self_ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge")
    local cd = 0

    if not self_ability then return 0 end

    cd = self_ability:GetSpecialValueFor("cast_cd")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_charge_cd_reduction")
    local add_cd = 0

    if not talent == false then
        if talent:GetLevel() > 0 then
            add_cd = talent:GetSpecialValueFor("value")
        end
    end

    return cd - add_cd
end






function lua_ability_vagabond_phantom_charge:OnUpgrade()
    local illu_strike = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge_fragment")
    if not illu_strike then return end

    illu_strike:SetLevel(self:GetLevel())

end



function lua_ability_vagabond_phantom_charge:OnSpellStart()

    local illu_strike = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge_fragment")
    if not illu_strike then return end


    local shard_mod = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if shard_mod == false then
        illu_strike:StartCooldown(self:GetCooldownTime())
    end

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_vagabond_phantom_charge_invi_frame",
        {duration = FrameTime()}
    )


    self.modifier = self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_vagabond_phantom_charge",
        {}
    )

    --self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_SPAWN,5)


    self:GetCaster():MoveToTargetToAttack(self:GetCursorTarget())
end





function lua_ability_vagabond_phantom_charge:GetAssociatedSecondaryAbilities()
    return "lua_ability_vagabond_phantom_charge_fragment"
end








------------------------------------------------------------
--Illu strike
-----------------------------------------------------------


lua_ability_vagabond_phantom_charge_fragment = class({})




function lua_ability_vagabond_phantom_charge_fragment:GetCastRange(location,target)

    local self_ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge")
    local range = 0

    if not self_ability then return 0 end

    range = self_ability:GetSpecialValueFor("cast_range")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_charge_range")
    local add_range = 0

    if not talent == false then
        if talent:GetLevel() > 0 then
            add_range = talent:GetSpecialValueFor("value")
        end
    end

    return range + add_range
end





function lua_ability_vagabond_phantom_charge_fragment:GetCooldown(lvl)

    local self_ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge")
    local cd = 0

    if not self_ability then return 0 end

    cd = self_ability:GetSpecialValueFor("cast_cd")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_charge_cd_reduction")
    local add_cd = 0

    if not talent == false then
        if talent:GetLevel() > 0 then
            add_cd = talent:GetSpecialValueFor("value")
        end
    end

    return cd - add_cd
end






function lua_ability_vagabond_phantom_charge_fragment:OnSpellStart()

    local real_strike = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge")
    if not real_strike then return end


    local shard_mod = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if shard_mod == false then
        real_strike:StartCooldown(self:GetCooldownTime())
    end


    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_vagabond_phantom_charge_invi",
        {duration = real_strike:GetSpecialValueFor("charge_duration")}
    )

    self.illusion = CreateIllusions(
        self:GetCaster(),
        self:GetCaster(),
        {
            outgoing_damage = 0,
            incoming_damage = 0,
            bounty_base = 0,
            bounty_growth = 0.0,
            outgoing_damage_structure = 0,
            outgoing_damage_roshan = 0
        },
        1,
        self:GetCaster():GetHullRadius(),
        false,
        true
    )

    self.illusion[1]:AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_vagabond_phantom_charge_invi_frame",
        {duration = FrameTime()}
    )

    --self.illusion[1]:StartGestureWithPlaybackRate(ACT_DOTA_SPAWN,5)

    self.modifier = self.illusion[1]:AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_vagabond_phantom_charge",
        {}
    )

    self.illusion[1]:MoveToTargetToAttack(self:GetCursorTarget())
end




function lua_ability_vagabond_phantom_charge_fragment:GetAssociatedPrimaryAbilities()
    return "lua_ability_vagabond_phantom_charge"
end
