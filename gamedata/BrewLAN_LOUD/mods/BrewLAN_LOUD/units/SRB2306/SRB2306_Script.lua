--**
--**  Summary  :  Cybran Maser Tower Script
--**
-- some neato shit going on here - weapon will increase energy usage each
-- time it fires - by 10 - until it reaches 800 - where it will overheat
-- and damage itself.   It then has a forced cooldown for several seconds
-- before continuing to fire normally again.
local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CDFHeavyMicrowaveLaserGeneratorCom = import('/lua/cybranweapons.lua').CDFHeavyMicrowaveLaserGeneratorCom
local explosion = import('/lua/defaultexplosions.lua') 

SRB2306 = Class(CStructureUnit) {
   
    Weapons = {
	
        MainGun = Class(CDFHeavyMicrowaveLaserGeneratorCom) {
        
            OnCreate = function(self)
            
                CDFHeavyMicrowaveLaserGeneratorCom.OnCreate(self)

                self.EnergyInc = self.bp.EnergyCumulativeUpkeepCost or 10
                self.EnergyMin = self.bp.EnergyConsumptionPerSecondMin or 10
                self.EnergyMax = self.bp.EnergyConsumptionPerSecondMax or 1000
                self.EnergyDissRate = self.bp.EnergyDissipationPerSecond or 30

                self.EnergyCost = self.EnergyMin

                self.ForceCooldown = false

                self.StopFireTime = false
                
                self.TimeSinceLastFire = 0
                
            end,
            
            OnWeaponFired = function(self)
            
                CDFHeavyMicrowaveLaserGeneratorCom.OnWeaponFired(self)
                
                self.TimeSinceLastFire = (self.StopFireTime or GetGameTimeSeconds()) - GetGameTimeSeconds()
				
                self.unit.deathdamage = math.max(self.EnergyMin, self.EnergyCost - math.floor(((self.TimeSinceLastFire - 1)*self.EnergyDissRate)/10)*10)
                
                if self.unit.deathdamage < self.EnergyCost then
                    self.unit.PerformOnFireChecks = true
                end

                --LOG("*AI DEBUG Time Since Last Fire is "..repr(self.TimeSinceLastFire))
                
                --LOG("*AI DEBUG deathdamage is "..self.unit.deathdamage)

            end,
            
            IdleState = State(CDFHeavyMicrowaveLaserGeneratorCom.IdleState) { 
			
                Main = function(self)
				
                    if self.RotatorManip then
					
                        self.RotatorManip:SetSpeed(0)
						
                    end
					
                    if self.SliderManip then
					
                        self.SliderManip:SetGoal(0,0,0)
                        self.SliderManip:SetSpeed(2)
						
                    end 
					
                    CDFHeavyMicrowaveLaserGeneratorCom.IdleState.Main(self)
                    
                    if self.PerformIdleChecks then
					
                        self.FirstShot = true

                        self.PerformIdleChecks = false 
                        self.unit.PerformOnFireChecks = true
						
                    end
					
                end,    
                
                OnGotTarget = function(self)
                
                    self.TimeSinceLastFire = GetGameTimeSeconds() - (self.StopFireTime or GetGameTimeSeconds())

                    self.EnergyCost = math.max(self.EnergyMin, self.EnergyCost - math.floor((self.TimeSinceLastFire*self.EnergyDissRate)/10)*10)
                    
                    --LOG("*AI DEBUG EnergyCost Reset to "..self.EnergyCost)
                
                    CDFHeavyMicrowaveLaserGeneratorCom.IdleState.OnGotTarget(self)
                end,
            },

            StartEconomyDrain = function(self)
			
                local bp = self.bp
				
                if self.FirstShot or self.Dead then return end
				
                if not self.EconDrain then
		
                    local function ChargeProgress( self, progress)
                        moho.unit_methods.SetWorkProgress( self, progress )
                    end
                    
                    local nrgReq = self.EnergyCost * (self.AdjEnergyMod or 1)
                    local nrgDrain = self.EnergyCost
				
                    if self.unit.PerformOnFireChecks then
                    
                        --LOG("*AI DEBUG Time since last fire is "..repr(self.TimeSinceLastFire))
					
                        nrgReq = math.max(self.EnergyMin, self.EnergyCost - math.floor((self.TimeSinceLastFire*self.EnergyDissRate)/10)*10)
                        nrgDrain = nrgReq

                        self.unit.PerformOnFireChecks = false
						
                    end
                    
                    if nrgDrain >= self.EnergyMax then
                    
                        self.ForceCooldown = true
                        self.unit:Overheat()

                    else
                        self.ForceCooldown = false
                    end
					
                    if (not self.Dead) and nrgDrain > 0 then
					
                        local time = math.max(nrgReq / nrgDrain, 0.1)
                        
                        if self.ForceCooldown then
                        
                            time = time * 3
                            
                            self.unit.PerformOnFireChecks = true
                            
                        end
                        
                        --LOG("*AI DEBUG Charge Time is "..repr(time))
                        --LOG("*AI DEBUG Charge requires "..nrgReq)
                        
                        self.StopFireTime = GetGameTimeSeconds() + time
						
                        self.EconDrain = CreateEconomyEvent(self.unit, nrgReq, 0, time, ChargeProgress )   
                        self.FirstShot = true
						
                    end
                end
            end,

            CreateProjectileAtMuzzle = function(self, muzzle)
			
                if not self.SliderManip then
				
                    self.SliderManip = CreateSlider(self.unit, 'Center_Turret_Barrel')
                    self.unit.Trash:Add(self.SliderManip)
					
                end
				
                if not self.RotatorManip then
				
                    self.RotatorManip = CreateRotator(self.unit, 'Center_Turret_Barrel', 'z')
                    self.unit.Trash:Add(self.RotatorManip)
					
                end
				
                self.RotatorManip:SetSpeed(180)
                self.SliderManip:SetPrecedence(11)
                self.SliderManip:SetGoal(0, 0, -1)
                self.SliderManip:SetSpeed(-1)  
				
                CDFHeavyMicrowaveLaserGeneratorCom.CreateProjectileAtMuzzle(self, muzzle)  

                self.EnergyCost = self.EnergyCost + self.EnergyInc  -- increase consumption
                
                -- then reduce it for any cooldown that took place
                self.EnergyCost = math.max(self.EnergyMin, self.EnergyCost - math.floor(((self.TimeSinceLastFire - 1) * self.EnergyDissRate)/10)*10)
				
                self.PerformIdleChecks = true

            end,
        },
    },
	
    Overheat = function(self)
    
        --LOG("*AI DEBUG Overheating - damage is "..repr(self.deathdamage))
    
        ForkThread( FloatingEntityText, self.EntityID, "Overheating Damage ")

        CreateEmitterAtBone(self, 'Turret_Muzzle01', self:GetArmy(),'/effects/emitters/destruction_explosion_fire_plume_02_emit.bp'):ScaleEmitter( 0.33 )
        CreateEmitterAtBone(self, 'Turret_Muzzle01', self:GetArmy(),'/effects/emitters/destruction_damaged_smoke_01_emit.bp'):SetEmitterParam('LIFETIME', 150):ScaleEmitter( 0.6 )
        CreateEmitterAtBone(self, 'Turret_Muzzle01', self:GetArmy(),'/effects/emitters/destruction_damaged_smoke_01_emit.bp'):SetEmitterParam('LIFETIME', 120)

        DamageArea(self, self:GetPosition(), 1, self.deathdamage, 'Default', true, true)

        explosion.CreateDefaultHitExplosionAtBone( self, 'Turret_Muzzle01', 1.0 )
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()})
		
    end,
    
    OnKilled = function(self, instigator, type, overkillRatio)
        
        if self.PerformOnFireChecks then
            self.deathdamage = self.deathdamage - (GetGameTimeSeconds() - (self.StopFireTime or GetGameTimeSeconds()))*30
        end
		
        local radius = 3 * (self.deathdamage or 10)/1000
		
        DamageArea(self, self:GetPosition(), radius, (self.deathdamage or 10), 'Default', true, true)
		
        explosion.CreateDefaultHitExplosionAtBone( self, 0, radius )
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()})
		
        CStructureUnit.OnKilled(self, instigator, type, overkillRatio)
		
    end, 
}

TypeClass = SRB2306
