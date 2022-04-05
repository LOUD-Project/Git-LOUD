local ALandUnit = import('/lua/defaultunits.lua').MobileUnit

local AAATemporalFizzWeapon = import('/lua/aeonweapons.lua').AAATemporalFizzWeapon

UAL0205 = Class(ALandUnit) {
    KickupBones = {},
    
    Weapons = {
        AAGun = Class(AAATemporalFizzWeapon) {
            ChargeEffectMuzzles = {'Muzzle_R01', 'Muzzle_L01'},
            
            PlayFxRackSalvoChargeSequence = function(self)
			
                local army = self.unit:GetArmy()
				local LOUDATTACHEMITTER = CreateAttachedEmitter
				
                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
                LOUDATTACHEMITTER( self.unit, 'Muzzle_R01', army, '/effects/emitters/temporal_fizz_muzzle_charge_02_emit.bp')
                LOUDATTACHEMITTER( self.unit, 'Muzzle_L01', army, '/effects/emitters/temporal_fizz_muzzle_charge_03_emit.bp')
            end,
        },
    },
    
    OnCreate = function(self)
        ALandUnit.OnCreate(self)
        self.Trash:Add(CreateSlaver(self, 'Barrel_L', 'Barrel_R'))
    end,    
}

TypeClass = UAL0205