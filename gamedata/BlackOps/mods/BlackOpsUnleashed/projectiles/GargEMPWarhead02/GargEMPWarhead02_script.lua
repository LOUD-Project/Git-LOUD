local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

GargEMPWarhead02 = Class(NullShell) {
	
    NukeOuterRingDamage = 0,
    NukeOuterRingRadius = 0,
    NukeOuterRingTicks = 0,
    NukeOuterRingTotalTime = 0,

    NukeInnerRingDamage = 0,
    NukeInnerRingRadius = 0,
    NukeInnerRingTicks = 0,
    NukeInnerRingTotalTime = 0,

    NukeMeshScale = 8.5725,
    PlumeVelocityScale = 0.1,

    # NOTE: This script has been modified to REQUIRE that data is passed in!  The nuke won't explode until this happens!


    PassData = function(self, Data)
        if Data.NukeOuterRingDamage then self.NukeOuterRingDamage = Data.NukeOuterRingDamage end
        if Data.NukeOuterRingRadius then self.NukeOuterRingRadius = Data.NukeOuterRingRadius end
        if Data.NukeOuterRingTicks then self.NukeOuterRingTicks = Data.NukeOuterRingTicks end
        if Data.NukeOuterRingTotalTime then self.NukeOuterRingTotalTime = Data.NukeOuterRingTotalTime end
        if Data.NukeInnerRingDamage then self.NukeInnerRingDamage = Data.NukeInnerRingDamage end
        if Data.NukeInnerRingRadius then self.NukeInnerRingRadius = Data.NukeInnerRingRadius end
        if Data.NukeInnerRingTicks then self.NukeInnerRingTicks = Data.NukeInnerRingTicks end
        if Data.NukeInnerRingTotalTime then self.NukeInnerRingTotalTime = Data.NukeInnerRingTotalTime end

        self:CreateNuclearExplosion()
    end,
	
    CreateNuclearExplosion = function(self)

        -- Mesh effects
        self.Plumeproj = self:CreateProjectile('/mods/BlackOpsUnleashed/effects/GargEMPWarHead/GargEMPWarHeadEffect01_proj.bp')

        -- Emitter Effects
        self:ForkThread(self.EmitterEffectsThread, self.Plumeproj)

        self:ForkThread(self.InnerRingDamage)
        self:ForkThread(self.OuterRingDamage)
    end,
    
    OuterRingDamage = function(self)

        local myPos = self:GetPosition()

        if self.NukeOuterRingTotalTime == 0 then
            DamageArea(self:GetLauncher(), myPos, self.NukeOuterRingRadius, self.NukeOuterRingDamage, 'Normal', true, true)
        else
            local ringWidth = ( self.NukeOuterRingRadius / self.NukeOuterRingTicks )
            local tickLength = ( self.NukeOuterRingTotalTime / self.NukeOuterRingTicks )
            
            -- Since we're not allowed to have an inner radius of 0 in the DamageRing function,
            -- I'm manually executing the first tick of damage with a DamageArea function.
            DamageArea(self:GetLauncher(), myPos, ringWidth, self.NukeOuterRingDamage, 'Normal', true, true)
            
            WaitSeconds(tickLength)
            
            for i = 2, self.NukeOuterRingTicks do

                DamageRing(self:GetLauncher(), myPos, ringWidth * (i - 1), ringWidth * i, self.NukeOuterRingDamage, 'Normal', true, true)

                WaitSeconds(tickLength)
            end
        end
    end,

    InnerRingDamage = function(self)

        local myPos = self:GetPosition()

        if self.NukeInnerRingTotalTime == 0 then
            DamageArea(self:GetLauncher(), myPos, self.NukeInnerRingRadius, self.NukeInnerRingDamage, 'Normal', true, true)
        else
            local ringWidth = ( self.NukeInnerRingRadius / self.NukeInnerRingTicks )
            local tickLength = ( self.NukeInnerRingTotalTime / self.NukeInnerRingTicks )

            DamageArea(self:GetLauncher(), myPos, ringWidth, self.NukeInnerRingDamage, 'Normal', true, true)

            WaitSeconds(tickLength)

            for i = 2, self.NukeInnerRingTicks do

                DamageRing(self:GetLauncher(), myPos, ringWidth * (i - 1), ringWidth * i, self.NukeInnerRingDamage, 'Normal', true, true)

                WaitSeconds(tickLength)
            end
        end
    end,   
	
    PlumeEffects = {'/effects/emitters/empfluxwarhead_concussion_ring_02_emit.bp',},

    NormalEffects = {'/effects/emitters/empfluxwarhead_fallout_01_emit.bp'},

    EmitterEffectsThread = function(self, plume)
        local army = self:GetArmy()

        for k, v in self.PlumeEffects do
            CreateAttachedEmitter( plume, -1, army, v )
        end

        for k, v in self.NormalEffects do
            CreateEmitterAtEntity( self, army, v )
        end

    end,

}

TypeClass = GargEMPWarhead02

