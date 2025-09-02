------------------------------------------------------------------------------
-- File     :  FAF version of projectiles/AIFQuantumWarhead02/AIFQuantumWarhead02_script.lua
-- For      :  FAF/1.6.6 cross compatibility
------------------------------------------------------------------------------
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

AIFQuantumWarhead = Class(NullShell) {

    NormalEffects       = {'/effects/emitters/quantum_warhead_01_emit.bp',},

    CloudFlareEffects   = EffectTemplate.CloudFlareEffects01,

    EffectThread = function(self)

        local army = self:GetArmy()

        CreateLightParticle(self, -1, army, 200, 200, 'beam_white_01', 'ramp_quantum_warhead_flash_01')

        self:ForkThread(self.ShakeAndBurnMe, army)
        self:ForkThread(self.InnerCloudFlares, army)
        self:ForkThread(self.DistortionField)

        for k, v in self.NormalEffects do
            CreateEmitterAtEntity(self, army, v)
        end
    end,

    ShakeAndBurnMe = function(self, army)

        self:ShakeCamera(75, 3, 0, 8)

        WaitSeconds(0.5)

        local orientation = RandomFloat(0,6.28)

        -- CreateDecal(position, heading, textureName, albedo2, type, sizeX, sizeZ, lodParam, duration, army)
        CreateDecal(self:GetPosition(), orientation, 'Crater01_albedo', '', 'Albedo', 48, 48, 800, 300, army)
        CreateDecal(self:GetPosition(), orientation, 'Crater01_normals', '', 'Normals', 48, 48, 800, 300, army)

        self:ShakeCamera(105, 10, 0, 2)
        WaitSeconds(2)
        self:ShakeCamera(75, 1, 0, 12)
    end,

    InnerCloudFlares = function(self, army)

        local angle = 0.1256
        local angleVariation = 6.28

        local emit, x, y, z = nil

        local DirectionMul = 0.02

        for i = 0, 49 do
            x = math.sin((i*angle) + RandomFloat(-angleVariation, angleVariation))
            y = 0.5
            z = math.cos((i*angle) + RandomFloat(-angleVariation, angleVariation)) 

            for k, v in self.CloudFlareEffects do
                emit = CreateEmitterAtEntity( self, army, v )
                emit:OffsetEmitter( x * 4, y * 4, z * 4 )
                emit:SetEmitterCurveParam('XDIR_CURVE', x * DirectionMul, 0.01)
                emit:SetEmitterCurveParam('YDIR_CURVE', y * DirectionMul, 0.01)
                emit:SetEmitterCurveParam('ZDIR_CURVE', z * DirectionMul, 0.01)
            end
            
            if math.mod(i,11) == 0 then
                CreateLightParticle(self, -1, army, 13, 3, 'beam_white_01', 'ramp_quantum_warhead_flash_01')
            end
            
            WaitSeconds(RandomFloat( 0.05, 0.15 ))
        end
        
        CreateLightParticle(self, -1, army, 13, 3, 'beam_white_01', 'ramp_quantum_warhead_flash_01')
        CreateEmitterAtEntity( self, army, '/effects/emitters/quantum_warhead_ring_01_emit.bp' )
    end,

    DistortionField = function(self)

        local proj = self:CreateProjectile('/effects/QuantumWarhead/QuantumWarheadEffect01_proj.bp')
        local scale = proj:GetBlueprint().Display.UniformScale

        proj:SetScaleVelocity(0.123 * scale,0.123 * scale,0.123 * scale)
        WaitSeconds(16.0)
        proj:SetScaleVelocity(0.01 * scale,0.01 * scale,0.01 * scale)
    end,
}

TypeClass = AIFQuantumWarhead