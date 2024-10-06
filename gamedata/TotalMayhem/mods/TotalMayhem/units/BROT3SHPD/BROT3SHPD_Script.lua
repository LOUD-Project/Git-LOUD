local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local DefaultProjectileWeapon           = import('/lua/sim/defaultweapons.lua').DefaultProjectileWeapon
local AAAZealotMissileWeapon            = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon
local TIFCommanderDeathWeapon           = import('/lua/terranweapons.lua').TIFCommanderDeathWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local LOUDATTACHEMITTER = CreateAttachedEmitter

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag      = TrashBag
local TrashAdd      = TrashBag.Add

BROT3SHPD = Class(TStructureUnit) {

    Weapons = {

        MainGun = Class(DefaultProjectileWeapon) {

            FxMuzzleFlashScale = 0.5,

			FxGroundEffect  = EffectTemplate.ConcussionRingLrg01,
	        FxMuzzleEffect  = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
	        FxVentEffect    = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2   = EffectTemplate.WeaponSteam01,			
	        FxVentEffect3   = EffectTemplate.CDisruptorGroundEffect,

	        PlayFxMuzzleSequence = function(self, muzzle)

                local unit = self.unit    
		        local army = unit:GetArmy()
		        
	            for k, v in self.FxGroundEffect do
                    LOUDATTACHEMITTER( unit, 'BROT3SHPD', army, v):ScaleEmitter(0.4)
                end
				
  	            for k, v in self.FxMuzzleEffect do
                    LOUDATTACHEMITTER( unit, muzzle, army, v):ScaleEmitter(0.7)
                end
				
  	            for k, v in self.FxVentEffect do
                    LOUDATTACHEMITTER( unit, 'vent01', army, v):ScaleEmitter(0.6)
                    LOUDATTACHEMITTER( unit, 'vent02', army, v):ScaleEmitter(0.8)
                    LOUDATTACHEMITTER( unit, 'vent03', army, v):ScaleEmitter(0.6)
                    LOUDATTACHEMITTER( unit, 'vent04', army, v):ScaleEmitter(0.8)
                    LOUDATTACHEMITTER( unit, 'vent05', army, v):ScaleEmitter(0.6)
                    LOUDATTACHEMITTER( unit, 'vent06', army, v):ScaleEmitter(0.8)
                    LOUDATTACHEMITTER( unit, 'vent07', army, v):ScaleEmitter(0.6)
                    LOUDATTACHEMITTER( unit, 'vent08', army, v):ScaleEmitter(0.8)
                    LOUDATTACHEMITTER( unit, 'vent09', army, v):ScaleEmitter(0.6)
                    LOUDATTACHEMITTER( unit, 'vent10', army, v):ScaleEmitter(0.8)
                end
				
  	            for k, v in self.FxVentEffect2 do
                    LOUDATTACHEMITTER( unit, muzzle, army, v):ScaleEmitter(0.5)
                end
				
	            for k, v in self.FxVentEffect3 do
                    LOUDATTACHEMITTER( unit, 'BROT3SHPD', army, v):ScaleEmitter(0.4)
                end

            end,  
		},
		
        AAMissiles  = Class(AAAZealotMissileWeapon) {},		

        DeathWeapon = Class(TIFCommanderDeathWeapon) {},

    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		TStructureUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

	end,	

}

TypeClass = BROT3SHPD