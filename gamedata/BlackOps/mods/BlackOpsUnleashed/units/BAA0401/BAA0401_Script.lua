local AAirUnit = import('/lua/aeonunits.lua').AAirUnit

local ArtemisLaserGenerator = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').ArtemisLaserGenerator
local TDFMachineGunWeapon = import('/lua/terranweapons.lua').TDFMachineGunWeapon
local CIFCommanderDeathWeapon = import('/lua/cybranweapons.lua').CIFCommanderDeathWeapon

local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

local explosion = import('/lua/defaultexplosions.lua')

#local Effects = import('/lua/effecttemplates.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone
#local Entity = import('/lua/sim/Entity.lua').Entity

local LOUDINSERT = table.insert
local LOUDATTACHEMITTER = CreateAttachedEmitter
local CreateRotator = CreateRotator

BAA0401 = Class(AAirUnit) {

	DestroyNoFallRandomChance = 1.1,  
	
	ChargeEffects01 = BlackOpsEffectTemplate.ArtemisMuzzleChargeFlash,
	ChargeEffects02 = BlackOpsEffectTemplate.ArtemisMuzzleChargeeffect01,
	ChargeEffects03 = BlackOpsEffectTemplate.ArtemisMuzzleChargeeffect02,

    Weapons = {
		BeamGun = Class(ArtemisLaserGenerator) {
			OnCreate = function(self)
			
				local CreateRotator = CreateRotator
				
				if not self.unit.SpinManip then 
                    self.unit.SpinManip = CreateRotator(self.unit, 'Ring_1', 'y', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.unit.SpinManip)
                end
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(50)
                end
				
                if not self.unit.SpinManip2 then 
                    self.unit.SpinManip2 = CreateRotator(self.unit, 'Ring_2', 'y', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.unit.SpinManip2)
                end
				if self.unit.SpinManip2 then
                    self.unit.SpinManip2:SetTargetSpeed(-60)
                end
				
				if not self.unit.SpinManip3 then 
                    self.unit.SpinManip3 = CreateRotator(self.unit, 'Ring_3', 'y', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.unit.SpinManip3)
                end
				if self.unit.SpinManip3 then
                    self.unit.SpinManip3:SetTargetSpeed(30)
                end
				
				if not self.unit.SpinManip4 then 
                    self.unit.SpinManip4 = CreateRotator(self.unit, 'Ring_4', 'y', nil, 270, 180, 600)
                    self.unit.Trash:Add(self.unit.SpinManip4)
                end
				if self.unit.SpinManip4 then
                    self.unit.SpinManip4:SetTargetSpeed(-150)
                end
				
				if not self.unit.SpinManip5 then 
                    self.unit.SpinManip5 = CreateRotator(self.unit, 'Ring_5', 'y', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.unit.SpinManip5)
                end
				if self.unit.SpinManip5 then
                    self.unit.SpinManip5:SetTargetSpeed(150)
                end
				
				if not self.unit.SpinManip6 then 
                    self.unit.SpinManip6 = CreateRotator(self.unit, 'Ring_6', 'y', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.unit.SpinManip6)
                end
				if self.unit.SpinManip6 then
                    self.unit.SpinManip6:SetTargetSpeed(-150)
                end
				
				if not self.unit.SpinManip7 then 
                    self.unit.SpinManip7 = CreateRotator(self.unit, 'Ring_7', 'y', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.unit.SpinManip7)
                end
				if self.unit.SpinManip7 then
                    self.unit.SpinManip7:SetTargetSpeed(50)
                end
				
				if not self.unit.SpinManip8 then 
                    self.unit.SpinManip8 = CreateRotator(self.unit, 'Ring_8', 'y', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.unit.SpinManip8)
                end
				if self.unit.SpinManip8 then
                    self.unit.SpinManip8:SetTargetSpeed(-80)
                end
				
				if not self.unit.SpinManip9 then 
                    self.unit.SpinManip9 = CreateRotator(self.unit, 'Ring_9', 'y', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.unit.SpinManip9)
                end
				if self.unit.SpinManip9 then
                    self.unit.SpinManip9:SetTargetSpeed(80)
                end
                ArtemisLaserGenerator.OnCreate(self)
			end,
			
			PlayFxRackSalvoChargeSequence = function(self, muzzle)
				local wep = self.unit:GetWeaponByLabel('BeamGun')
        		local bp = wep:GetBlueprint()
        		if bp.Audio.RackSalvoCharge then
            		wep:PlaySound(bp.Audio.RackSalvoCharge)
        		end
				
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(1000)
                end
                
                if self.unit.SpinManip2 then
                    self.unit.SpinManip2:SetTargetSpeed(-1000)
                end
				
				if self.unit.SpinManip3 then
                    self.unit.SpinManip3:SetTargetSpeed(1000)
                end
				
				if self.unit.SpinManip4 then
                    self.unit.SpinManip4:SetTargetSpeed(-1000)
                end
				
				if self.unit.SpinManip5 then
                    self.unit.SpinManip5:SetTargetSpeed(1000)
                end
				
				if self.unit.SpinManip6 then
                    self.unit.SpinManip6:SetTargetSpeed(-1000)
                end
				
				if self.unit.SpinManip7 then
                    self.unit.SpinManip7:SetTargetSpeed(1000)
                end
				
				if self.unit.SpinManip8 then
                    self.unit.SpinManip8:SetTargetSpeed(-1000)
                end
				
				if self.unit.SpinManip9 then
                    self.unit.SpinManip9:SetTargetSpeed(1000)
                end
				
				if self.unit.ChargeEffects01Bag then
            		for k, v in self.unit.ChargeEffects01Bag do
                		v:Destroy()
            		end
		    		self.unit.ChargeEffects01Bag = {}
				end
                
                local army = self.unit:GetArmy()
				local LOUDINSERT = table.insert
				local LOUDATTACHEMITTER = CreateAttachedEmitter
                
        		for k, v in self.unit.ChargeEffects01 do
            		LOUDINSERT( self.unit.ChargeEffects01Bag, LOUDATTACHEMITTER( self.unit, 'Nuke_Muzzle01', army, v ):ScaleEmitter(2))
        		end
				
				if self.unit.ChargeEffects02Bag then
            		for k, v in self.unit.ChargeEffects02Bag do
                		v:Destroy()
            		end
		    		self.unit.ChargeEffects02Bag = {}
				end
        		for k, v in self.unit.ChargeEffects02 do
            		LOUDINSERT( self.unit.ChargeEffects02Bag, LOUDATTACHEMITTER( self.unit, 'ChargeEffect01', army, v ):ScaleEmitter(1))
					LOUDINSERT( self.unit.ChargeEffects02Bag, LOUDATTACHEMITTER( self.unit, 'ChargeEffect02', army, v ):ScaleEmitter(1))
        		end
				
				if self.unit.ChargeEffects03Bag then
            		for k, v in self.unit.ChargeEffects03Bag do
                		v:Destroy()
            		end
		    		self.unit.ChargeEffects03Bag = {}
				end
        		for k, v in self.unit.ChargeEffects03 do
            		LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura01', army, v ):ScaleEmitter(0.1) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura01', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.8, 0) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura01', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.8, 0) )
					
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura02', army, v ):ScaleEmitter(0.1) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura02', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.8, 0) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura02', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.8, 0) )
					
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura03', army, v ):ScaleEmitter(0.1) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura03', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.8, 0) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura03', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.8, 0) )
					
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura04', army, v ):ScaleEmitter(0.1) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura04', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.8, 0) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura04', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.8, 0) )
					
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura05', army, v ):ScaleEmitter(0.1) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura05', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.8, 0) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura05', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.8, 0) )
					
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura06', army, v ):ScaleEmitter(0.1) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura06', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.8, 0) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura06', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.8, 0) )
					
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura07', army, v ):ScaleEmitter(0.1) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura07', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.8, 0) )
					LOUDINSERT( self.unit.ChargeEffects03Bag, LOUDATTACHEMITTER( self.unit, 'ChargeAura07', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.8, 0) )
        		end
				
				ArtemisLaserGenerator.PlayFxRackSalvoChargeSequence(self, muzzle) 
			end,
			
			
			
			
			PlayFxRackSalvoReloadSequence = function(self)
                if self.unit.SpinManip then
                    self.unit.SpinManip:SetTargetSpeed(50)
                end
                if self.unit.SpinManip2 then
                    self.unit.SpinManip2:SetTargetSpeed(-50)
                end
				if self.unit.SpinManip3 then
                    self.unit.SpinManip3:SetTargetSpeed(50)
                end
				if self.unit.SpinManip4 then
                    self.unit.SpinManip4:SetTargetSpeed(-50)
                end
				if self.unit.SpinManip5 then
                    self.unit.SpinManip5:SetTargetSpeed(50)
                end
				if self.unit.SpinManip6 then
                    self.unit.SpinManip6:SetTargetSpeed(-50)
                end
				if self.unit.SpinManip7 then
                    self.unit.SpinManip7:SetTargetSpeed(50)
                end
				if self.unit.SpinManip8 then
                    self.unit.SpinManip8:SetTargetSpeed(-50)
                end
				if self.unit.SpinManip9 then
                    self.unit.SpinManip9:SetTargetSpeed(50)
                end
				if self.unit.ChargeEffects03Bag then
            	for k, v in self.unit.ChargeEffects03Bag do
                	v:Destroy()
            	end
		    	self.unit.ChargeEffects03Bag = {}
			end
                ArtemisLaserGenerator.PlayFxRackSalvoReloadSequence(self)
            end,
		},
        ArtemisCannon = Class(TDFMachineGunWeapon) {},
        --ArtemisCannon2 = Class(TDFMachineGunWeapon) {},
    },
	#
		SetParent = function(self, parent)
#
                self.Parent = parent
#
        end,
		--[[
	OnDamage = function(self, instigator, amount, vector, damagetype) 
    	if not self:IsDead() then
        	###Base script for this script function was developed by Gilbot_x
        	--local artemis_DLS = 0.08
        	--amount = math.ceil(amount*artemis_DLS)
			if not self:IsDead() then
				self:ForkThread(self.WeaponsThread)
			end
    	end
    	AAirUnit.OnDamage(self, instigator, amount, vector, damagetype) 
	end,
	]]--
    OnStopBeingBuilt = function(self)
        --ChangeState( self, self.OpenState )
		--self:SetWeaponEnabledByLabel('ArtemisCannon', false)
		--self:SetWeaponEnabledByLabel('ArtemisCannon2', false)
		self.ChargeEffects01Bag = {}
		self.ChargeEffects02Bag = {}
		self.ChargeEffects03Bag = {}
		AAirUnit.OnStopBeingBuilt(self) 
    end,
    
    
    OpenState = State() {
        Main = function(self)
            self.OpenAnim = CreateAnimator(self)
            WaitSeconds(6)
            
            self.OpenAnim:PlayAnim( '/mods/BlackOpsUnleashed/units/BAA0401/BAA0401_Aopen.sca' )
            
        end,
    },
	
	
	
	CreateDamageEffects = function(self, bone, army )
		
		local LOUDATTACHEMITTER = CreateAttachedEmitter
		
        for k, v in BlackOpsEffectTemplate.ArtemisDamageFireSmoke01 do
            LOUDATTACHEMITTER( self, bone, army, v ):ScaleEmitter(6)
        end
    end,
	
	CreateExplosionDebris = function( self, bone, army )
	
		local LOUDATTACHEMITTER = CreateAttachedEmitter
		
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            LOUDATTACHEMITTER( self, bone, army, v )--:OffsetEmitter( 0, 5, 0 )
        end
    end,

	
	OnKilled = function(self, instigator, type, overkillRatio)
        #LOG('*SINCE I JUST GOT MYSELF SHOT DOWN TELLING THE CARRIER TO MAKE ANOTHER DRONE')
            #
		if self.Parent then
			self.Parent:NotifyOfDroneDeath()
        end
		self.Trash:Destroy()
        self.Trash = TrashBag()
		self:ForkThread(self.DeathEffectsThread)
        AAirUnit.OnKilled(self, instigator, type, overkillRatio)        
    end,
	
	DeathEffectsThread = function(self)
		local army = self:GetArmy()
		local LOUDATTACHEMITTER = CreateAttachedEmitter

        # Create Initial explosion effects
        explosion.CreateFlash( self, 'BAA0401', 4.5, army )
        LOUDATTACHEMITTER(self, 'Turret', army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):OffsetEmitter( 0, 5, 0 )
        LOUDATTACHEMITTER(self,'Turret', army, '/effects/emitters/explosion_fire_sparks_02_emit.bp'):OffsetEmitter( 0, 5, 0 )
        LOUDATTACHEMITTER(self,'Turret', army, '/effects/emitters/distortion_ring_01_emit.bp')


        self:CreateExplosionDebris('DamageBone11', army )
        self:CreateExplosionDebris('Turret', army )
        self:CreateExplosionDebris('DamageBone01', army )

        --WaitSeconds(1)
        
        # Create damage effects on turret bone
        CreateDeathExplosion( self, 'DamageBone01', 1.5)
        
        self:CreateDamageEffects( 'DamageBone01', army )
		self:CreateDamageEffects( 'DamageBone02', army )
		self:CreateDamageEffects( 'DamageBone03', army )
		self:CreateDamageEffects( 'DamageBone04', army )
		WaitSeconds(0.8)
		self:CreateDamageEffects( 'DamageBone05', army )
		self:CreateDamageEffects( 'DamageBone06', army )
		self:CreateDamageEffects( 'DamageBone07', army )
		self:CreateDamageEffects( 'DamageBone08', army )
		WaitSeconds(0.8)
		self:CreateDamageEffects( 'DamageBone09', army )
		self:CreateDamageEffects( 'DamageBone10', army )
		self:CreateDamageEffects( 'DamageBone11', army )
		self:CreateDamageEffects( 'DamageBone12', army )
        
        CreateDeathExplosion( self, 'DamageBone01', 1)

        CreateDeathExplosion( self, 'DamageBone08', 1)
        WaitSeconds(0.8)
        CreateDeathExplosion( self, 'DamageBone05', 1)
        WaitSeconds(0.5)
        CreateDeathExplosion( self, 'DamageBone11', 1)
        WaitSeconds(0.4)
        CreateDeathExplosion( self, 'DamageBone03', 1)
        CreateDeathExplosion( self, 'DamageBone02', 2)
		CreateDeathExplosion( self, 'DamageBone12', 1)

        WaitSeconds(0.5)
    end,
	
	DeathThread = function(self)
        self:PlayUnitSound('Destroyed')

		local bp = self:GetBlueprint()

		WaitSeconds(0.4)
        CreateDeathExplosion( self, 'DamageBone03', 1)
		WaitSeconds(0.4)
        CreateDeathExplosion( self, 'DamageBone02', 2)
        WaitSeconds(0.2)
		CreateDeathExplosion( self, 'DamageBone08', 1)
		WaitSeconds(0.2)
        CreateDeathExplosion( self, 'DamageBone05', 1)
		LOG('waiting 0.5 seconds')
        WaitSeconds(0.5)

		CreateDeathExplosion( self, 'BAA0401', 5)
		self:PlayUnitSound('Destroyed')
        self:CreateWreckage(0.1)
        self:Destroy()
    end,
	
}

TypeClass = BAA0401