--
-- Terran Anti Air Missile
--
CAANanoDartProjectile = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile
BaaMissile01 = Class(CAANanoDartProjectile)
{
	OnCreate = function(self)
		CAANanoDartProjectile.OnCreate(self)
		
		self:ForkThread(self.WaitThread)
		self:ForkThread(self.UpdateThread)
	end,
	
	FxBeam = {'/mods/BlackOpsUnleashed/effects/emitters/mini_microwave_laser_beam_01_emit.bp'},
	
	#-- seems the purpose of this is to have a slow missile launch, but after 4 ticks, show exhaust trails  and then accelerate to 
	#-- very high - but random - speeds - Gives the appearance of a two stage missile
	UpdateThread = function(self)
	
        WaitTicks(4)
		
        self:SetMaxSpeed(8)
        self:SetBallisticAcceleration(-0.5)
		
        local army = self:GetArmy()

        for i in self.FxTrails do
            CreateEmitterOnEntity(self,army,self.FxTrails[i])
        end

        WaitTicks(5)
        self:SetMesh('/projectiles/CAANanoDart01/CAANanoDartUnPacked01_mesh')
        self:SetMaxSpeed(65)
        self:SetAcceleration(20 + Random() * 5)

        WaitTicks(3)
        self:SetTurnRate(360)

    end,
	
	WaitThread = function(self)
		
		local army = self:GetArmy()
	
		while(true) do	--	do this forever.
		
			local currentTarget = self:GetTrackingTarget()
			
			if not currentTarget then
				return	--	damn.
			end

			if currentTarget.GetSource then
				currentTarget = currentTarget:GetSource()
			end

			if VDist3(currentTarget:GetPosition(), self:GetPosition()) < 10 then
				--	Now we go all Shoop-de-Whoop.
				
				self.Lasering = true
				
				if self.hasOKC then
					self.OKCData.dontOKCheck = true	--	turn off OKC right now.
				end
				
				--playing firing sound
				self:PlaySound(self:GetBlueprint().Audio['Arc'])
				
				--	Just in case there's lots of stuff in FxBeam, we'll loop through it.
				for id, fx in self.FxBeam do
					local effectEnt = AttachBeamEntityToEntity(currentTarget, -1, self, -1, army, fx)	--	the -2 is worrying.

					self.Trash:Add(effectEnt)
				end
				
				self:DoDamage(self:GetLauncher(), self.DamageData, currentTarget)
				
				WaitSeconds(self.DamageData.DoTTime)
				
				self:Destroy()	--	au revoir.
			end
			
			WaitTicks(1)
		
		end
	
	end,
	--[[
	OnImpact = function(self, with, who)
	
		if not self.Lasering then	--	if we collide with something else before being Shoop, don't DoT.
			self.DamageData.DoTTime = nil
			self.DamageData.DoTPulses = nil
		end
		
		CAANanoDartProjectile.OnImpact(self, with, who)
	
	end,
	]]--
}

TypeClass = BaaMissile01

