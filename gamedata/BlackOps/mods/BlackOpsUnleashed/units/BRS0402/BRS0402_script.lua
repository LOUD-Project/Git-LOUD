local CSeaUnit = import('/lua/cybranunits.lua').CSeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CybranWeaponsFile2 = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua')

local XCannonWeapon01 = CybranWeaponsFile2.XCannonWeapon01
local MGAALaserWeapon = CybranWeaponsFile2.MGAALaserWeapon

local CDFProtonCannonWeapon = CybranWeaponsFile.CDFProtonCannonWeapon
local CANNaniteTorpedoWeapon = CybranWeaponsFile.CANNaniteTorpedoWeapon
local CAMZapperWeapon = CybranWeaponsFile.CAMZapperWeapon
local CIFMissileLoaWeapon = CybranWeaponsFile.CIFMissileLoaWeapon

local CreateAttachedEmitter = CreateAttachedEmitter

BRS0402= Class(CSeaUnit) {

	MuzzleFlashEffects01 = {
		'/mods/BlackOpsUnleashed/effects/emitters/xcannon_cannon_muzzle_01_emit.bp',	-- large redish flash
		'/mods/BlackOpsUnleashed/effects/emitters/x_cannon_fire_test_01_emit.bp',		-- barrel lightning effect
		'/mods/BlackOpsUnleashed/effects/emitters/xcannon_cannon_muzzle_07_emit.bp',	-- small redish flash, double quick
		'/mods/BlackOpsUnleashed/effects/emitters/xcannon_cannon_muzzle_08_emit.bp',	-- small redish double flash
	},
	
	MuzzleFlashEffects02 = { '/effects/emitters/dirty_exhaust_sparks_02_emit.bp' },
	
	-- lightning
	MuzzleChargeEffects = {	'/mods/BlackOpsUnleashed/effects/emitters/x_cannon_charge_test_01_emit.bp' },
	
    Weapons = {
	
        MainCannon01 = Class(XCannonWeapon01) {
		
        	OnWeaponFired = function(self)
			
            	XCannonWeapon01.OnWeaponFired(self)
				
            	if self.unit.MuzzleFlashWep1Effects01Bag then
            		for k, v in self.unit.MuzzleFlashWep1Effects01Bag do
                		v:Destroy()
            		end
		    		self.unit.MuzzleFlashWep1Effects01Bag = {}
				end
				
        		for k, v in self.unit.MuzzleFlashEffects01 do
            		table.insert( self.unit.MuzzleFlashWep1Effects01Bag, CreateAttachedEmitter( self.unit, 'Left_Railgun_Muzzle', self.unit:GetArmy(), v ):ScaleEmitter(1.2))
        		end
        		
        		if self.unit.MuzzleFlashWep1Effects02Bag then
            		for k, v in self.unit.MuzzleFlashWep1Effects02Bag do
                		v:Destroy()
            		end
		    		self.unit.MuzzleFlashWep1Effects02Bag = {}
				end
				
        		for k, v in self.unit.MuzzleFlashEffects02 do
            		table.insert( self.unit.MuzzleFlashWep1Effects02Bag, CreateAttachedEmitter( self.unit, 'Left_Railgun_Effect03', self.unit:GetArmy(), v ):ScaleEmitter(0.5))
            		table.insert( self.unit.MuzzleFlashWep1Effects02Bag, CreateAttachedEmitter( self.unit, 'Left_Railgun_Effect04', self.unit:GetArmy(), v ):ScaleEmitter(0.5))
            		table.insert( self.unit.MuzzleFlashWep1Effects02Bag, CreateAttachedEmitter( self.unit, 'Left_Railgun_Effect05', self.unit:GetArmy(), v ):ScaleEmitter(0.5))
        		end
				
				self:ForkThread(self.MuzzleFlashEffectsWep1CleanUp)
				
			end,

			MuzzleFlashEffectsWep1CleanUp = function(self)
			
				WaitTicks(30)
				
				if self.unit.MuzzleFlashWep1Effects01Bag then
					for k, v in self.unit.MuzzleFlashWep1Effects01Bag do
						v:Destroy()
					end
					self.unit.MuzzleFlashWep1Effects01Bag = {}
				end
				
				if self.unit.MuzzleFlasWep1hEffects02Bag then
					for k, v in self.unit.MuzzleFlashWep1Effects02Bag do
						v:Destroy()
					end
					self.unit.MuzzleFlashWep1Effects02Bag = {}
				end
				
			end,
            
        	PlayFxRackSalvoChargeSequence = function(self, muzzle)
			
            	XCannonWeapon01.PlayFxRackSalvoChargeSequence(self, muzzle) 
				
            	local wep = self.unit:GetWeaponByLabel('MainCannon01')
				
            	local bp = wep:GetBlueprint()
				
        		if bp.Audio.RackSalvoCharge then
            		wep:PlaySound(bp.Audio.RackSalvoCharge)
        		end
				
            	if self.unit.MuzzleChargeEffectsWep1Bag then
				
            		for k, v in self.unit.MuzzleChargeEffectsWep1Bag do
                		v:Destroy()
            		end
					
		    		self.unit.MuzzleChargeEffectsWep1Bag = {}
					
				end
				
        		for k, v in self.unit.MuzzleChargeEffects do
				
            		table.insert( self.unit.MuzzleChargeEffectsWep1Bag, CreateAttachedEmitter( self.unit, 'Left_Railgun_Effect01', self.unit:GetArmy(), v ):ScaleEmitter(0.4):OffsetEmitter(0, 0, -0.9))
            		table.insert( self.unit.MuzzleChargeEffectsWep1Bag, CreateAttachedEmitter( self.unit, 'Left_Railgun_Effect02', self.unit:GetArmy(), v ):ScaleEmitter(0.4):OffsetEmitter(0, 0, -0.9))
					
        		end
				
        		self:ForkThread(self.MuzzleChargeEffectsWep1CleanUp)
				
        	end,
			
        	MuzzleChargeEffectsWep1CleanUp = function(self)
			
				WaitTicks(100)
				
				if self.unit.MuzzleChargeEffectsWep1Bag then
				
					for k, v in self.unit.MuzzleChargeEffectsWep1Bag do
						v:Destroy()
					end
					
					self.unit.MuzzleChargeEffectsWep1Bag = {}
					
				end
				
			end,
			
        },
		
        MainCannon02 = Class(XCannonWeapon01) {
		
        	OnWeaponFired = function(self)
			
            	XCannonWeapon01.OnWeaponFired(self)
				
            	if self.unit.MuzzleFlashWep2Effects01Bag then
            		for k, v in self.unit.MuzzleFlashWep2Effects01Bag do
                		v:Destroy()
            		end
		    		self.unit.MuzzleFlashWep2Effects01Bag = {}
				end
				
        		for k, v in self.unit.MuzzleFlashEffects01 do
            		table.insert( self.unit.MuzzleFlashWep2Effects01Bag, CreateAttachedEmitter( self.unit, 'Right_Railgun_Muzzle', self.unit:GetArmy(), v ):ScaleEmitter(1.2))
        		end
        		
        		if self.unit.MuzzleFlashWep2Effects02Bag then
            		for k, v in self.unit.MuzzleFlashWep2Effects02Bag do
                		v:Destroy()
            		end
		    		self.unit.MuzzleFlashWep2Effects02Bag = {}
				end
				
        		for k, v in self.unit.MuzzleFlashEffects02 do
            		table.insert( self.unit.MuzzleFlashWep2Effects02Bag, CreateAttachedEmitter( self.unit, 'Right_Railgun_Effect03', self.unit:GetArmy(), v ):ScaleEmitter(0.5))
            		table.insert( self.unit.MuzzleFlashWep2Effects02Bag, CreateAttachedEmitter( self.unit, 'Right_Railgun_Effect04', self.unit:GetArmy(), v ):ScaleEmitter(0.5))
            		table.insert( self.unit.MuzzleFlashWep2Effects02Bag, CreateAttachedEmitter( self.unit, 'Right_Railgun_Effect05', self.unit:GetArmy(), v ):ScaleEmitter(0.5))
        		end
				
				self:ForkThread(self.MuzzleFlashEffectsWep2CleanUp)
				
			end,

			MuzzleFlashEffectsWep2CleanUp = function(self)
			
				WaitTicks(30)
				
				if self.unit.MuzzleFlashWep2Effects01Bag then
				
					for k, v in self.unit.MuzzleFlashWep2Effects01Bag do
						v:Destroy()
					end
					
					self.unit.MuzzleFlashWep2Effects01Bag = {}
					
				end
				
				if self.unit.MuzzleFlashWep2Effects02Bag then
				
					for k, v in self.unit.MuzzleFlashWep2Effects02Bag do
						v:Destroy()
					end
					
					self.unit.MuzzleFlashWep2Effects02Bag = {}
					
				end
				
			end,
            
        	PlayFxRackSalvoChargeSequence = function(self, muzzle)
			
            	XCannonWeapon01.PlayFxRackSalvoChargeSequence(self, muzzle) 
				
            	local wep2 = self.unit:GetWeaponByLabel('MainCannon02')
				
            	local bp = wep2:GetBlueprint()
				
        		if bp.Audio.RackSalvoCharge then
            		wep2:PlaySound(bp.Audio.RackSalvoCharge)
        		end
				
            	if self.unit.MuzzleChargeEffectsWep2Bag then
				
            		for k, v in self.unit.MuzzleChargeEffectsWep2Bag do
                		v:Destroy()
            		end
					
		    		self.unit.MuzzleChargeEffectsWep2Bag = {}
					
				end
				
        		for k, v in self.unit.MuzzleChargeEffects do
				
            		table.insert( self.unit.MuzzleChargeEffectsWep2Bag, CreateAttachedEmitter( self.unit, 'Right_Railgun_Effect01', self.unit:GetArmy(), v ):ScaleEmitter(0.4):OffsetEmitter(0, 0, -0.9))
            		table.insert( self.unit.MuzzleChargeEffectsWep2Bag, CreateAttachedEmitter( self.unit, 'Right_Railgun_Effect02', self.unit:GetArmy(), v ):ScaleEmitter(0.4):OffsetEmitter(0, 0, -0.9))
					
        		end
				
        		self:ForkThread(self.MuzzleChargeEffectsWep2CleanUp)
				
        	end,
			
        	MuzzleChargeEffectsWep2CleanUp = function(self)
			
				WaitTicks(100)
				
				if self.unit.MuzzleChargeEffectsWep2Bag then
				
					for k, v in self.unit.MuzzleChargeEffectsWep2Bag do
						v:Destroy()
					end
					
					self.unit.MuzzleChargeEffectsWep2Bag = {}
					
				end
				
			end,
			
        },
		
        SecondaryCannon = Class(CDFProtonCannonWeapon) {},
		
        AntiMissile = Class(CAMZapperWeapon) {},
		
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
		
        AALaser = Class(MGAALaserWeapon) {},
		
        CruiseMissile = Class(CIFMissileLoaWeapon){},		
		
    },
	
    OnStopBeingBuilt = function(self,builder,layer)
	
        CSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.MuzzleFlashWep1Effects01Bag = {}
        self.MuzzleFlashWep1Effects02Bag = {}
        self.MuzzleFlashWep2Effects01Bag = {}
        self.MuzzleFlashWep2Effects02Bag = {}
        self.MuzzleChargeEffectsWep1Bag = {}
        self.MuzzleChargeEffectsWep2Bag = {}
		
    end,
}

TypeClass = BRS0402