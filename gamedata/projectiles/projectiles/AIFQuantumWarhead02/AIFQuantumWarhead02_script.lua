local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

local ForkThread = ForkThread
local KillThread = KillThread
local WaitSeconds = WaitSeconds

local DamageArea = DamageArea
local DamageRing = DamageRing

local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateLightParticle = CreateLightParticle

AIFQuantumWarhead02 = Class(NullShell) {

	-- declare variables -- 
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

    NormalEffects = {'/effects/emitters/quantum_warhead_01_emit.bp',},
	
    CloudFlareEffects = EffectTemplate.CloudFlareEffects01,

	-- get the data from the blueprint data
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
	
        local army = self:GetArmy()
		
        CreateLightParticle(self, -1, army, 200, 200, 'beam_white_01', 'ramp_quantum_warhead_flash_01')

        self:ForkThread(self.ShakeAndBurnMe, army)
        self:ForkThread(self.InnerCloudFlares, army)
        self:ForkThread(self.DistortionField)

        for k, v in self.NormalEffects do
            CreateEmitterAtEntity( self, army, v )
        end

        self:ForkThread(self.InnerRingDamage)
        self:ForkThread(self.OuterRingDamage)
        self:ForkThread(self.ForceThread)
    end,
    
    OuterRingDamage = function(self)
	
        local myPos = self:GetPosition()
		local launcher = self:GetLauncher()
		local startradius = math.max( self.NukeInnerRingRadius, 0.1 ) -- determine starting radius of outer ring -- min is 0.1 
		
        if self.NukeOuterRingTotalTime == 0 then	-- damage the entire outer ring all at once
		
            DamageRing( launcher, myPos, startradius, self.NukeOuterRingRadius, self.NukeOuterRingDamage, self.DamageData.DamageType, true, true)
			
        else	-- roll the damage from the inner ring to the outer ring -- 
		
            local ringWidth = ( (self.NukeOuterRingRadius - self.NukeInnerRingRadius) / self.NukeOuterRingTicks )
            local tickLength = ( self.NukeOuterRingTotalTime / self.NukeOuterRingTicks )
			
            for i = 1, self.NukeOuterRingTicks do
				
                DamageRing( launcher, myPos, startradius + (ringWidth * (i - 1)), startradius + (ringWidth * i), self.NukeOuterRingDamage, self.DamageData.DamageType, true, true)
				
                WaitSeconds(tickLength)
				
            end
			
        end
		
    end,

    InnerRingDamage = function(self)
	
        local myPos = self:GetPosition()
		local launcher = self:GetLauncher()
		
        if self.NukeInnerRingTotalTime == 0 then
		
            DamageArea( launcher, myPos, self.NukeInnerRingRadius, self.NukeInnerRingDamage, self.DamageData.DamageType, true, true)
			
        else
		
            local ringWidth = ( self.NukeInnerRingRadius / self.NukeInnerRingTicks )
            local tickLength = ( self.NukeInnerRingTotalTime / self.NukeInnerRingTicks )
			
            -- Since we're not allowed to have an inner radius of 0 in the DamageRing function,
            -- I execute the first ring of damage with a DamageArea function.
            DamageArea( launcher, myPos, ringWidth, self.NukeInnerRingDamage, 'Normal', true, true)
			
            WaitSeconds(tickLength)
			
            for i = 2, self.NukeInnerRingTicks do
			
                DamageRing( launcher, myPos, ringWidth * (i - 1), ringWidth * i, self.NukeInnerRingDamage, self.DamageData.DamageType, true, true)
				
                WaitSeconds(tickLength)
				
            end
			
        end
		
    end,   

    ForceThread = function(self)
        local pos = self:GetPosition()
        pos[2] = GetSurfaceHeight(pos[1], pos[3]) + 1

        DamageArea(self, pos, 5, 1, 'Force', true)

        WaitSeconds(0.5)

        DamageRing(self, pos, 4, 15, 1, 'Force', true)

        WaitSeconds(0.5)

        DamageArea(self, pos, 15, 1, 'Force', true)
    end,

    ShakeAndBurnMe = function(self, army)
	
        self:ShakeCamera( 75, 3, 0, 10 )
		
        WaitSeconds( 0.5 )
		
        local orientation = RandomFloat(0,6.28)
		
        CreateDecal(self:GetPosition(), orientation, 'Crater01_albedo', '', 'Albedo', 50, 50, 360, 0, army)
        CreateDecal(self:GetPosition(), orientation, 'Crater01_normals', '', 'Normals', 50, 50, 360, 0, army)
		
        self:ShakeCamera( 105, 10, 0, 2 )
		
        WaitSeconds( 2 )
		
        self:ShakeCamera( 75, 1, 0, 15 )
    end,


    InnerCloudFlares = function(self, army)
	
		local LOUDCOS = math.cos
		local LOUDSIN = math.sin
		local LOUDMOD = math.mod

		local CreateEmitterAtEntity = CreateEmitterAtEntity
		
        local numFlares = 50
        local angle = 6.28 / numFlares
        local angleInitial = 0.0 
        local angleVariation = 6.28

        local emit, x, y, z = nil
        local DirectionMul = 0.02
        local OffsetMul = 4

        for i = 0, (numFlares - 1) do
            x = LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))
            y = 0.5 #RandomFloat(0.5, 1.5)
            z = LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation)) 

            for k, v in self.CloudFlareEffects do
                emit = CreateEmitterAtEntity( self, army, v )
                emit:OffsetEmitter( x * OffsetMul, y * OffsetMul, z * OffsetMul )
                emit:SetEmitterCurveParam('XDIR_CURVE', x * DirectionMul, 0.01)
                emit:SetEmitterCurveParam('YDIR_CURVE', y * DirectionMul, 0.01)
                emit:SetEmitterCurveParam('ZDIR_CURVE', z * DirectionMul, 0.01)
            end
            
            if LOUDMOD(i,11) == 0 then
                CreateLightParticle(self, -1, army, 13, 3, 'beam_white_01', 'ramp_quantum_warhead_flash_01')
            end
            
            WaitSeconds(RandomFloat( 0.05, 0.15 ))
        end
        
        CreateLightParticle(self, -1, army, 13, 3, 'beam_white_01', 'ramp_quantum_warhead_flash_01')
        CreateEmitterAtEntity( self, army, '/effects/emitters/quantum_warhead_ring_01_emit.bp' )
    end,

    DistortionField = function( self )
        local proj = self:CreateProjectile('/effects/QuantumWarhead/QuantumWarheadEffect01_proj.bp')
        local scale = proj:GetBlueprint().Display.UniformScale

        proj:SetScaleVelocity(0.123 * scale,0.123 * scale,0.123 * scale)
        WaitSeconds(17.0)
        proj:SetScaleVelocity(0.01 * scale,0.01 * scale,0.01 * scale)
    end,
}

TypeClass = AIFQuantumWarhead02

