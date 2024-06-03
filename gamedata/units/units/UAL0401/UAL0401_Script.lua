local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import ('/lua/aeonweapons.lua')

local ADFPhasonLaser = WeaponsFile.ADFPhasonLaser
local ADFTractorClaw = WeaponsFile.ADFTractorClaw

WeaponsFile = nil

local utilities = import('/lua/utilities.lua')
local explosion = import('/lua/defaultexplosions.lua')

UAL0401 = Class(AWalkingLandUnit) {

    Weapons = {
        EyeWeapon = Class(ADFPhasonLaser) {},
        RightArmTractor = Class(ADFTractorClaw) {},
        LeftArmTractor = Class(ADFTractorClaw) {},
    },

    OnKilled = function(self, instigator, type, overkillRatio)
        AWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
        local wep = self:GetWeaponByLabel('EyeWeapon')
        local bp = wep:GetBlueprint()
        if bp.Audio.BeamStop then
            wep:PlaySound(bp.Audio.BeamStop)
        end
        if bp.Audio.BeamLoop and wep.Beams[1].Beam then
            wep.Beams[1].Beam:SetAmbientSound(nil, nil)
        end
        for k, v in wep.Beams do
            v.Beam:Disable()
        end     
    end,

    DeathThread = function( self, overkillRatio , instigator)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Torso', 4.0 )
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()})           
        WaitSeconds(2)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Right_Leg_B02', 1.0 )
        WaitSeconds(0.1)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Right_Leg_B01', 1.0 )
        WaitSeconds(0.1)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Left_Arm_B02', 1.0 )
        WaitSeconds(0.3)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Right_Arm_B01', 1.0 )
        explosion.CreateDefaultHitExplosionAtBone( self, 'Right_Leg_B01', 1.0 )

        WaitSeconds(3.5)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Torso', 5.0 )        

        if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
    
        local bp = self:GetBlueprint()
        for i, numWeapons in bp.Weapon do
            if(bp.Weapon[i].Label == 'CollossusDeath') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end

        self:DestroyAllDamageEffects()
        self:CreateWreckage( overkillRatio )

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

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,
    
}
TypeClass = UAL0401