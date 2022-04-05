local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AAATemporalFizzWeapon = import('/lua/aeonweapons.lua').AAATemporalFizzWeapon

UAB3304 = Class(AStructureUnit) {
    Weapons = {
        AAFizz = Class(AAATemporalFizzWeapon) {
            ChargeEffectMuzzles = {'Turret_Right_Muzzle', 'Turret_Left_Muzzle'},
            
            PlayFxRackSalvoChargeSequence = function(self)
				local army = self.unit:GetArmy()
				local CreateAttachedEmitter = CreateAttachedEmitter
				
                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
                CreateAttachedEmitter( self.unit, 'Turret_Right_Muzzle', army, '/effects/emitters/temporal_fizz_muzzle_charge_02_emit.bp')
                CreateAttachedEmitter( self.unit, 'Turret_Left_Muzzle', army, '/effects/emitters/temporal_fizz_muzzle_charge_03_emit.bp')
            end,
        },
    },
}

TypeClass = UAB3304