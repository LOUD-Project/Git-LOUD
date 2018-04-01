
local SeraHeavyLightningCannonChildProjectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').SeraHeavyLightningCannonChildProjectile

local GetEnemyUnitsInSphere = import('/lua/utilities.lua').GetEnemyUnitsInSphere

SeraHeavyLightningCannonChild01 = Class(SeraHeavyLightningCannonChildProjectile) {

    AttackBeams = {'/mods/BlackOpsUnleashed/effects/emitters/seraphim_lightning_beam_02_emit.bp'},

	FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/seraphim_lightning_beam_02_emit.bp'},
	FxBeamScale = 0.01,
	
    OnCreate = function(self)
		SeraHeavyLightningCannonChildProjectile.OnCreate(self)
		self:ForkThread(self.BFG)
    end,

	BFG = function(self)
        -- Setup the FX bag
        local arcFXBag = {}
        local radius = 0.5
        local army = self:GetArmy()       

        -- While projectile active and has avalible damage perform BFG area damage and effects
        if not self:BeenDestroyed() then

            local projPos = self:GetPosition()
            local avalibleTargets = GetEnemyUnitsInSphere( self, projPos, 10)
            
            if avalibleTargets then
			
                if table.getn(avalibleTargets) > 4 then
				
					#-- damage 4 targets randomly
                    for i = 0, (4 -1) do
					
						#-- pick a target
						local ranTarget = Random( 1, table.getn(avalibleTargets) )
						local target = avalibleTargets[ranTarget]   
						
						-- Set the beam damage equal to a fraction of the projectile
						local beamDmgAmt =  self.DamageData.DamageAmount * .25

						self:PlaySound(self:GetBlueprint().Audio['Arc'])       

						Damage(self:GetLauncher(), target:GetPosition(), target, beamDmgAmt, 'Normal') 
						
						-- Attach beam to the target
						for k, a in self.FxBeam do
							local beam = AttachBeamEntityToEntity(self, -1, target, -1, army, a)
							table.insert(arcFXBag, beam)
							self.Trash:Add(beam)
						end

					end
					
				elseif table.getn(avalibleTargets) <= 4 and table.getn(avalibleTargets) > 0 then
				
					#-- damage the targets equally
					for i = 0, (table.getn(avalibleTargets) -1) do      
					
						local ranTarget = Random(1,table.getn(avalibleTargets))
						local target = avalibleTargets[ranTarget]   
						
						-- Set the beam damage equal to a fraction of the projectiles avalible DMG pool
						local beamDmgAmt = math.floor(self.DamageData.DamageAmount / table.getn(avalibleTargets) )

						self:PlaySound(self:GetBlueprint().Audio['Arc'])                                   
						
						Damage(self:GetLauncher(), target:GetPosition(), target, beamDmgAmt, 'Normal') 

						for k, a in self.FxBeam do
							local beam = AttachBeamEntityToEntity(self, -1, target, -1, army, a)
							table.insert(arcFXBag, beam)
							self.Trash:Add(beam)
						end

					end
				end                                                                     
            end            
            -- Small delay so that the beam and FX are visable
            WaitTicks(3)            
            -- Remove all FX
            for k, v in arcFXBag do
                v:Destroy()
            end            
            arcFXBag = {}              
            -- Small delay to show the FX removal
            WaitTicks(3)          
        end
    end,

}

TypeClass = SeraHeavyLightningCannonChild01