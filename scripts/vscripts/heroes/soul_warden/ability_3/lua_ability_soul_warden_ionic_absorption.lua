LinkLuaModifier( "lua_modifier_soul_warden_ionic_absorption", "heroes/soul_warden/ability_3/lua_modifier_soul_warden_ionic_absorption", LUA_MODIFIER_MOTION_NONE )


lua_ability_soul_warden_ionic_absorption = class({})



function lua_ability_soul_warden_ionic_absorption:GetCooldown(lvl)
    local cd = self:GetLevelSpecialValueFor("ability_cd",0)
    local talent = self:GetCaster():FindAbilityByName("special_bonus_soul_warden_ionic_absorption_reduce_cd")
    if not talent == false then
        if talent:GetLevel() > 0 then
            cd = cd-talent:GetSpecialValueFor("value")
        end
    end
    return cd
end



function lua_ability_soul_warden_ionic_absorption:GetAOERadius()
    local range = self:GetLevelSpecialValueFor("aoe_range",0)
    local talent = self:GetCaster():FindAbilityByName("special_bonus_soul_warden_ionic_absorption_range")
    if not talent == false then
        if talent:GetLevel() > 0 then
            range = range+talent:GetSpecialValueFor("value")
        end
    end
    return range
end



function lua_ability_soul_warden_ionic_absorption:GetCastRange(pos,target)
    return self:GetAOERadius()
end



function lua_ability_soul_warden_ionic_absorption:OnSpellStart()

    local aoe_range = self:GetAOERadius()
    local aoe_damage = self:GetSpecialValueFor("aoe_damage")
    local mana_drain_percent = self:GetSpecialValueFor("mana_drain_percent")*0.01
    local mana_gain_per_stack = self:GetSpecialValueFor("mana_gain_per_stack")
    local ms_duration = self:GetSpecialValueFor("ms_duration")
    local ms_initial = self:GetSpecialValueFor("ms_initial")
    local ms_max_stack = self:GetSpecialValueFor("ms_max_stack")
    local ms_per_stack = self:GetSpecialValueFor("ms_per_stack")
    local caster_player = self:GetCaster():GetPlayerOwner()

    --local effect_duration = self:GetSpecialValueFor("effect_duration")


    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        aoe_range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    local stacks = 0 --max 3
    local total_mana_gained = 0

    for _,enemy in pairs(enemies) do
        if enemy:IsMagicImmune() == false then

            local enemy_player = enemy:GetPlayerOwner()

            local current_mana = enemy:GetMana()
            local max_mana = enemy:GetMaxMana()
            local stolen_mana = math.min(max_mana*mana_drain_percent,current_mana)
            enemy:ReduceMana(stolen_mana)

            SendOverheadEventMessage(caster_player,OVERHEAD_ALERT_MANA_LOSS,enemy,stolen_mana,caster_player)
            SendOverheadEventMessage(enemy_player,OVERHEAD_ALERT_MANA_LOSS,enemy,stolen_mana,caster_player)


            if stolen_mana > 0 then
                stacks = stacks+1
                local gain_mana = math.min(stolen_mana,mana_gain_per_stack)
                total_mana_gained = total_mana_gained+gain_mana
            end


            --apply Damage
            local dtable = {
                victim = enemy,
                attacker = self:GetCaster(),
                damage = aoe_damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                ability = self
            }

            ApplyDamage(dtable)

            local particle = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf",
                PATTACH_POINT_FOLLOW,self:GetCaster()
            )

            ParticleManager:SetParticleControlEnt(
                particle,0,self:GetCaster(),PATTACH_OVERHEAD_FOLLOW,"follow_overhead",Vector(0,0,0),false
            )

            ParticleManager:SetParticleControlEnt(
                particle,1,enemy,PATTACH_POINT_FOLLOW,"attach_hitloc",Vector(0,0,0),false
            )

            ParticleManager:SetParticleControl(particle,2,Vector(4,0,0))
            ParticleManager:DestroyParticle(particle,false)
            ParticleManager:ReleaseParticleIndex(particle)

        end
	end

    self:GetCaster():GiveMana(total_mana_gained)
    SendOverheadEventMessage(caster_player,OVERHEAD_ALERT_MANA_ADD,self:GetCaster(),total_mana_gained,caster_player)


    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_soul_warden_ionic_absorption",
        {
            duration = ms_duration,
            ms_stacks = math.min(stacks,ms_max_stack)
        }
    )

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf",
        PATTACH_POINT_FOLLOW,self:GetCaster()
    )

    ParticleManager:SetParticleControlEnt(
        particle,0,self:GetCaster(),PATTACH_OVERHEAD_FOLLOW,"follow_overhead",Vector(0,0,0),false
    )

    ParticleManager:SetParticleControlEnt(
        particle,1,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_hitloc",Vector(0,0,0),false
    )

    ParticleManager:SetParticleControl(particle,2,Vector(4,0,0))
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)

    self:GetCaster():EmitSound("Hero_Razor.UnstableCurrent.Strike")
end
