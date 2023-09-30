local SSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SDFHeavyQuarnonCannon = SeraphimWeapons.SDFHeavyQuarnonCannon
local SAMElectrumMissileDefense = SeraphimWeapons.SAMElectrumMissileDefense
local SAAOlarisCannonWeapon = SeraphimWeapons.SAAOlarisCannonWeapon
local SDFUltraChromaticBeamGenerator = SeraphimWeapons.SDFUltraChromaticBeamGenerator02
local SIFHuAntiNukeWeapon = import('/lua/seraphimweapons.lua').SIFHuAntiNukeWeapon
local SDFSinnuntheWeapon = SeraphimWeapons.SDFSinnuntheWeapon

local nukeFiredOnGotTarget = false

local CreateRotator = CreateRotator
local explosion = import('/lua/defaultexplosions.lua')

BSS0401 = Class(SSeaUnit) {

    FxDamageScale = 2,
    DestructionTicks = 400,
	
    SpawnEffects = {
		'/effects/emitters/seraphim_othuy_spawn_01_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_02_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_03_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_04_emit.bp',
	},

    Weapons = {
	
    	FrontMainTurret = Class(SDFSinnuntheWeapon) {
		
            PlayFxWeaponPackSequence = function(self)
			
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
				
                SDFSinnuntheWeapon.PlayFxWeaponPackSequence(self)
				
            end,
        
            PlayFxRackSalvoChargeSequence = function(self)
			
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Main_Front_Turret_Spinner', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
   
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(900)
                end
				
                SDFSinnuntheWeapon.PlayFxRackSalvoChargeSequence(self)
				
            end,            
            
            PlayFxRackSalvoReloadSequence = function(self)
			
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(100)
                end
				
                SDFSinnuntheWeapon.PlayFxRackSalvoChargeSequence(self)
				
            end,
		},
		
        BackMainTurret = Class(SDFSinnuntheWeapon) {
		
            PlayFxWeaponPackSequence = function(self)
			
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
				
                SDFSinnuntheWeapon.PlayFxWeaponPackSequence(self)
				
            end,
        
            PlayFxRackSalvoChargeSequence = function(self)
			
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Main_Back_Turret_Spinner', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
   
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(900)
                end
				
                SDFSinnuntheWeapon.PlayFxRackSalvoChargeSequence(self)
				
            end,            
            
            PlayFxRackSalvoReloadSequence = function(self)
			
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(100)
                end
				
                SDFSinnuntheWeapon.PlayFxRackSalvoChargeSequence(self)
				
            end,
			
		},
		
        SecondaryTurret = Class(SDFHeavyQuarnonCannon) {},
		
        AntiMissileTactical = Class(SAMElectrumMissileDefense) {},
		
        AAGun = Class(SAAOlarisCannonWeapon) {},
		
        DeckGun = Class(SDFUltraChromaticBeamGenerator) {},
		
        MissileRack = Class(SIFHuAntiNukeWeapon) {},  

        },
		
    },
	
	OnStopBeingBuilt = function(self, builder, layer)
        self:HideBone('Pod04', true)
        self:HideBone('Pod05', true)
        self:HideBone('Pod06', true)
        SSeaUnit.OnStopBeingBuilt(self, builder, layer)
    end,

	OnKilled = function(self, inst, type, okr)

		self.Trash:Destroy()
        self.Trash = TrashBag()

        SSeaUnit.OnKilled(self, inst, type, okr)
		
    end,
	
	
    DeathThread = function( self, overkillRatio , instigator)

        local bp = __blueprints[self.BlueprintID]
		
        for i, numWeapons in bp.Weapon do
		
            if(bp.Weapon[i].Label == 'CollossusDeath') then
			
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
				
            end
			
        end

        -- Spawn a death ball
        local position = self:GetPosition()
        local spiritUnit = CreateUnitHPR('XSL0402', self:GetArmy(), position[1], position[2], position[3], 0, 0, 0)
        
		for k, v in self.SpawnEffects do
		
			CreateAttachedEmitter(spiritUnit, -1, self:GetArmy(), v )
			
		end	

        explosion.CreateDefaultHitExplosionAtBone( self, 'Main_Front_Turret', 5.0 )        

        if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
    
        self:DestroyAllDamageEffects()
        self:CreateWreckage( overkillRatio )

        self:PlayUnitSound('Destroyed')
        self:Destroy()
		
    end,
	
}

TypeClass = BSS0401