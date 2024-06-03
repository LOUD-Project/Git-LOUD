local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AAATemporalFizzWeapon = import('/lua/aeonweapons.lua').AAATemporalFizzWeapon

local CreateAttachedEmitter = CreateAttachedEmitter

UAB2204 = Class(AStructureUnit) {

    Weapons = {

        AAFizz = Class(AAATemporalFizzWeapon) {
        
            ChargeEffectMuzzles = {'Turret_Right_Muzzle', 'Turret_Left_Muzzle'},
            
            PlayFxRackSalvoChargeSequence = function(self)

                local unit = self.unit
				local army = unit:GetArmy()
				
                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
   
                CreateAttachedEmitter( unit, 'Turret_Right_Muzzle', army, '/effects/emitters/temporal_fizz_muzzle_charge_02_emit.bp')
                CreateAttachedEmitter( unit, 'Turret_Left_Muzzle', army, '/effects/emitters/temporal_fizz_muzzle_charge_03_emit.bp')
            end,
        },
    },
}

TypeClass = UAB2204