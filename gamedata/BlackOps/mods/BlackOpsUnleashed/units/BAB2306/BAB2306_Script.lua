local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local MiniPhasonLaser = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').MiniPhasonLaser

--local EffectUtils = import('/lua/effectutilities.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BAB2306 = Class(AStructureUnit) {

    Weapons = {

		MainGun = Class(MiniPhasonLaser){

	        FxVentEffect2 = EffectTemplate.WeaponSteam01,
    
            PlayFxWeaponUnpackSequence = function(self)

                self.unit.EmergeManip:SetGoal( 0,0,0 )

                self.unit.SpinManip:SetTargetSpeed(720)
        
                MiniPhasonLaser.PlayFxWeaponUnpackSequence(self)
    
            end, 
    
            PlayFxWeaponPackSequence = function(self)
        
                self.unit.EmergeManip:SetGoal( 0, -0.22, 0)

		        local army = self.unit:GetArmy()

  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'Rotator', army, v):ScaleEmitter(2)
                    CreateAttachedEmitter(self.unit, 'Muzzle01', army, v):ScaleEmitter(1)
                end

                self.unit.SpinManip:SetTargetSpeed(0)
        
                MiniPhasonLaser.PlayFxWeaponPackSequence(self)
    
            end,         
        },
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
	
        AStructureUnit.OnStopBeingBuilt(self,builder,layer)
        
        self.EmergeManip = CreateSlider( self, 'Turret_Yaw', 0, 0, 0, 0.1, true )
        self.Trash:Add(self.EmergeManip)
        
        self.EmergeManip:SetGoal( 0, -0.22, 0)

		if not self.SpinManip then 
            self.SpinManip = CreateRotator(self, 'Rotator', 'y', nil, 0, 180, 0)
            self.Trash:Add(self.SpinManip)
        end

    end,

}

TypeClass = BAB2306