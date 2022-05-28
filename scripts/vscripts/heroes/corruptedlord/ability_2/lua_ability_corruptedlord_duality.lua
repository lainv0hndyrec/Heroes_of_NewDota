LinkLuaModifier( "lua_modifier_corruptedlord_duality_chaos", "heroes/corruptedlord/ability_2/lua_modifier_corruptedlord_duality", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_corruptedlord_duality_solace", "heroes/corruptedlord/ability_2/lua_modifier_corruptedlord_duality", LUA_MODIFIER_MOTION_NONE )


lua_ability_corruptedlord_duality_chaos = class({})


function lua_ability_corruptedlord_duality_chaos:ProcsMagicStick() return false end
function lua_ability_corruptedlord_duality_chaos:GetAssociatedSecondaryAbilities() return "lua_ability_corruptedlord_duality_solace" end



function lua_ability_corruptedlord_duality_chaos:OnUpgrade()
    local solace_ability = self:GetCaster():FindAbilityByName("lua_ability_corruptedlord_duality_solace")
    if not solace_ability == false then
        solace_ability:SetLevel(self:GetLevel())
    end
end




function lua_ability_corruptedlord_duality_chaos:OnToggle()


    if self:GetToggleState() == true then

        local solace_ability = self:GetCaster():FindAbilityByName("lua_ability_corruptedlord_duality_solace")
        if not solace_ability == false then
            if solace_ability:GetToggleState() == true then
                solace_ability:ToggleAbility()
            end
        end


        self:GetCaster():AddNewModifier(
            self:GetCaster(),self ,
            "lua_modifier_corruptedlord_duality_chaos",
            {}
        )

    else

        local chaos_mod = self:GetCaster():FindModifierByName("lua_modifier_corruptedlord_duality_chaos")
        if not chaos_mod == false then
            chaos_mod:Destroy()
        end
    end

end












-------------------------------------
-------------------------------------
-------------------------------------


lua_ability_corruptedlord_duality_solace = class({})

function lua_ability_corruptedlord_duality_solace:ProcsMagicStick() return false end
function lua_ability_corruptedlord_duality_solace:GetAssociatedPrimaryAbilities() return "lua_ability_corruptedlord_duality_chaos" end


function lua_ability_corruptedlord_duality_solace:OnToggle()


    if self:GetToggleState() == true then

        local chaos_ability = self:GetCaster():FindAbilityByName("lua_ability_corruptedlord_duality_chaos")
        if not chaos_ability == false then
            if chaos_ability:GetToggleState() == true then
                chaos_ability:ToggleAbility()
            end
        end


        self:GetCaster():AddNewModifier(
            self:GetCaster(),self ,
            "lua_modifier_corruptedlord_duality_solace",
            {}
        )

    else

        local solace_mod = self:GetCaster():FindModifierByName("lua_modifier_corruptedlord_duality_solace")
        if not solace_mod == false then
            solace_mod:Destroy()
        end
    end

end
