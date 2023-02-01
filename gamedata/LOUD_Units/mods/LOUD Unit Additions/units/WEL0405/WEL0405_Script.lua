local ExperimentalMobileUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local DefaultProjectileWeapon = import('/lua/sim/defaultweapons.lua').DefaultProjectileWeapon

local AIFMissileTacticalSerpentineWeapon = import('/lua/aeonweapons.lua').AIFMissileTacticalSerpentineWeapon
local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

local Buff = import('/lua/sim/Buff.lua')
local AeonBuffField = import('/lua/aeonweapons.lua').AeonBuffField

WEL0405 = Class(ExperimentalMobileUnit) {

	BuffFields = {
	
		RegenField = Class(AeonBuffField){
		
			OnCreate = function(self)
				AeonBuffField.OnCreate(self)
			end,
		},
	},
    
    Weapons = {
		
        RightMainWeapon = Class(DefaultProjectileWeapon) {
		
            OnCreate = function(self)
			
                self.RightSpinner = CreateRotator(self.unit, 'UUX0111_T01_B01_Recoil01', 'z')
				
                self.RightSpinnerGoal = 180
                self.unit.Trash:Add(self.RightSpinner)        
				
                DefaultProjectileWeapon.OnCreate(self)
            end,

            PlayFxRackReloadSequence = function(self)
			
                self.RightSpinner:SetCurrentAngle(0)
                self.RightSpinner:SetGoal(self.RightSpinnerGoal)
                self.RightSpinner:SetSpeed(100)
                self.RightSpinner:SetAccel(10)
				
		        DefaultProjectileWeapon.PlayFxRackReloadSequence(self)
	        end,

        },
		
        LeftMainWeapon = Class(DefaultProjectileWeapon) {
		
            OnCreate = function(self)            
			
                self.LeftSpinner = CreateRotator(self.unit, 'UUX0111_T01_B02_Recoil01', '-z')
				
                self.LeftSpinnerGoal = 180
                self.unit.Trash:Add(self.LeftSpinner)        
				
                DefaultProjectileWeapon.OnCreate(self)
            end,

            PlayFxRackReloadSequence = function(self)
			
                self.LeftSpinner:SetCurrentAngle(0)
                self.LeftSpinner:SetGoal(self.LeftSpinnerGoal)
                self.LeftSpinner:SetSpeed(100)
                self.LeftSpinner:SetAccel(10)
				
		        DefaultProjectileWeapon.PlayFxRackReloadSequence(self)
	        end,

        },
		
        Turret = Class(DefaultProjectileWeapon) {},
		
		TacticalMissile = Class(AIFMissileTacticalSerpentineWeapon) {
		
            OnLostTarget = function(self)
			
				self.unit.TopLeftDoor:SetGoal(0)
				self.unit.TopRightDoor:SetGoal(0)
				self.unit.BottomLeftDoor:SetGoal(0)
				self.unit.BottomRightDoor:SetGoal(0)
				
                DefaultProjectileWeapon.OnLostTarget(self)
				
            end,

			OnGotTarget = function(self)
			
				self.unit.TopLeftDoor:SetGoal(-90)
				self.unit.TopRightDoor:SetGoal(-90)
				self.unit.BottomLeftDoor:SetGoal(90)
				self.unit.BottomRightDoor:SetGoal(90)
				
				DefaultProjectileWeapon.IdleState.OnGotTarget(self)
			end,
        },
		
        AntiAirMissiles = Class(AAAZealotMissileWeapon) {},		
		
        --CrownArtillery01 = Class(MainGun) {},
        --CrownArtillery02 = Class(MainGun) {},
        --CrownArtillery03 = Class(MainGun) {},
        --CrownArtillery04 = Class(MainGun) {},
		
    },

    OnCreate = function(self, createArgs)

        self.MaelstromFieldName = 'AeonMaelstromBuffField2'
        self.MaelstromFieldRadius = 32
		
		self.Spinner = CreateRotator(self, 'UUX0111_Crown', 'y', nil, 0, 60, 360):SetTargetSpeed(-30)
		
		self.Trash:Add(self.Spinner)

        -- Create missile doors
        self.TopLeftDoor = CreateRotator(self, 'UUX0111_LeftMissileTop', 'x', 0, 90, 360)
        self.TopRightDoor = CreateRotator(self, 'UUX0111_RightMissileTop', 'x', 0, 90, 360)
        self.BottomLeftDoor = CreateRotator(self, 'UUX0111_LeftMissileBottom', 'x', 0, 90, 360)
        self.BottomRightDoor = CreateRotator(self, 'UUX0111_RightMissileBottom', 'x', 0, 90, 360)
	
		ExperimentalMobileUnit.OnCreate(self, createArgs)
	end,
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
		
		-- turn on Maelstrom field --
		self:SetScriptBit('RULEUTC_SpecialToggle',true)
	end,	
	
	OnScriptBitSet = function(self, bit)

        if bit == 7 then

            if self.MaelstromFieldName then
            
                self:SetIntelRadius( 'RadarStealth', self.MaelstromFieldRadius )
                self:SetIntelRadius( 'RadarStealthField', self.MaelstromFieldRadius )
                self:SetIntelRadius( 'SonarStealth', self.MaelstromFieldRadius )
                self:SetIntelRadius( 'SonarStealthField', self.MaelstromFieldRadius )

                self:EnableUnitIntel('RadarStealthField')
                self:EnableUnitIntel('SonarStealthField')

                self:GetBuffFieldByName( self.MaelstromFieldName ):Enable()

                self.MaelstromFieldOn = true
            end
		end
	
	end,
	
	OnScriptBitClear = function(self, bit)

        if bit == 7 then    -- Maelstrom Field

            if self.MaelstromFieldName then
            
                self:SetIntelRadius( 'RadarStealth', 1 )
                self:SetIntelRadius( 'RadarStealthField', 1 )
                self:SetIntelRadius( 'SonarStealth', 1 )
                self:SetIntelRadius( 'SonarStealthField', 1 )

                self:DisableUnitIntel('RadarStealthField')
                self:DisableUnitIntel('SonarStealthField')

                self:GetBuffFieldByName( self.MaelstromFieldName ):Disable()

                self.MaelstromFieldOn = false
            end
		end
	
	end,
	
	CreateExplosionDebris = function( self, army, bone )
	
        for k, v in Death02 do
            CreateAttachedEmitter( self, bone, army, v )
        end
		
    end,
    
}

TypeClass = WEL0405
