local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local GoldenLaserGenerator = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').GoldenLaserGenerator
local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon

local explosion = import('/lua/defaultexplosions.lua')

local LOUDINSERT = table.insert
local LOUDATTACHEMITTER = CreateAttachedEmitter
local AttachBeamEntityToEntity = AttachBeamEntityToEntity

BAL0403 = Class(AWalkingLandUnit) {

	ChargeEffects01 = {'/mods/BlackOpsUnleashed/effects/emitters/g_laser_flash_01_emit.bp',	'/mods/BlackOpsUnleashed/effects/emitters/g_laser_muzzle_01_emit.bp'},

    ChargeEffects02 = {'/mods/BlackOpsUnleashed/effects/emitters/g_laser_charge_01_emit.bp'},
	
    ChargeEffects03 = {'/mods/BlackOpsUnleashed/effects/emitters/g_laser_flash_01_emit.bp', '/mods/BlackOpsUnleashed/effects/emitters/g_laser_muzzle_01_emit.bp' },
	
    Weapons = {
	
        MainGun = Class(GoldenLaserGenerator) {
		
            OnWeaponFired = function(self)
			
				self:ForkThread(self.ArrayEffectsCleanup)
			
            	GoldenLaserGenerator.OnWeaponFired(self)
				
            	local wep = self.unit:GetWeaponByLabel('BoomWeapon')
				
            	self.targetaquired = self:GetCurrentTargetPos()
				
            	if self.targetaquired then
            		wep:SetTargetGround(self.targetaquired)
					self.unit:SetWeaponEnabledByLabel('BoomWeapon', true)
					wep:SetTargetGround(self.targetaquired)
					wep:OnFire()
				end
			end,
        
			PlayFxRackSalvoChargeSequence = function(self, muzzle)
		
				GoldenLaserGenerator.PlayFxRackSalvoChargeSequence(self, muzzle) 
				
            	local wep = self.unit:GetWeaponByLabel('MainGun')
        		local bp = wep:GetBlueprint()
                local army = self.unit.Army
				
				local LOUDINSERT = LOUDINSERT
				local LOUDATTACHEMITTER = CreateAttachedEmitter
				local AttachBeamEntityToEntity = AttachBeamEntityToEntity
                
        		if bp.Audio.RackSalvoCharge then
            		wep:PlaySound(bp.Audio.RackSalvoCharge)
        		end
				
        		if self.unit.ChargeEffects01Bag then
            		for k, v in self.unit.ChargeEffects01Bag do
                		v:Destroy()
            		end
		    		self.unit.ChargeEffects01Bag = {}
				end
				
        		for k, v in self.unit.ChargeEffects01 do
            		LOUDINSERT( self.unit.ChargeEffects01Bag, LOUDATTACHEMITTER( self.unit, 'ChargeBeam01', army, v ):ScaleEmitter(0.2))
            		LOUDINSERT( self.unit.ChargeEffects01Bag, LOUDATTACHEMITTER( self.unit, 'ChargeBeam02', army, v ):ScaleEmitter(0.2))
            		LOUDINSERT( self.unit.ChargeEffects01Bag, LOUDATTACHEMITTER( self.unit, 'ChargeBeam03', army, v ):ScaleEmitter(0.2))
        		end
				
        		if self.unit.ChargeEffects02Bag then
            		for k, v in self.unit.ChargeEffects02Bag do
                		v:Destroy()
            		end
		    		self.unit.ChargeEffects02Bag = {}
				end
				
        		for k, v in self.unit.ChargeEffects02 do
            		LOUDINSERT( self.unit.ChargeEffects02Bag, LOUDATTACHEMITTER( self.unit, 'Muzzle01', army, v ):ScaleEmitter(0.5))
        		end
				
        		if self.unit.ChargeEffects03Bag then
            		for k, v in self.unit.ChargeEffects03Bag do
                		v:Destroy()
            		end
		    		self.unit.ChargeEffects03Bag = {}
				end
				
        		for k, v in self.unit.ChargeEffects03 do
            		LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargePoint', army, v ):ScaleEmitter(0.5))
            		LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargePoint01', army, v ):ScaleEmitter(0.5))
            		LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargePoint02', army, v ):ScaleEmitter(0.5))
        		end
				
				if self.unit.BeamChargeEffects01 then
					for k, v in self.unit.BeamChargeEffects01 do
						v:Destroy()
					end
					self.unit.BeamChargeEffects01 = {}
				end
				
				LOUDINSERT( self.unit.BeamChargeEffects, AttachBeamEntityToEntity(self.unit, 'ChargeBeam01', self.unit, 'ChargePoint', army, '/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_charge_beam_01_emit.bp') )
				LOUDINSERT( self.unit.BeamChargeEffects, AttachBeamEntityToEntity(self.unit, 'ChargeBeam02', self.unit, 'ChargePoint', army, '/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_charge_beam_01_emit.bp') )
				LOUDINSERT( self.unit.BeamChargeEffects, AttachBeamEntityToEntity(self.unit, 'ChargeBeam03', self.unit, 'ChargePoint', army, '/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_charge_beam_01_emit.bp') )
				LOUDINSERT( self.unit.BeamChargeEffects, AttachBeamEntityToEntity(self.unit, 'ChargeBeam01', self.unit, 'ChargePoint01', army, '/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_charge_beam_01_emit.bp') )
				LOUDINSERT( self.unit.BeamChargeEffects, AttachBeamEntityToEntity(self.unit, 'ChargeBeam02', self.unit, 'ChargePoint01', army, '/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_charge_beam_01_emit.bp') )
				LOUDINSERT( self.unit.BeamChargeEffects, AttachBeamEntityToEntity(self.unit, 'ChargeBeam03', self.unit, 'ChargePoint01', army, '/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_charge_beam_01_emit.bp') )
				LOUDINSERT( self.unit.BeamChargeEffects, AttachBeamEntityToEntity(self.unit, 'ChargeBeam01', self.unit, 'ChargePoint02', army, '/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_charge_beam_01_emit.bp') )
				LOUDINSERT( self.unit.BeamChargeEffects, AttachBeamEntityToEntity(self.unit, 'ChargeBeam02', self.unit, 'ChargePoint02', army, '/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_charge_beam_01_emit.bp') )
				LOUDINSERT( self.unit.BeamChargeEffects, AttachBeamEntityToEntity(self.unit, 'ChargeBeam03', self.unit, 'ChargePoint02', army, '/mods/BlackOpsUnleashed/effects/emitters/mini_golden_laser_charge_beam_01_emit.bp') )
			end,
			
			ArrayEffectsCleanup = function(self)
			
				WaitTicks(20)
				
				if self.unit.BeamChargeEffects then
					for k, v in self.unit.BeamChargeEffects do
						v:Destroy()
					end
					self.unit.BeamChargeEffects = {}
				end
				
				if self.unit.ChargeEffects01Bag then
            		for k, v in self.unit.ChargeEffects01Bag do
                		v:Destroy()
            		end
		    		self.unit.ChargeEffects01Bag = {}
				end
				
				if self.unit.ChargeEffects02Bag then
            		for k, v in self.unit.ChargeEffects02Bag do
                		v:Destroy()
            		end
		    		self.unit.ChargeEffects02Bag = {}
				end
				
				if self.unit.ChargeEffects03Bag then
            		for k, v in self.unit.ChargeEffects03Bag do
                		v:Destroy()
            		end
		    		self.unit.ChargeEffects03Bag = {}
				end
			end,
        },
		
        BoomWeapon = Class(CDFLaserHeavyWeapon){
		
        	OnWeaponFired = function(self)
               	CDFLaserHeavyWeapon.OnWeaponFired(self)
				self:SetWeaponEnabled(false)
            end,
        },
    },
    
    OnStartBeingBuilt = function(self, builder, layer)
	
        AWalkingLandUnit.OnStartBeingBuilt(self, builder, layer)
		
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
		
        self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationActivate, false):SetRate(0)
    end,
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        AWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		
		self.BeamChargeEffects = {}
		self.ChargeEffects01Bag = {}
		self.ChargeEffects02Bag = {}
		self.ChargeEffects03Bag = {}
		
		self:SetWeaponEnabledByLabel('BoomWeapon', false)
		
		if self.AnimationManipulator then
		
            self:SetUnSelectable(true)
            self.AnimationManipulator:SetRate(1)
            
            self:ForkThread(function()
                WaitSeconds(self.AnimationManipulator:GetAnimationDuration()*self.AnimationManipulator:GetRate())
                self:SetUnSelectable(false)
                self.AnimationManipulator:Destroy()
            end)
        end     
    end,
    
    OnKilled = function(self, instigator, type, overkillRatio)
	
        AWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
		
        local wep = self:GetWeaponByLabel('MainGun')
        local bp = wep:GetBlueprint()
		
        if bp.Audio.BeamStop then
            wep:PlaySound(bp.Audio.BeamStop)
        end
		
        if bp.Audio.BeamLoop and wep.Beams[1].Beam then
            wep.Beams[1].Beam:SetAmbientSound(nil, nil)
        end
		
        for k, v in wep.Beams do
            v.Beam:Disable()
        end     
    end,
	
    DeathThread = function( self, overkillRatio , instigator)
	
        explosion.CreateDefaultHitExplosionAtBone( self, 'Barrel01', 4.0 )
		
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()})           
		
        WaitSeconds(1.5)
		
        explosion.CreateDefaultHitExplosionAtBone( self, 'F_R_Leg_B02', 1.0 )
		
        WaitSeconds(0.1)
		
        explosion.CreateDefaultHitExplosionAtBone( self, 'Target03', 1.0 )
		
		WaitSeconds(0.1)
		
        explosion.CreateDefaultHitExplosionAtBone( self, 'B_L_Leg_B03', 1.0 )
        explosion.CreateDefaultHitExplosionAtBone( self, 'Target02', 1.0 )
		
        WaitSeconds(0.3)
		
        explosion.CreateDefaultHitExplosionAtBone( self, 'B_L_Leg_B01', 1.0 )
        explosion.CreateDefaultHitExplosionAtBone( self, 'B_R_Leg_B02', 1.0 )

        WaitSeconds(1.3
		)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Turret01', 5.0 )        

        if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
    
        local bp = __blueprints[self.BlueprintID]
		
        for i, numWeapons in bp.Weapon do
            if(bp.Weapon[i].Label == 'CollossusDeath') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end

        self:DestroyAllDamageEffects()
        self:CreateWreckage( overkillRatio )

        if( self.ShowUnitDestructionDebris and overkillRatio ) then
            if overkillRatio <= 1 then
                self.CreateUnitDestructionDebris( self, true, true, false )
            elseif overkillRatio <= 2 then
                self.CreateUnitDestructionDebris( self, true, true, false )
            elseif overkillRatio <= 3 then
                self.CreateUnitDestructionDebris( self, true, true, true )
            else #VAPORIZED
                self.CreateUnitDestructionDebris( self, true, true, true )
            end
        end

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,
}

TypeClass = BAL0403