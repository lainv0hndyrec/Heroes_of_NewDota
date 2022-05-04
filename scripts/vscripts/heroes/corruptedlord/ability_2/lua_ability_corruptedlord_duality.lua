LinkLuaModifier( "lua_modifier_corruptedlord_duality_chaos", "heroes/corruptedlord/ability_2/lua_modifier_corruptedlord_duality", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_corruptedlord_duality_solace", "heroes/corruptedlord/ability_2/lua_modifier_corruptedlord_duality", LUA_MODIFIER_MOTION_NONE )


lua_ability_corruptedlord_duality_chaos = class({})


function lua_ability_corruptedlord_duality_chaos:OnUpgrade()

    self.caster = self:GetCaster()
    self.switch_name = "lua_ability_corruptedlord_duality_solace"
    self.ability_switch = self.caster:FindAbilityByName(self.switch_name)

    if not self.ability_switch then return end

    self.ability_switch.caster = self.caster
    self.ability_switch.switch_name = "lua_ability_corruptedlord_duality_chaos"
    self.ability_switch.ability_switch = self

    self.ability_switch:SetLevel(self:GetLevel())

    --update the modifier
    if not self.modifier == false then
        self.modifier:Destroy()
        self.modifier = self.caster:AddNewModifier(self.caster,self,"lua_modifier_corruptedlord_duality_chaos",{})
    end

    if not self.ability_switch.modifier == false then
        self.ability_switch.modifier:Destroy()
        self.ability_switch.modifier = self.caster:AddNewModifier(self.caster,self.ability_switch,"lua_modifier_corruptedlord_duality_solace",{})
    end


end




function lua_ability_corruptedlord_duality_chaos:OnToggle()


    if self:GetToggleState() == true then
        if not self.modifier then
            self.modifier = self.caster:AddNewModifier(self.caster,self,"lua_modifier_corruptedlord_duality_chaos",{})
        end

        if self.ability_switch:GetToggleState() == true then
            self.caster:CastAbilityToggle(self.ability_switch,self.caster:GetPlayerID())
        end

        if not self.weapon_particle then
            self.weapon_particle = ParticleManager:CreateParticle(
                "particles/units/heroes/corrupted_lord/ability_2/duality_modifier_1.vpcf",
                PATTACH_ABSORIGIN_FOLLOW,
                self.caster
            )
            self.ability_switch.weapon_particle = self.weapon_particle
        end

        ParticleManager:SetParticleControl(self.weapon_particle,60,Vector(255,0,0))

    else

        if not self.modifier == false then
            self.modifier:Destroy()
            self.modifier = nil
        end

        if not self.weapon_particle == false then
            ParticleManager:DestroyParticle(self.weapon_particle,false)
            ParticleManager:ReleaseParticleIndex(self.weapon_particle)
            self.weapon_particle = nil
            self.ability_switch.weapon_particle = nil
        end

    end



end





function lua_ability_corruptedlord_duality_chaos:ProcsMagicStick()
	return false
end




function lua_ability_corruptedlord_duality_chaos:GetAssociatedSecondaryAbilities()
    return "lua_ability_corruptedlord_duality_solace"
end



-------------------------------------
-------------------------------------
-------------------------------------


lua_ability_corruptedlord_duality_solace = class({})




function lua_ability_corruptedlord_duality_solace:OnToggle()


    if self:GetToggleState() == true then
        if not self.modifier then
            self.modifier = self.caster:AddNewModifier(self.caster,self,"lua_modifier_corruptedlord_duality_solace",{})
        end

        if self.ability_switch:GetToggleState() == true then
            self.caster:CastAbilityToggle(self.ability_switch,self.caster:GetPlayerID())
        end

        if not self.weapon_particle then
            self.weapon_particle = ParticleManager:CreateParticle(
                "particles/units/heroes/corrupted_lord/ability_2/duality_modifier_1.vpcf",
                PATTACH_ABSORIGIN_FOLLOW,
                self.caster
            )
            self.ability_switch.weapon_particle = self.weapon_particle
        end

        ParticleManager:SetParticleControl(self.weapon_particle,60,Vector(0,255,0))

    else

        if not self.modifier == false then
            self.modifier:Destroy()
            self.modifier = nil
        end

        if not self.weapon_particle == false then
            ParticleManager:DestroyParticle(self.weapon_particle,false)
            ParticleManager:ReleaseParticleIndex(self.weapon_particle)
            self.weapon_particle = nil
            self.ability_switch.weapon_particle = nil
        end
    end

end





function lua_ability_corruptedlord_duality_solace:ProcsMagicStick()
	return false
end




function lua_ability_corruptedlord_duality_solace:GetAssociatedPrimaryAbilities()
    return "lua_ability_corruptedlord_duality_chaos"
end
