LinkLuaModifier( "lua_modifier_vagabond_phantom_charge_invi", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_phantom_charge_movement", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_phantom_charge_particle", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )


lua_ability_vagabond_phantom_charge = class({})

function lua_ability_vagabond_phantom_charge:OnUpgrade()
    local illu_ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge_fragment")
    if not illu_ability == false then
        illu_ability:SetLevel(self:GetLevel())
    end
end


function lua_ability_vagabond_phantom_charge:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_charge_range")
    if not talent == false then
        if talent:GetLevel() > 0 then
            cast_range = cast_range+talent:GetSpecialValueFor("value")
        end
    end

    return cast_range
end


function lua_ability_vagabond_phantom_charge:GetCooldown(lvl)
    local cast_cd = self:GetLevelSpecialValueFor("cast_cd",lvl)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_charge_cd_reduction")
    if not talent == false then
        if talent:GetLevel() > 0 then
            cast_cd = cast_cd-talent:GetSpecialValueFor("value")
        end
    end

    return cast_cd
end


function lua_ability_vagabond_phantom_charge:GetManaCost(lvl)
    local cast_mana = self:GetLevelSpecialValueFor("cast_mana",lvl)
    return cast_mana
end


function lua_ability_vagabond_phantom_charge:OnSpellStart()

    local illu_ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge_fragment")
    local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if not illu_ability == false then
        if shard == false then
            illu_ability:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()-1))
        end
    end


    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    --particle
    CreateModifierThinker(
        self:GetCaster(),self,"lua_modifier_vagabond_phantom_charge_particle",
        {duration = 2.0},self:GetCaster():GetAbsOrigin(),self:GetCaster():GetTeam(),false
    )

    --invi fake out
    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,"lua_modifier_vagabond_phantom_charge_invi",
        {duration = 0.1}
    )

    --charge
    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,"lua_modifier_vagabond_phantom_charge_movement",
        {
            duration = self:GetSpecialValueFor("charge_duration"),
            target = self:GetCursorTarget():GetEntityIndex()
        }
    )


end


function lua_ability_vagabond_phantom_charge:GetAssociatedSecondaryAbilities()
    return "lua_ability_vagabond_phantom_charge_fragment"
end















-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
lua_ability_vagabond_phantom_charge_fragment = class({})



function lua_ability_vagabond_phantom_charge_fragment:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_charge_range")
    if not talent == false then
        if talent:GetLevel() > 0 then
            cast_range = cast_range+talent:GetSpecialValueFor("value")
        end
    end

    return cast_range
end


function lua_ability_vagabond_phantom_charge_fragment:GetCooldown(lvl)
    local cast_cd = self:GetLevelSpecialValueFor("cast_cd",lvl)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_charge_cd_reduction")
    if not talent == false then
        if talent:GetLevel() > 0 then
            cast_cd = cast_cd-talent:GetSpecialValueFor("value")
        end
    end

    return cast_cd
end


function lua_ability_vagabond_phantom_charge_fragment:GetManaCost(lvl)
    local cast_mana = self:GetLevelSpecialValueFor("cast_mana",lvl)
    return cast_mana
end



function lua_ability_vagabond_phantom_charge_fragment:OnSpellStart()

    local main_ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge")
    local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if not main_ability == false then
        if shard == false then
            main_ability:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()-1))
        end
    end

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    --particle
    CreateModifierThinker(
        self:GetCaster(),self,"lua_modifier_vagabond_phantom_charge_particle",
        {duration = 2.0},self:GetCaster():GetAbsOrigin(),self:GetCaster():GetTeam(),false
    )

    
    --create illu
    local illu = CreateIllusions(
        self:GetCaster(),self:GetCaster(),
        {
            outgoing_damage = 0,
            incoming_damage = 0,
            bounty_base = 0,
            bounty_growth = 0,
            outgoing_damage_structure =  -100.0,
            outgoing_damage_roshan =  -100.0
        },
        1,self:GetCaster():GetHullRadius(),
        false,false
    )

    --invi owner
    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,"lua_modifier_vagabond_phantom_charge_invi",
        {duration = self:GetSpecialValueFor("charge_duration")}
    )

    --invi fake out
    illu[1]:AddNewModifier(
        self:GetCaster(),self,"lua_modifier_vagabond_phantom_charge_invi",
        {duration = 0.1}
    )

    --illu charge
    illu[1]:AddNewModifier(
        self:GetCaster(),self,"lua_modifier_vagabond_phantom_charge_movement",
        {
            duration = self:GetSpecialValueFor("charge_duration"),
            target = self:GetCursorTarget():GetEntityIndex()
        }
    )



end


function lua_ability_vagabond_phantom_charge_fragment:GetAssociatedPrimaryAbilities()
    return "lua_ability_vagabond_phantom_charge"
end
