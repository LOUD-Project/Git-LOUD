local SShieldStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local LambdaWeapon = import ('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').LambdaWeapon

local SSeraphimSubCommanderGateway01 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway01
local SSeraphimSubCommanderGateway02 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway02
local SSeraphimSubCommanderGateway03 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway03

local explosion = import('/lua/defaultexplosions.lua')

local SeraLambdaFieldRedirector = import('/lua/defaultantiprojectile.lua').SeraLambdaFieldRedirector
local SeraLambdaFieldDestroyer = import('/lua/defaultantiprojectile.lua').SeraLambdaFieldDestroyer

local CreateAttachedEmitter = CreateAttachedEmitter

BSB0405 = Class(SShieldStructureUnit) {
	
    LambdaEffects = {
        '/effects/emitters/seraphim_t3power_ambient_01_emit.bp',
        '/effects/emitters/seraphim_t3power_ambient_02_emit.bp',
        '/effects/emitters/seraphim_t3power_ambient_04_emit.bp',
    },
	
    Weapons = {
        Eye = Class(LambdaWeapon) {},
    },
    
    OnStopBeingBuilt = function(self, builder, layer)
    
        local army = self.Army
        
        for k, v in SSeraphimSubCommanderGateway01 do
            CreateAttachedEmitter(self, 'Light04', army, v):ScaleEmitter(0.4)
			CreateAttachedEmitter(self, 'Light05', army, v):ScaleEmitter(0.4)
			CreateAttachedEmitter(self, 'Light06', army, v):ScaleEmitter(0.4)
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
		
        self.Rotator1 = CreateRotator(self, 'Spinner', 'y', nil, 5, 20, 5)
		
        self.Trash:Add(self.Rotator1)

        local bpd = self:GetBlueprint().Defense
        
    	local bp = bpd.LambdaRedirect01
        local bp2 = bpd.LambdaRedirect02
        local bp3 = bpd.LambdaRedirect03
        local bp4 = bpd.LambdaDestroy01
        local bp5 = bpd.LambdaDestroy02
        
        self.Lambda1 = SeraLambdaFieldRedirector {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }
		
        self.Lambda2 = SeraLambdaFieldRedirector {
            Owner = self,
            Radius = bp2.Radius,
            AttachBone = bp2.AttachBone,
            RedirectRateOfFire = bp2.RedirectRateOfFire
        }
		
        self.Lambda3 = SeraLambdaFieldRedirector {
            Owner = self,
            Radius = bp3.Radius,
            AttachBone = bp3.AttachBone,
            RedirectRateOfFire = bp3.RedirectRateOfFire
        }
		
        self.Lambda4 = SeraLambdaFieldDestroyer {
            Owner = self,
            Radius = bp4.Radius,
            AttachBone = bp4.AttachBone,
            RedirectRateOfFire = bp4.RedirectRateOfFire
        }
		
        self.Lambda5 = SeraLambdaFieldDestroyer {
            Owner = self,
            Radius = bp5.Radius,
            AttachBone = bp5.AttachBone,
            RedirectRateOfFire = bp5.RedirectRateOfFire
        }
		
        self.Trash:Add(self.Lambda1)
        self.Trash:Add(self.Lambda2)
        self.Trash:Add(self.Lambda3)
        self.Trash:Add(self.Lambda4)
        self.Trash:Add(self.Lambda5)		

		-- turn on Lambda emitters --
        self:SetScriptBit('RULEUTC_SpecialToggle', true)
    end,
    
    OnScriptBitSet = function(self, bit)
	
        SShieldStructureUnit.OnScriptBitSet(self, bit)
		
        if bit == 7 then 
            self.Lambda1:Enable()
            self.Lambda2:Enable()
            self.Lambda3:Enable()
            self.Lambda4:Enable()
            self.Lambda5:Enable()

			self:SetMaintenanceConsumptionActive()
            
            if not self.ConsumptionThread then
                self.ConsumptionThread = self:ForkThread( self.WatchConsumption )
            end

            self.Rotator1:SetTargetSpeed(60)

    	end

    end,
    
    OnScriptBitClear = function(self, bit)
	
        SShieldStructureUnit.OnScriptBitClear(self, bit)
		
        if bit == 7 then 
            self.Lambda1:Disable()
            self.Lambda2:Disable()
            self.Lambda3:Disable()
            self.Lambda4:Disable()
            self.Lambda5:Disable()

			self:SetMaintenanceConsumptionInactive()
        
            KillThread(self.ConsumptionThread)
            self.ConsumptionThread = nil

            self.Rotator1:SetTargetSpeed(0)            

        end
    end,

    -- this thread is launched when the lambda is turned on
    -- and will disable it, and remove the toggle, if the power drops out
    -- and will restore it once the power returns
    WatchConsumption = function(self)
	
        local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
		local GetResourceConsumed = moho.unit_methods.GetResourceConsumed
        local WaitTicks = coroutine.yield

        local MaintenanceConsumption = __blueprints[self.BlueprintID].MaintenanceConsumptionPerSecondEnergy
    
        local on = true
        local count = 0

        local aiBrain = self:GetAIBrain()
        local army =  self.Army

        self.Effects = {}    

        while true do

            WaitTicks(16)
            
            if GetResourceConsumed(self) != 1 and GetEconomyStored(aiBrain,'Energy') < 1 then
            
                self.Lambda1:Disable()
                self.Lambda2:Disable()
                self.Lambda3:Disable()
                self.Lambda4:Disable()
                self.Lambda5:Disable()

                self:SetMaintenanceConsumptionInactive()

                self.Rotator1:SetTargetSpeed(0)            

                -- turn off the consumption effects
                for _,v in self.Effects do
                    v:Destroy()
                end
   
   count = 0

                self:RemoveToggleCap('RULEUTC_SpecialToggle')

                on = false
            end

            while not on do

                WaitTicks(16)

                if GetEconomyStored(aiBrain,'Energy') > MaintenanceConsumption then

                    self.Lambda1:Enable()
                    self.Lambda2:Enable()
                    self.Lambda3:Enable()
                    self.Lambda4:Enable()
                    self.Lambda5:Enable()

                    self:SetMaintenanceConsumptionActive()

                    self.Rotator1:SetTargetSpeed(60)

                    self:AddToggleCap('RULEUTC_SpecialToggle')

                    on = true
                end
            end

            -- turn on the consumption effects --
            if count == 0 then
                for _,v in self.LambdaEffects do
                    count = count + 1
                    self.Effects[count] = CreateEmitterOnEntity( self, army, v ):ScaleEmitter(0.7)
                end
            end
            
        end
        
    end,    

    DeathThread = function( self, overkillRatio , instigator)
	
		if self.Rotator1 then
			self.Rotator1:SetTargetSpeed(0)
		end

        local bigExplosionBones = {'Spinner', 'Eye01', 'Eye02'}
        local explosionBones = {'XSB0405', 'Light01', 'Light02', 'Light03', 'Light04', 'Light05', 'Light06' }

        explosion.CreateDefaultHitExplosionAtBone( self, bigExplosionBones[Random(1,3)], 4.0 )
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()}) 
		
        WaitTicks(15)
        
        local RandBoneIter = RandomIter(explosionBones)
		
        for i=1,Random(4,6) do
            local bone = RandBoneIter()
            explosion.CreateDefaultHitExplosionAtBone( self, bone, 1.0 )
            WaitTicks(Random(1,3))
        end
        
        local bp = __blueprints[self.BlueprintID]
		
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
		
        if ( self.ShowUnitDestructionDebris and overkillRatio ) then
		
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

}

TypeClass = BSB0405