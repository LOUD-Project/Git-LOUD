local SShieldStructureUnit = import('/lua/seraphimunits.lua').SShieldStructureUnit
local WeaponsFile = import ('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua')
local LambdaWeapon = WeaponsFile.LambdaWeapon
local SSeraphimSubCommanderGateway01 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway01
local SSeraphimSubCommanderGateway02 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway02
local SSeraphimSubCommanderGateway03 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway03

local explosion = import('/lua/defaultexplosions.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BSB0405 = Class(SShieldStructureUnit) {

	SpawnEffects = {
		'/effects/emitters/seraphim_othuy_spawn_01_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_02_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_03_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_04_emit.bp',
	},
	
    LambdaEffects = {
        '/effects/emitters/seraphim_t3power_ambient_01_emit.bp',
        '/effects/emitters/seraphim_t3power_ambient_02_emit.bp',
        '/effects/emitters/seraphim_t3power_ambient_04_emit.bp',
    },
	
    Weapons = {
        Eye = Class(LambdaWeapon) {},
    },
    
    OnStopBeingBuilt = function(self, builder, layer)
    
        local army = self:GetArmy()
        
        for k, v in SSeraphimSubCommanderGateway01 do
            CreateAttachedEmitter(self, 'Light04', army, v):ScaleEmitter(0.5)
			CreateAttachedEmitter(self, 'Light05', army, v):ScaleEmitter(0.5)
			CreateAttachedEmitter(self, 'Light06', army, v):ScaleEmitter(0.5)
        end
		
        for k, v in SSeraphimSubCommanderGateway02 do
            CreateAttachedEmitter(self, 'Light01', army, v):ScaleEmitter(0.2)
            CreateAttachedEmitter(self, 'Light02', army, v):ScaleEmitter(0.2)
            CreateAttachedEmitter(self, 'Light03', army, v):ScaleEmitter(0.2)
		end
		
		for k, v in SSeraphimSubCommanderGateway03 do
			CreateAttachedEmitter(self, 'TargetBone03', army, v):ScaleEmitter(0.7)
        end
		
        SShieldStructureUnit.OnStopBeingBuilt(self, builder, layer)
		
        self.Rotator1 = CreateRotator(self, 'Spinner', 'y', nil, 10, 5, 0)
		
        self.Trash:Add(self.Rotator1)
        self.lambdaEmitterTable = {}
        self.LambdaEffectsBag = {}
		
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:ForkThread(self.ResourceThread)
    end,
    
    OnScriptBitSet = function(self, bit)
	
        SShieldStructureUnit.OnScriptBitSet(self, bit)
        
        local army =  self:GetArmy()
        
        if bit == 0 then 
            self:SetMaintenanceConsumptionActive()
            self:ForkThread(self.LambdaEmitter)
    	end
		
    	if self.Rotator1 then
            self.Rotator1:SetTargetSpeed(40)
        end
		
        if self.LambdaEffectsBag then
            for k, v in self.LambdaEffectsBag do
                v:Destroy()
            end
		    self.LambdaEffectsBag = {}
		end
		
        for k, v in self.LambdaEffects do
            table.insert( self.LambdaEffectsBag, CreateAttachedEmitter( self, 0, army, v ):ScaleEmitter(0.8) )
        end
    end,
    
    OnScriptBitClear = function(self, bit)
	
        SShieldStructureUnit.OnScriptBitClear(self, bit)
		
        if bit == 0 then 
            self.Rotator1:SetTargetSpeed(0)
            self:ForkThread(self.KillLambdaEmitter)
            self:SetMaintenanceConsumptionInactive()
    	end
		
		if self.LambdaEffectsBag then
            for k, v in self.LambdaEffectsBag do
                v:Destroy()
            end
		    self.LambdaEffectsBag = {}
		end
    end,
    
	LambdaEmitter = function(self)

		if not self.Dead then
		
			WaitTicks(5)
			
			if not self.Dead then
				-- Get the platforms current orientation
				local platOrient = self:GetOrientation()
            
				-- Get the position of the platform
				local location = self:GetPosition('Spinner')

				-- Creates lambdaEmitter over the platform with a ranomly generated Orientation
				local lambdaEmitter = CreateUnit('bsb0001', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

				-- Adds the created lambdaEmitter to the parent platforms lambdaEmitter table
				table.insert (self.lambdaEmitterTable, lambdaEmitter)

				-- Sets the platform as the lambdaEmitter parent
				lambdaEmitter:SetParent(self, 'bsb0405')
				lambdaEmitter:SetCreator(self)
				
				-- lambdaEmitter clean up scripts
				self.Trash:Add(lambdaEmitter)
			end
		end 
	end,
    
    DeathThread = function( self, overkillRatio , instigator)
	
		if self.Rotator1 then
			self.Rotator1:SetTargetSpeed(0)
		end

        local bigExplosionBones = {'Spinner', 'Eye01', 'Eye02'}
        local explosionBones = {'XSB0405', 'Light01',
                                'Light02', 'Light03',
                                'Light04', 'Light05', 'Light06',
                                }
                                        
        explosion.CreateDefaultHitExplosionAtBone( self, bigExplosionBones[Random(1,3)], 4.0 )
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()}) 
		
        WaitTicks(15)
        
        local RandBoneIter = RandomIter(explosionBones)
		
        for i=1,Random(4,6) do
            local bone = RandBoneIter()
            explosion.CreateDefaultHitExplosionAtBone( self, bone, 1.0 )
            WaitTicks(Random(1,3))
        end
        
        local bp = self:GetBlueprint()
		
        for i, numWeapons in bp.Weapon do
            if(bp.Weapon[i].Label == 'CollossusDeath') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end
		
        WaitTicks(35)
		
        explosion.CreateDefaultHitExplosionAtBone( self, 'Spinner', 5.0 )        

        if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end

        self:DestroyAllDamageEffects()
        self:CreateWreckage( overkillRatio )

        # CURRENTLY DISABLED UNTIL DESTRUCTION
        # Create destruction debris out of the mesh, currently these projectiles look like crap,
        # since projectile rotation and terrain collision doesn't work that great. These are left in
        # hopes that this will look better in the future.. =)
		
        if( self.ShowUnitDestructionDebris and overkillRatio ) then
		
            if overkillRatio <= 1.5 then
                self.CreateUnitDestructionDebris( self, true, true, false )
	
            else #-- VAPORIZED
                self.CreateUnitDestructionDebris( self, true, true, true )
            end
        end
        
        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,
	
    OnDamage = function(self, instigator, amount, vector, damagetype) 
    	if self.Dead == false then
        	#-- Base script for this script function was developed by Gilbot_x
        	#-- sets the damage resistance of the rebuilder bot to 30%
        	local lambdaEmitter_DLS = 0.3
        	amount = math.ceil(amount*lambdaEmitter_DLS)
    	end
    	SShieldStructureUnit.OnDamage(self, instigator, amount, vector, damagetype) 
	end,
	
	KillLambdaEmitter = function(self, instigator, type, overkillRatio)
	
		-- Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
		if table.getn({self.lambdaEmitterTable}) > 0 then
			for k, v in self.lambdaEmitterTable do 
				IssueClearCommands({self.lambdaEmitterTable[k]}) 
				IssueKillSelf({self.lambdaEmitterTable[k]})
			end
		end
	end,

	-- standard maintenance energy
	ResourceThread = function(self) 
		
    	if not self.Dead then
		
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	-- Check to see if the player has enough mass / energy
        	if  energy <= 10 then 
				#-- turn off the unit and launch thread to see if enough to restart it
				#-- since startup power different from maintenance power
            	self:SetScriptBit('RULEUTC_ShieldToggle', false)
            	self:ForkThread(self.ResourceThread2)

        	else
            	-- If the above conditions are not met check again
            	self:ForkThread(self.EconomyWaitUnit)
        	end
    	end    
	end,

	EconomyWaitUnit = function(self)
	
		WaitTicks(30)
		
		if not self.Dead then
			self:ForkThread(self.ResourceThread)
		end
	end,
	
	#-- runs when energy has run out - startup energy is higher than maintenance energy
	ResourceThread2 = function(self) 

    	if not self.Dead then
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	-- Check to see if the player has enough energy
        	if  energy > 3000 then 
            	-- Loops back to standard resource thread
            	self:SetScriptBit('RULEUTC_ShieldToggle', true)
            	self:ForkThread(self.ResourceThread)

        	else
            	#-- wait to try again
            	self:ForkThread(self.EconomyWaitUnit2)
        	end
    	end    
	end,

	EconomyWaitUnit2 = function(self)
		
		WaitTicks(30)

       	if not self.Dead then
           	self:ForkThread(self.ResourceThread2)
       	end
	end,
}

TypeClass = BSB0405