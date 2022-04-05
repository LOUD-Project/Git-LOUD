local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AIFQuantumWarhead = import('/lua/aeonweapons.lua').AIFQuantumWarhead

UAB2305 = Class(AStructureUnit) {


    Weapons = {
        QuantumMissiles = Class(AIFQuantumWarhead) {
		
            UnpackEffects01 = {'/effects/emitters/aeon_nuke_unpack_01_emit.bp',},

            PlayFxWeaponUnpackSequence = function(self)
			
				local army = self.unit:GetArmy()
				local CreateAttachedEmitter = CreateAttachedEmitter
				
                for k, v in self.UnpackEffects01 do
                    CreateAttachedEmitter( self.unit, 'B04', army, v )
                end

                AIFQuantumWarhead.PlayFxWeaponUnpackSequence(self)
				
            end,
    
        },
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        AStructureUnit.OnStopBeingBuilt(self,builder,layer)
		
        local bp = self:GetBlueprint()
        self.Trash:Add(CreateAnimator(self):PlayAnim(bp.Display.AnimationOpen))
        self:ForkThread(self.PlayArmSounds)
		
    end,

    PlayArmSounds = function(self)
	
        local myBlueprint = self:GetBlueprint()
		
        if myBlueprint.Audio.Open and myBlueprint.Audio.Activate then
            WaitSeconds(4.75)
            self:PlaySound(myBlueprint.Audio.Activate)
            WaitSeconds(3.75)
            self:PlaySound(myBlueprint.Audio.Activate)
            WaitSeconds(3.85)
            self:PlaySound(myBlueprint.Audio.Activate)
        end
    end,
    

}

TypeClass = UAB2305
