
local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit
local AAATemporalFizzWeapon = import('/lua/aeonweapons.lua').AAATemporalFizzWeapon

local CreateAttachedEmitter = CreateAttachedEmitter

UAB2204 = Class(AStructureUnit) {
    Weapons = {
        AAFizz = Class(AAATemporalFizzWeapon) {
            ChargeEffectMuzzles = {'Turret_Right_Muzzle', 'Turret_Left_Muzzle'},
            
            PlayFxRackSalvoChargeSequence = function(self)
				local army = self.unit:GetArmy()
				
                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
                
                CreateAttachedEmitter( self.unit, 'Turret_Right_Muzzle', army, '/effects/emitters/temporal_fizz_muzzle_charge_02_emit.bp')
                CreateAttachedEmitter( self.unit, 'Turret_Left_Muzzle', army, '/effects/emitters/temporal_fizz_muzzle_charge_03_emit.bp')
            end,
        },
    },
}

TypeClass = UAB2204