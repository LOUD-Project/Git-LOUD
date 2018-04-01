local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local SIFInainoWeapon = import('/lua/seraphimweapons.lua').SIFInainoWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')

XSB2305 = Class(SStructureUnit) {
    Weapons = {
        InainoMissiles = Class(SIFInainoWeapon) { 
        
            # launch charge
			LaunchEffects = function(self)   
				###LOG ("launch effects") 
				local FxLaunch = EffectTemplate.SIFInainoPreLaunch01 
				
				WaitSeconds(1.5)
 				self.unit:PlayUnitAmbientSound( 'NukeCharge' )
				for k, v in FxLaunch do
					CreateEmitterAtEntity( self.unit, self.unit:GetArmy(), v )
				end
				WaitSeconds(9.5)
				self.unit:StopUnitAmbientSound( 'NukeCharge' )

			end,   
		  
			PlayFxWeaponUnpackSequence = function(self)
				self:ForkThread(self.LaunchEffects)
				SIFInainoWeapon.PlayFxWeaponUnpackSequence(self)
			end,  
        },
    },
    
    --OnStopBeingBuilt = function(self,builder,layer)
        --SStructureUnit.OnStopBeingBuilt(self,builder,layer)
        --local bp = self:GetBlueprint()
        --self.Trash:Add(CreateAnimator(self):PlayAnim(bp.Display.AnimationOpen))
        --self:ForkThread(self.PlayArmSounds)
    --end,
--

    
  
}

TypeClass = XSB2305