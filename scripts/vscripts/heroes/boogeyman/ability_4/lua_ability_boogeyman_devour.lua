LinkLuaModifier( "lua_modifier_boogeyman_devour_stacks", "heroes/boogeyman/ability_4/lua_modifier_boogeyman_devour", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "lua_modifier_boogeyman_devour_debuff", "heroes/boogeyman/ability_4/lua_modifier_boogeyman_devour", LUA_MODIFIER_MOTION_HORIZONTAL )


lua_ability_boogeyman_devour = class({})







function lua_ability_boogeyman_devour:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_boogeyman_devour:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_boogeyman_devour:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_boogeyman_devour:OnUpgrade()

    if self:GetCaster():GetName() ~= "npc_dota_hero_night_stalker" then return end

    local devstack = self:GetCaster():FindModifierByName("lua_modifier_boogeyman_devour_stacks")

    if not devstack then
        self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_boogeyman_devour_stacks",
            {}
        )

        self:GetCaster():NotifyWearablesOfModelChange(false)
    end
end






function lua_ability_boogeyman_devour:OnSpellStart()


    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    self:GetCaster():EmitSound("Hero_Nightstalker.Trickling_Fear")

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_night_stalker/nightstalker_shard_hunter.vpcf",
        PATTACH_POINT_FOLLOW,self:GetCaster()
    )
    ParticleManager:SetParticleControlEnt(
        particle,0,self:GetCursorTarget(),
        PATTACH_POINT_FOLLOW,"attach_hitloc",
        Vector(0,0,0),false
    )
    ParticleManager:SetParticleControlEnt(
        particle,1,self:GetCaster(),
        PATTACH_POINT_FOLLOW,"attach_hitloc",
        Vector(0,0,0),false
    )

    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)



    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_boogeyman_devour_debuff",
        {duration = self:GetSpecialValueFor("debuff_kill_time")}
    )

    local base_dmg = self:GetSpecialValueFor("ability_damage")
    local stack_dmg = self:GetSpecialValueFor("devour_stack_damage")

    local d_stacks = self:GetCaster():FindModifierByName("lua_modifier_boogeyman_devour_stacks")
    if not d_stacks == false then
        base_dmg = base_dmg + (stack_dmg*d_stacks:GetStackCount())
    end

    if self:GetCursorTarget():IsCreep() then
        if self:GetCursorTarget():GetName() ~= "npc_dota_roshan" then
            self:GetCursorTarget():Kill(nil,self:GetCaster())
            self:GetCaster():Heal(base_dmg,self)
            return
        end
    end

    local dtable = {
        victim = self:GetCursorTarget(),
        attacker = self:GetCaster(),
        damage = base_dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self
    }
    ApplyDamage(dtable)


end
