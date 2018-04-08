
local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit
local Weapon = import('/lua/sim/Weapon.lua').Weapon
local cWeapons = import('/lua/cybranweapons.lua')
local CybranWeaponsFile2 = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua')
local CDFLaserHeavyWeapon = cWeapons.CDFLaserHeavyWeapon
local BassieCannonWeapon01 = CybranWeaponsFile2.BassieCannonWeapon01
local BasiliskAAMissile01 = CybranWeaponsFile2.BasiliskAAMissile01
local CAANanoDartWeapon = cWeapons.CAANanoDartWeapon

local CDFLaserDisintegratorWeapon = cWeapons.CDFLaserDisintegratorWeapon01
local CIFCommanderDeathWeapon = cWeapons.CIFCommanderDeathWeapon
local CIFMissileLoaWeapon = import('/lua/cybranweapons.lua').CIFMissileLoaWeapon
local CDFElectronBolterWeapon = cWeapons.CDFElectronBolterWeapon

local BasiliskNukeEffect04 = '/mods/BlackOpsUnleashed/projectiles/MGQAIPlasmaArty01/MGQAIPlasmaArty01_proj.bp' 
local BasiliskNukeEffect05 = '/mods/BlackOpsUnleashed/effects/Entities/BasiliskNukeEffect05/BasiliskNukeEffect05_proj.bp'

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local RandomInt = import('/lua/utilities.lua').GetRandomInt
local Util = import('/lua/utilities.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlacOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')
local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone
local Entity = import('/lua/sim/Entity.lua').Entity

local CreateRotator = CreateRotator

BRL0401 = Class(CWalkingLandUnit) 
{
    PlayEndAnimDestructionEffects = false,

    Weapons = {
		BasiliskDeathNuck = Class(CIFCommanderDeathWeapon) {},
		TorsoWeapon = Class(CDFLaserHeavyWeapon){},
    	HeadWeapon = Class(CDFLaserHeavyWeapon)
        {
            OnWeaponFired = function(self, muzzle)
                #CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
                if not self.JawTopRotator then 
                    self.JawBottomRotator = CreateRotator(self.unit, 'Jaw', 'x')
                    
                    self.unit.Trash:Add(self.JawBottomRotator)
                end
                
                self.JawBottomRotator:SetGoal(30):SetSpeed(100)
                
                CDFLaserHeavyWeapon.OnWeaponFired(self, muzzle)
                
                self:ForkThread(function()
                    WaitSeconds(3)
                    
                    self.JawBottomRotator:SetGoal(0):SetSpeed(50)
                end)
            end,
        },
		SideCannons = Class(CDFLaserHeavyWeapon) {},
        MainGun = Class(BassieCannonWeapon01) {},
        MissileRack = Class(CIFMissileLoaWeapon) {},
		RightBolter = Class(CDFElectronBolterWeapon) {},
		LeftBolter = Class(CDFElectronBolterWeapon) {},
		LasMissile01 = Class(BasiliskAAMissile01) {},
		--LasMissile02 = Class(CAANanoDartWeapon) {},
		--LasMissile03 = Class(CAANanoDartWeapon) {},
		--LasMissile04 = Class(CAANanoDartWeapon) {},
		--LasMissile05 = Class(CAANanoDartWeapon) {},
		--LasMissile06 = Class(CAANanoDartWeapon) {},
		--Siege weapons
		ShoulderGuns = Class(CDFLaserDisintegratorWeapon) {},
		MissileRack2 = Class(CIFMissileLoaWeapon) {},
		
    },
    
    OnCreate = function(self,builder,layer)
        CWalkingLandUnit.OnCreate(self,builder,layer)
		self:SetWeaponEnabledByLabel('ShoulderGuns', false)
		local shoulderwep = self:GetWeaponByLabel('ShoulderGuns')
		shoulderwep:ChangeMaxRadius(0)
		self:SetWeaponEnabledByLabel('MissileRack2', false)
		local missilewep = self:GetWeaponByLabel('MissileRack2')
		missilewep:ChangeMaxRadius(0)
   end,
    
	
   	OnStartBeingBuilt = function(self, builder, layer)
        CWalkingLandUnit.OnStartBeingBuilt(self, builder, layer)
        --if not self.AnimationManipulator then
        --    self.AnimationManipulator = CreateAnimator(self)
        --    self.Trash:Add(self.AnimationManipulator)
        --end
        --self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationActivate, false):SetRate(0)
    end,
    
    OnStopBeingBuilt = function(self,builder,layer)
    	--if self.AnimationManipulator then
        --    self:SetUnSelectable(true)
        --    self.AnimationManipulator:SetRate(1)
            
        --    self:ForkThread(function()
        --        WaitSeconds(self.AnimationManipulator:GetAnimationDuration()*self.AnimationManipulator:GetRate())
        --        self:SetUnSelectable(false)
        --        self.AnimationManipulator:Destroy()
        --    end)
        --end  
        
		self.Rotator1 = CreateRotator(self, 'Jaw', 'x')
        self.Rotator2 = CreateRotator(self, 'Head', 'x')
        self.Rotator3 = CreateRotator(self, 'Head', 'y')
        self.Trash:Add(self.Rotator1)
        if self.Rotator1 then
            self.Rotator1:SetGoal(30):SetSpeed(100)
        end
        self:ForkThread(function()
        	WaitSeconds(3)
                    
        	self.Rotator1:SetGoal(0):SetSpeed(50)
        end)
        if self.Rotator2 then
            self.Rotator2:SetGoal(-40):SetSpeed(100)
        end
        self:ForkThread(function()
        	WaitSeconds(2)
                    
        	self.Rotator2:SetGoal(0):SetSpeed(50)
        end)
        if self.Rotator3 then
            self.Rotator3:SetGoal(-30):SetSpeed(100)
        end
        self:ForkThread(function()
        	WaitSeconds(1)
                    
        	self.Rotator3:SetGoal(30):SetSpeed(100)
        	WaitSeconds(1)
        	self.Rotator3:SetGoal(0):SetSpeed(50)
        end)    
		
		--if not self.AnimationManipulator then
		--	self.AnimationManipulator = CreateAnimator(self)
		--	self.Trash:Add(self.AnimationManipulator)
		--end
		CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
    end,
    
    
	OnScriptBitSet = function(self, bit)
        CWalkingLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
			if not self.AnimationManipulator then
				self.AnimationManipulator = CreateAnimator(self)
				self.Trash:Add(self.AnimationManipulator)
				self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationDeploy)
			end
			self.AnimationManipulator:SetRate(1.5)
			
			self:ForkThread(function()
				self:SetSpeedMult(0.5)
				self:RemoveToggleCap('RULEUTC_WeaponToggle')
				--weapon stuff
				self:SetWeaponEnabledByLabel('SideCannons', false)
				local sidewep = self:GetWeaponByLabel('SideCannons')
				sidewep:ChangeMaxRadius(0)
		
				self:SetWeaponEnabledByLabel('MainGun', false)
				local MainWep = self:GetWeaponByLabel('MainGun')
				MainWep:ChangeMaxRadius(0)
		
				self:SetWeaponEnabledByLabel('MissileRack', false)
				local shortMissWep = self:GetWeaponByLabel('MissileRack')
				shortMissWep:ChangeMaxRadius(0)
				shortMissWep:ChangeMinRadius(20)
				LOG('Side and Main gun disabled')
				--range on Torso Dummy weapon
				local dummywep = self:GetWeaponByLabel('TorsoWeapon')
				local maxradius, minradius
				local wep = self:GetWeaponByLabel('ShoulderGuns')
				maxradius = wep:GetBlueprint().MaxRadius
				minradius = wep:GetBlueprint().MinRadius or 0
				dummywep:ChangeMaxRadius(maxradius)
				dummywep:ChangeMinRadius(minradius)
                WaitSeconds(self.AnimationManipulator:GetAnimationDuration() + 2)
				--local durTime = self.AnimationManipulator:GetAnimationDuration()
				--LOG( durTime,'************Animation Duration**********')
				self:SetWeaponEnabledByLabel('ShoulderGuns', true)
				local shoulderwep = self:GetWeaponByLabel('ShoulderGuns')
				shoulderwep:ChangeMaxRadius(180)
				shoulderwep:ChangeMinRadius(20)
		
				self:SetWeaponEnabledByLabel('MissileRack2', true)
				local missilewep = self:GetWeaponByLabel('MissileRack2')
				missilewep:ChangeMaxRadius(180)
				missilewep:ChangeMinRadius(20)
				LOG('Arty Weapon enabled')
				self:AddToggleCap('RULEUTC_WeaponToggle')
            end)
    	end
    end,
	
	
	OnScriptBitClear = function(self, bit)
        CWalkingLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
			if self.AnimationManipulator then
				self.AnimationManipulator:SetRate(-1.5)
			end
			self:ForkThread(function()
				self:SetSpeedMult(1.0)
				self:RemoveToggleCap('RULEUTC_WeaponToggle')
				self:SetWeaponEnabledByLabel('ShoulderGuns', false)
				local shoulderwep = self:GetWeaponByLabel('ShoulderGuns')
				shoulderwep:ChangeMaxRadius(0)
				shoulderwep:ChangeMinRadius(0)
				self:SetWeaponEnabledByLabel('MissileRack2', false)
				local missilewep = self:GetWeaponByLabel('MissileRack2')
				missilewep:ChangeMaxRadius(0)
				missilewep:ChangeMinRadius(0)
				LOG('Arty gun disabled')
				--range on torso dummy weapon
				local dummywep = self:GetWeaponByLabel('TorsoWeapon')
				local maxradius, minradius
				local wep = self:GetWeaponByLabel('MainGun')
				maxradius = wep:GetBlueprint().MaxRadius
				minradius = wep:GetBlueprint().MinRadius or 0
				dummywep:ChangeMaxRadius(maxradius)
				dummywep:ChangeMinRadius(minradius)
                WaitSeconds(self.AnimationManipulator:GetAnimationDuration())
				self:SetWeaponEnabledByLabel('SideCannons', true)
				local sidewep = self:GetWeaponByLabel('SideCannons')
				sidewep:ChangeMaxRadius(60)
				sidewep:ChangeMinRadius(0)
		
				self:SetWeaponEnabledByLabel('MainGun', true)
				local MainWep = self:GetWeaponByLabel('MainGun')
				MainWep:ChangeMaxRadius(60)
				MainWep:ChangeMinRadius(0)
		
				self:SetWeaponEnabledByLabel('MissileRack', true)
				local shortMissWep = self:GetWeaponByLabel('MissileRack')
				shortMissWep:ChangeMaxRadius(80)
				shortMissWep:ChangeMinRadius(10)
				LOG('Mobile Weapons enabled')
				self:AddToggleCap('RULEUTC_WeaponToggle')
				
            end)
    	end
    end,
	
    CreateDeathExplosionDustRing = function( self )
        local blanketSides = 18
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 2.8

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)

            local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 1.5, blanketZ + 4, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end        
    end,
	
	CreateLightning = function(self)
		#LOG('inner plasma')
        local vx, vy, vz = self:GetVelocity()
        local num_projectiles = 20        
        local horizontal_angle = (2*math.pi) / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, zVec
        local offsetMultiple = 5
        local px, pz

		--WaitSeconds( 10 )
        for i = 0, (num_projectiles -1) do            
            xVec = (math.sin(angleInitial + (i*horizontal_angle)))
            zVec = (math.cos(angleInitial + (i*horizontal_angle)))
            px = 0--(offsetMultiple*xVec)
            pz = 0--(offsetMultiple*zVec)
            
            local proj = self:CreateProjectile( BasiliskNukeEffect05, px, 2, pz, xVec, 0, zVec )
            proj:SetLifetime(2.0)
            proj:SetVelocity(12.0)
            proj:SetAcceleration(-0.9)            
        end
	end,
	
	CreateFireBalls = function(self)
		local num_projectiles = 2        
        local horizontal_angle = (2*math.pi) / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, yVec, zVec
        local angleVariation = 0.1        
        local px, pz       
		local py = 2
		
        for i = 0, (num_projectiles -1) do            
            xVec = math.sin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            yVec = RandomFloat( 0.5, 1.7 ) + 1.2
            zVec = math.cos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            px = RandomFloat( 0.5, 1.0 ) * xVec
           -- py = RandomFloat( 0.5, 1.0 ) * yVec
            pz = RandomFloat( 0.5, 1.0 ) * zVec
            
            local proj = self:CreateProjectile( BasiliskNukeEffect04, px, py, pz, xVec, yVec, zVec )
            proj:SetVelocity(RandomFloat( 10, 20  ))
            proj:SetBallisticAcceleration(-9.8)            
        end        
	end,
	
	CreateHeadConvectionSpinners = function(self)
        local sides = 8
        local angle = (2*math.pi) / sides
        local HeightOffset = 0
        local velocity = 1
        local OffsetMod = 10
        local projectiles = {}        

        for i = 0, (sides-1) do
            local x = math.sin(i*angle) * OffsetMod
            local z = math.cos(i*angle) * OffsetMod
            local proj = self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/BasiliskNukeEffect03/BasiliskNukeEffect03_proj.bp', x, HeightOffset, z, x, 0, z)
                :SetVelocity(velocity)
            table.insert(projectiles, proj)
        end   
    
    WaitSeconds(1)
        for i = 0, (sides-1) do
            local x = math.sin(i*angle)
            local z = math.cos(i*angle)
            local proj = projectiles[i+1]
		proj:SetVelocityAlign(false)
		proj:SetOrientation(OrientFromDir(Util.Cross( Vector(x,0,z), Vector(0,1,0))),true)
		proj:SetVelocity(0,3,0) 
          proj:SetBallisticAcceleration(-0.05)            
        end   
    end,
	
    CreateDamageEffects = function(self, bone, army )
        for k, v in EffectTemplate.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(5)
        end
    end,
	
	CreateBlueFireDamageEffects = function(self, bone, army )
        for k, v in BlacOpsEffectTemplate.DamageBlueFire do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(3)
        end
    end,
	
    DeathThread = function(self)
    	#if not self.Station01:IsDead() then
		#	self.Station01:Kill()
		#end
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()
        local position = self:GetPosition()

        --Start off with a single Large explosion and several small ones
		CreateDeathExplosion( self, 'BRL0401', 6)
        CreateAttachedEmitter(self, 'BRL0401', army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):OffsetEmitter( 0, 0, 0 )
		self:ShakeCamera(20, 2, 1, 1.5)
		WaitSeconds(1)
		CreateDeathExplosion( self, 'Torso', 1.5)
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Right_Side_Cannon_Arm', 1)
		WaitSeconds(0.5)
		CreateDeathExplosion( self, 'Left_Side_Cannon_Arm', 1)
		WaitSeconds(1)
		
		--As the basilisk falls to the ground more small explosions + blue leaking fire effects and regular fire effects
		CreateDeathExplosion( self, 'MainGun_Turret', 1)
		self:CreateBlueFireDamageEffects( 'MainGun_Turret', army )--leaking blue fire
		--explosions on right leg
		WaitSeconds(1.5)
		CreateDeathExplosion( self, 'Right_Leg_3', 1)
		self:CreateDamageEffects( 'Right_Piston_1B', army )
		CreateDeathExplosion( self, 'Right_Piston_3A', 1)
		self:CreateDamageEffects( 'Right_Cannon', army )
		CreateDeathExplosion( self, 'Right_Leg_1', 1)
		self:CreateDamageEffects( 'Right_Leg_2', army )
		WaitSeconds(0.1)
		CreateDeathExplosion( self, 'Right_Bolter', 1)
		self:CreateDamageEffects( 'Right_Bolter', army )
		CreateDeathExplosion( self, 'Right_Cannon', 1)
		self:CreateDamageEffects( 'Right_Cannon', army )
		WaitSeconds(0.5)
		CreateDeathExplosion( self, 'MainGun_Muzzle_Left', 1)
		self:CreateBlueFireDamageEffects( 'Missile_7', army )--leaking blue fire
		WaitSeconds(0.4)
		CreateDeathExplosion( self, 'Left_Top_Cannon_Support', 1)
		self:CreateDamageEffects( 'Left_Top_Cannon_Support', army )
		WaitSeconds(0.8)
		CreateDeathExplosion( self, 'Right_Leg_2', 1)
		self:CreateDamageEffects( 'Right_Leg_2', army )
		WaitSeconds(1)
		CreateDeathExplosion( self, 'AA_Missile_3', 1)
		self:CreateBlueFireDamageEffects( 'AA_Missile_3', army )--leaking blue fire
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Left_Cannon_Muzzle_1', 0.5)
		self:CreateBlueFireDamageEffects( 'Left_Cannon_Muzzle_1', army )
		CreateDeathExplosion( self, 'Left_Cannon_Recoil_2', 0.5)
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'MainGun_Muzzle_Right', 1)
		WaitSeconds(0.6)
		CreateDeathExplosion( self, 'Right_Bolter_Muzzle_3', 1)
		CreateDeathExplosion( self, 'Missile_7', 3)
		WaitSeconds(0.5)
		--Knee hits the ground
		--self:ShakeCamera(40, 4, 1, 3.8)
		CreateDeathExplosion( self, 'Head', 1)
		self:CreateDeathExplosionDustRing( self, 'Right_Kneepad', 1)
       self:PlayUnitSound('DoneBeingBuilt')
	   WaitSeconds(1)
		
		--Final Roar and then nuke explosion
		CreateDeathExplosion( self, 'Head', 3)
		self:CreateBlueFireDamageEffects( 'Head', army )--leaking blue fire
		
		
		self:CreateLightning()
		WaitSeconds(2)
		
        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        -- Knockdown force rings
        DamageRing(self, position, 0.1, 18, 1, 'Force', true)
        WaitSeconds(0.8)
        DamageRing(self, position, 0.1, 18, 1, 'Force', true)
		
        -- Create initial fireball dome effect
		CreateLightParticle(self, -1, self:GetArmy(), 50, 100, 'beam_white_01', 'ramp_blue_16')
		self:PlayUnitSound('NukeExplosion')
        local FireballDomeYOffset = -7
        self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/BasiliskNukeEffect01/BasiliskNukeEffect01_proj.bp',0,FireballDomeYOffset,0,0,0,1)
        
		local bp = self:GetBlueprint()
        for i, numWeapons in bp.Weapon do
            if(bp.Weapon[i].Label == 'BasiliskDeathNuck') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end
		WaitSeconds( 1 )
		WaitSeconds(0.1)
		self:CreateFireBalls()
		WaitSeconds(0.1)
		self:CreateFireBalls()
		WaitSeconds(0.5)
		self:CreateFireBalls()
		WaitSeconds(0.2)
		self:CreateFireBalls()
		WaitSeconds(0.5)
		self:CreateFireBalls()
		WaitSeconds(0.5)
		
		local army = self:GetArmy()
        CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), 'nuke_scorch_001_albedo', '', 'Albedo', 30, 30, 125, 0, army)
		
		self:CreateHeadConvectionSpinners()
        
        self:CreateWreckage(0.1)
        self:Destroy()
    end,
	

	
}

TypeClass = BRL0401