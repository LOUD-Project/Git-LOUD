local EffectUtil = import('/lua/EffectUtilities.lua')

local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local TWeapons = import('/lua/terranweapons.lua')
local Weapons2 = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua')

local TIFCruiseMissileUnpackingLauncher = TWeapons.TIFCruiseMissileUnpackingLauncher
local TANTorpedoLandWeapon = TWeapons.TANTorpedoLandWeapon
local HawkGaussCannonWeapon = Weapons2.HawkGaussCannonWeapon
local TIFCommanderDeathWeapon = TWeapons.TIFCommanderDeathWeapon

local utilities = import('/lua/utilities.lua')
local RandomFloat = utilities.GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')
local explosion = import('/lua/defaultexplosions.lua')
local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone


XEL0401 = Class(TWalkingLandUnit) {

    Weapons = {
	
        Flamer = Class(HawkGaussCannonWeapon) {},
        Rockets = Class(TIFCruiseMissileUnpackingLauncher) {},
        Torpedoes = Class(TANTorpedoLandWeapon) {},
		CollossusDeath = Class(TIFCommanderDeathWeapon) {},
    },
    
    OnStartBeingBuilt = function(self, builder, layer)
	
        TWalkingLandUnit.OnStartBeingBuilt(self, builder, layer)
		
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
		
        self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationActivate, false):SetRate(0)
        self.HitsTaken = 0
    	self.DmgTotal = 0
		
    end,
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        if self.AnimationManipulator then
            self:SetUnSelectable(true)
            self.AnimationManipulator:SetRate(1)
            
            self:ForkThread(function()
                WaitSeconds(self.AnimationManipulator:GetAnimationDuration()*self.AnimationManipulator:GetRate())
                self:SetUnSelectable(false)
                self.AnimationManipulator:Destroy()
            end)
        end 
		
        self.HitsTaken = 0
    	self.DmgTotal = 0
		
    	### Globals uses for target assists and counter attacks
    	self.CurrentTarget = nil
    	self.OldTarget = nil
    	self.MyAttacker = nil
    	self.DroneTable = {}
    	self.Retaliation = false
        self:ForkThread(self.CreateDrone1) 
        self:ForkThread(self.CreateDrone2)      
    end,
    
    CreateDrone1 = function(self)
	
    	if not self:IsDead() then
		
    		local location = self:GetPosition('AttachSpecial02')
            local Drone1 = CreateUnitHPR('XEA0005', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
			
            Drone1:SetParent(self, 'XEL0401')
            Drone1:SetCreator(self)
            table.insert (self.DroneTable, Drone1)
            self.Trash:Add(Drone1)
            self:AssistHeartBeat() 
			
        end
		
    end,
    
    CreateDrone2 = function(self)
	
    	if not self:IsDead() then
		
    		local location = self:GetPosition('AttachSpecial01')
            local Drone2 = CreateUnitHPR('XEA0005', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
			
            Drone2:SetParent(self, 'XEL0401')
            Drone2:SetCreator(self)
            table.insert (self.DroneTable, Drone2)
            self.Trash:Add(Drone2)
            self:AssistHeartBeat() 
			
        end
		
    end,
    
    AssistHeartBeat = function(self)

        while not self.Dead do
        
            WaitSeconds(1)
            
            if not self.Dead and self.Retaliation == true and self.MyAttacker != nil then
            
                --- Clears flags if there is no longer a target to retaliate against thats in range
                if self.MyAttacker:IsDead() or self:GetDistanceToAttacker() >= 55 then
                    --- Clears flag to allow retaliation on another attacker
                    self.MyAttacker = nil
                    self.Retaliation = false
                end
				
            end
            
            if not self.Dead and self.Retaliation == false and table.getn({self.MyAttacker}) > 0 and self:GetDistanceToAttacker() < 55 then
            
                if not self.MyAttacker:IsDead() then
                    
                    --- Issues the retaliation command to each of the drones on the carriers table
                    if table.getn({self.DroneTable}) > 0 then
					
                        for k, v in self.DroneTable do
                            IssueClearCommands({self.DroneTable[k]})
                            IssueAttack({self.DroneTable[k]}, self.MyAttacker)
                        end
						
                        --- Performs retaliation flag
                        self.Retaliation = true         
                    end
					
                end
                
            elseif not self.Dead and self.Retaliation == false and self:GetTargetEntity() then
            
                --- Updates variable with latest targeting info
                self.CurrentTarget = self:GetTargetEntity()
                
                --- Verifies that the carrier is not dead and that it has a target
                --- Ensures that either there hasnt been a target before or that its new
                --- To prevent the same retargeting command from being given out multible times
                
                if self.OldTarget == nil or self.OldTarget != self.CurrentTarget then
                
                    --- Updates the OldTarget to match CurrentTarget
                    self.OldTarget = self.CurrentTarget       
                    
                    --- Issues the attack command to each of the drones on the carriers table
                    if table.getn({self.DroneTable}) > 0 then
					
                        for k, v in self.DroneTable do
                            IssueClearCommands({self.DroneTable[k]})
                            IssueAttack({self.DroneTable[k]}, self.CurrentTarget)
                        end
						
                    end
					
                end
				
            end
			
        end
		
    end,

GetDistanceToAttacker = function(self)

    local tpos = self.MyAttacker:GetPosition()
    local mpos = self:GetPosition()
    local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
    return dist
	
end,

OnDamage = function(self, instigator, amount, vector, damagetype)

    ### Check to make sure that the carrier isnt already dead and what just damaged it is a unit we can attack
    if self:IsDead() == false and damagetype == 'Normal' and self.MyAttacker == nil then
        ### only attack if retaliation not already active
        if IsUnit(instigator) then
            self.MyAttacker = instigator
        end
    end
	
    TWalkingLandUnit.OnDamage(self, instigator, amount, vector, damagetype)
	
end, 

    DestructionEffectBones = {
        'L_Flame_Muzzle','R_Flame_Muzzle','L_Arm_B01',
        'L_Arm_B02','R_Arm_B01', 
        'R_Arm_B02','Torso','R_Missile_Muzzle01',
        'R_Missile_Muzzle02','R_Missile_Muzzle03','R_Missile_Muzzle04','R_Missile_Muzzle05',
        'L_Missile_Muzzle01','L_Missile_Muzzle02','L_Missile_Muzzle03','L_Missile_Muzzle04',
        'L_Missile_Muzzle05','R_Leg_B01','R_Leg_B01',
    },
    
    
    CreateDamageEffects = function(self, bone, Army )
        for k, v in EffectTemplate.CEMPGrenadeHit01 do   
            CreateAttachedEmitter( self, bone, Army, v ):ScaleEmitter(1.0)
        end
    end,

    CreateExplosionDebris = function( self, bone, Army )
        for k, v in EffectTemplate.ExplosionEffectsSml01 do
            CreateAttachedEmitter( self, bone, Army, v ):ScaleEmitter(1.5)
        end
    end,
    
    CreateFirePlumes = function( self, Army, bones, yBoneOffset )
        ### Fire plume effects
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            local position = self:GetPosition(vBone)
            local offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition ) 
            velocity.x = velocity.x + utilities.GetRandomFloat(-0.45, 0.45)
            velocity.z = velocity.z + utilities.GetRandomFloat(-0.45, 0.45)
            velocity.y = velocity.y + utilities.GetRandomFloat( 0.0, 0.45)
            local proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, 1)):SetVelocity(utilities.GetRandomFloat(1, 2)):SetCollision(false)
            local emitter = CreateEmitterOnEntity(proj, Army, '/effects/emitters/destruction_explosion_fire_plume_01_emit.bp')
            local lifetime = utilities.GetRandomFloat( 10, 30 )
        end
    end,

    CreateAmmoCookOff = function( self, Army, bones, yBoneOffset )
        ### Fire plume effects
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            local position = self:GetPosition(vBone)
            local offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition ) 
            velocity.x = velocity.x + utilities.GetRandomFloat(-0.45, 0.45)
            velocity.z = velocity.z + utilities.GetRandomFloat(-0.45, 0.45)
            velocity.y = velocity.y + utilities.GetRandomFloat( 0.0, 0.65)

            ### Ammo Cookoff projectiles and damage
            self.DamageData = {
                BallisticArc = 'RULEUBA_LowArc',
                UseGravity = true, 
                CollideFriendly = true, 
                DamageFriendly = true, 
                Damage = 25,
            	DamageRadius = 3,
            	DoTPulses = 15,
            	DoTTime = 2.5, 
                DamageType = 'Normal',
                } 
            ammocookoff = self:CreateProjectile('/mods/BlackOpsUnleashed/projectiles/NapalmProjectile01/Napalm01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            ### SetVelocity controls how far away the ammo will be thrown
            ammocookoff:SetVelocity(Random(2,5))  
            ammocookoff:SetLifetime(20) 
            ammocookoff:PassDamageData(self.DamageData)
            self.Trash:Add(ammocookoff)
        end
    end,
	
    CreateSCUEffects = function(self, bone, army )
        #CreateEmitterAtEntity(self, self:GetArmy(),  '/effects/emitters/aeon_commander_overcharge_hit_01_emit.bp')
        #CreateEmitterAtEntity(self, self:GetArmy(),  '/effects/Entities/SCUDeath01/SCUDeath01_proj.bp')#the game wont spawn this for some reason?
        local sides = 1
        local angle = (1*math.pi) / sides
        local velocity = 2
        local OffsetMod = 1
        local projectiles = {}

        for i = 0, (sides-1) do
            local X = math.sin(i*angle)
            local Z = math.cos(i*angle)
            local proj =  self:CreateProjectile('/effects/Entities/SCUDeath01/SCUDeath01_proj.bp', X * OffsetMod , 2, Z * OffsetMod, X, 0, Z)
                :SetVelocity(velocity)
            table.insert( projectiles, proj )
        end  
    end,
    
    
    DeathThread = function( self, overkillRatio , instigator)
    
    	local position = self:GetPosition()
        local numExplosions =  math.floor( table.getn( self.DestructionEffectBones ) * Random(0.4, 1.0))
        self:PlayUnitSound('Destroyed')
        # Create small explosions effects all over
        local ranBone = utilities.GetRandomInt( 1, numExplosions )
        if table.getn({self.DroneTable}) > 0 then
        	for k, v in self.DroneTable do
            	IssueClearCommands({self.DroneTable[k]})
            	IssueKillSelf({self.DroneTable[k]})
        	end
    	end 
        explosion.CreateDefaultHitExplosionAtBone( self, 'Torso', 4.0 )
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()})           
        WaitSeconds(2)
        explosion.CreateDefaultHitExplosionAtBone( self, 'R_Leg_B02', 1.0 )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        WaitSeconds(0.1)
        explosion.CreateDefaultHitExplosionAtBone( self, 'R_Leg_B01', 1.0 )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        WaitSeconds(0.1)
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        WaitSeconds(1)
        explosion.CreateDefaultHitExplosionAtBone( self, 'L_Arm_B02', 1.0 )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        WaitSeconds(0.3)
        explosion.CreateDefaultHitExplosionAtBone( self, 'R_Arm_B01', 1.0 )
        explosion.CreateDefaultHitExplosionAtBone( self, 'R_Leg_B01', 1.0 )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        WaitSeconds(0.1)
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )

        WaitSeconds(0.5)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Torso', 5.0 )  
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        WaitSeconds(0.3)
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )  
        
        WaitSeconds(0.3)
        explosion.CreateDefaultHitExplosionAtBone( self, 'R_Arm_B02', 1.0 )
        explosion.CreateDefaultHitExplosionAtBone( self, 'R_Leg_B03', 1.0 ) 
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        
        WaitSeconds(1)
        explosion.CreateDefaultHitExplosionAtBone( self, 'R_Missile_Muzzle01', 1.0 )
        explosion.CreateDefaultHitExplosionAtBone( self, 'R_Missile_Muzzle04', 1.0 )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        WaitSeconds(0.1)
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        
        WaitSeconds(0.3)
        explosion.CreateDefaultHitExplosionAtBone( self, 'R_Missile_Muzzle02', 1.0 )
        explosion.CreateDefaultHitExplosionAtBone( self, 'L_Missile_Muzzle05', 1.0 )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
        WaitSeconds(0.1)
        self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
           
		--[[
        if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
    	]]--
        WaitSeconds(2)#this is just here for testing purposes, once i get the desired explosion this gets taken out
		
        explosion.CreateDefaultHitExplosionAtBone( self, 'Torso', 5.0 )   
		
        local bp = self:GetBlueprint()
        local army = self:GetArmy()
		
        for i, numWeapons in bp.Weapon do
            if(bp.Weapon[i].Label == 'CollossusDeath') then
            	#self:CreateSCUEffects( 'Torso', army )# spawns the final explsoion and does the final area damage
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end

        self:ShakeCamera(3, 2, 0, 0.15)
		
        self:DestroyAllDamageEffects()
        self:CreateWreckage( overkillRatio )

        # CURRENTLY DISABLED UNTIL DESTRUCTION
        # Create destruction debris out of the mesh, currently these projectiles look like crap,
        # since projectile rotation and terrain collision doesn't work that great. These are left in
        # hopes that this will look better in the future.. =)
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

        self:PlayUnitSound('Destroyed2')
        self:Destroy()
		
    end,
    
}

TypeClass = XEL0401