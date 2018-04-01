#**************************************************************************** 
#**  File          : /lua/4D-SDR.lua 
#** 
#**  Author        : Resin_Smoker 
#** 
#**  Summary       : 4D_SDR: Allows a structure so enhanced to resist enemy fire. 
#** 
#**  Copyright © 2010 4DC  All rights reserved.
#**************************************************************************** 
#** 
#**  The following is required in the units script for Struture Damage Resistance (SDR)
#**  This calls into action the SDR scripts for AStructureUnit 
#** 
#**  local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit
#**  AStructureUnit = import('/mods/4DC/lua/CustomAbilities/4D-SDR/4D_SDR.lua').SDR( AStructureUnit )
#**  
#**  The following is required in the units blueprint for Struture Damage Resistance (SDR)
#**  
#** Defense = {
#**     SDR = {
#**         ActiveWhileAttacking = false,
#**         SDRPercent = 50,  
#**     },          
#** },
#** 
#**************************************************************************** 

### Start of Struture Damage Resistance(SuperClass) ###
function SDR(SuperClass) 
    return Class(SuperClass) {
    
    OnDamage = function(self, instigator, amount, vector, damagetype)
        #LOG('Incomming amount: ', amount)
        if not self:IsDead() then
            local damageReduction = self:GetBlueprint().Defense.SDR.SDRPercent / 100
            #LOG(' % of SDR: ', damageReduction)                     
            if  self:GetBlueprint().Defense.SDR.ActiveWhileAttacking == false then 
                if not self:GetTargetEntity() then
                    ### % reduction while not attacking                 
                    amount = math.ceil(amount - (amount * damageReduction ))
                    #LOG('Reduced amount: ', amount)
                else
                    ### 0% reduction while attacking
                    local damageReduction = 1.0
                    amount = math.ceil(amount * damageReduction)                
                end
            else
                ### % reduction while attacking
                amount = math.ceil(amount - (amount * damageReduction ))
            end
        end
        SuperClass.OnDamage(self, instigator, amount, vector, damagetype)
    end,           
}
end 
### End of Struture Damage Resistance(SuperClass) ###