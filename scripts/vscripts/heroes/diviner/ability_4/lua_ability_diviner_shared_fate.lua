LinkLuaModifier( "lua_modifier_diviner_shared_fate_scepter", "heroes/diviner/ability_4/lua_modifier_diviner_shared_fate", LUA_MODIFIER_MOTION_NONE )



lua_ability_diviner_shared_fate = class({})


function lua_ability_diviner_shared_fate:CastFilterResultTarget(target)
    if not IsServer() then return end

    if target:IsCreep() then return UF_FAIL_CREEP end
    if target:IsBuilding() then return UF_FAIL_BUILDING  end
    if target:IsCourier() then return UF_FAIL_COURIER end
    if target:IsOther() then return UF_FAIL_OTHER end
    if target:IsAlive() == false then return UF_FAIL_DEAD end
    if self:GetCaster():IsAlive() == false then return UF_FAIL_DEAD end
    if target:IsInvulnerable() then return UF_FAIL_INVULNERABLE end
    --if self:GetCaster():CanEntityBeSeenByMyTeam(target) == false then return UF_FAIL_IN_FOW end
    --if target:IsInvisible() then return UF_FAIL_INVISIBLE end
    if target:IsOutOfGame() then return UF_FAIL_OUT_OF_WORLD end
    if target == self:GetCaster() then return UF_FAIL_CUSTOM end

    return UF_SUCCESS
end



function lua_ability_diviner_shared_fate:GetCustomCastErrorTarget(target)
    if target == self:GetCaster() then
        return "Invalid Target"
    end
end



function lua_ability_diviner_shared_fate:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    if self:GetCaster():HasScepter() then
        cast_range = cast_range+self:GetLevelSpecialValueFor("scepter_cast_range",0)
    end
    return cast_range
end


function lua_ability_diviner_shared_fate:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_diviner_shared_fate:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_diviner_shared_fate:GetChannelTime()
    local effect_duration = self:GetLevelSpecialValueFor("effect_duration",0)
    return effect_duration
end


function lua_ability_diviner_shared_fate:OtherAbilitiesAlwaysInterruptChanneling()
    return true
end


function lua_ability_diviner_shared_fate:OnSpellStart()
    if not IsServer() then return end

    self:GetCursorTarget():EmitSound("Hero_Oracle.FalsePromise.Cast")

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then
        self:GetCaster():Interrupt()
        return
    end

    --self:GetCursorTarget():EmitSound("Hero_Oracle.FalsePromise.Target")

    self.my_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_oracle/oracle_false_promise_indicator.vpcf",
        PATTACH_OVERHEAD_FOLLOW,self:GetCaster()
    )
    ParticleManager:SetParticleControlEnt(self.my_particle,0,self:GetCaster(),PATTACH_OVERHEAD_FOLLOW,"follow_overhead",Vector(0,0,0),false)

    self.target_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_oracle/oracle_false_promise_indicator.vpcf",
        PATTACH_OVERHEAD_FOLLOW,self:GetCursorTarget()
    )
    ParticleManager:SetParticleControlEnt(self.target_particle,0,self:GetCursorTarget(),PATTACH_OVERHEAD_FOLLOW,"follow_overhead",Vector(0,0,0),false)


    local my_hp = {}
    my_hp["current"] = self:GetCaster():GetHealth()
    my_hp["max"] = self:GetCaster():GetMaxHealth()
    my_hp["percent"] = self:GetCaster():GetHealthPercent()

    local target_hp = {}
    target_hp["current"] = self:GetCursorTarget():GetHealth()
    target_hp["max"] = self:GetCursorTarget():GetMaxHealth()
    target_hp["percent"] = self:GetCursorTarget():GetHealthPercent()

    self.effect_duration = self:GetSpecialValueFor("effect_duration")

    self.is_friend = false
    if self:GetCursorTarget():GetTeam() == self:GetCaster():GetTeam() then
        self.is_friend = true
    end

    self.target = nil

    if self.is_friend == true then

        --if i hamve more hp than my team mate
        if my_hp["percent"] >= target_hp["percent"] then

            local ideal_hp = target_hp["max"]*my_hp["percent"]*0.01
            local diff_hp = ideal_hp - target_hp["current"]
            self.increment_hp = (diff_hp/self.effect_duration)
            self.target = self:GetCursorTarget()
            ParticleManager:SetParticleControl(self.target_particle,2,Vector(500,0,0))
            return

        end

        --if my teammate have more hp than mine
        local ideal_hp = my_hp["max"]*target_hp["percent"]*0.01
        local diff_hp = ideal_hp - my_hp["current"]
        self.increment_hp = (diff_hp/self.effect_duration)
        self.target = self:GetCaster()
        ParticleManager:SetParticleControl(self.my_particle,2,Vector(500,0,0))
        return

    else

        if self:GetCaster():HasScepter() then
            self:GetCursorTarget():AddNewModifier(
                self:GetCaster(),self,
                "lua_modifier_diviner_shared_fate_scepter",
                {duration = self.effect_duration}
            )
        end

        if my_hp["percent"] >= target_hp["percent"] then

            local ideal_hp = my_hp["max"]*target_hp["percent"]*0.01
            local diff_hp = my_hp["current"] - ideal_hp
            self.increment_hp = (diff_hp/self.effect_duration)
            self.target = self:GetCaster()
            ParticleManager:SetParticleControl(self.my_particle,1,Vector(500,0,0))
            return

        end

        local ideal_hp = target_hp["max"]*my_hp["percent"]*0.01
        local diff_hp = target_hp["current"] - ideal_hp
        self.increment_hp = (diff_hp/self.effect_duration)
        self.target = self:GetCursorTarget()
        ParticleManager:SetParticleControl(self.target_particle,1,Vector(500,0,0))
        return
    end

end



function lua_ability_diviner_shared_fate:OnChannelThink(delta)

    if self:GetCaster():IsAlive() == false then return end

    if self:GetCursorTarget():IsAlive() == false then return end

    if not self.increment_hp then return end

    if not self.target then return end

    if self.is_friend == true then
        local heal = self.increment_hp*delta
        local new_hp = self.target:GetHealth()+heal
        self.target:ModifyHealth(new_hp,self,false,0)
    else
        local decrease = self.increment_hp*delta
        local new_hp = self.target:GetHealth()-decrease
        self.target:ModifyHealth(new_hp,self,false,0)
    end
end



function lua_ability_diviner_shared_fate:OnChannelFinish(interrupted)

    --self:GetCursorTarget():StopSound("Hero_Oracle.FalsePromise.Target")

    if not self.my_particle == false then
        ParticleManager:DestroyParticle(self.my_particle,false)
        ParticleManager:ReleaseParticleIndex(self.my_particle)
        self.my_particle  = nil
    end

    if not self.target_particle == false then
        ParticleManager:DestroyParticle(self.target_particle,false)
        ParticleManager:ReleaseParticleIndex(self.target_particle)
        self.target_particle  = nil
    end

    if self:GetCursorTarget():IsAlive() then
        local scepter_mod = self:GetCursorTarget():FindModifierByName("lua_modifier_diviner_shared_fate_scepter")
        if not scepter_mod == false then
            scepter_mod:Destroy()
        end
    end
end
