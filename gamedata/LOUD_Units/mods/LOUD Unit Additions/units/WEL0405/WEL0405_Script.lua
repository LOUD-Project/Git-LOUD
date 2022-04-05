local ExperimentalMobileUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local DefaultProjectileWeapon = import('/lua/sim/defaultweapons.lua').DefaultProjectileWeapon

local AIFMissileTacticalSerpentineWeapon = import('/lua/aeonweapons.lua').AIFMissileTacticalSerpentineWeapon
local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

local Buff = import('/lua/sim/Buff.lua')
local AeonBuffField = import('/lua/aeonweapons.lua').AeonBuffField

--local TurretWeapon = import('/lua/sim/weapon.lua').Weapon

--[[
local function PassData(self, proj)
    local data = {
        Radius = self:GetBlueprint().CameraVisionRadius or 5,
        Lifetime = self:GetBlueprint().CameraLifetime or 5,
        Army = self.unit:GetArmy(),
    }
    if proj and not proj:BeenDestroyed() then
        proj:PassData(data)
    end
end

local MainGun = Class(DefaultProjectileWeapon) {
    CreateProjectileAtMuzzle = function(self, muzzle)
		PassData( self, DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle) )
    end,
}
--]]

WEL0405 = Class(ExperimentalMobileUnit) {

	BuffFields = {
	
		RegenField = Class(AeonBuffField){
		
			OnCreate = function(self)
				AeonBuffField.OnCreate(self)
			end,
		},
	},
    
    Weapons = {
	
        --BodyYaw = Class(TurretWeapon) {},
		
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
	
		ExperimentalMobileUnit.OnCreate(self, createArgs)
		
		self.Spinner = CreateRotator(self, 'UUX0111_Crown', 'y', nil, 0, 60, 360):SetTargetSpeed(-30)
		
		self.Trash:Add(self.Spinner)

        -- Create missile doors
        self.TopLeftDoor = CreateRotator(self, 'UUX0111_LeftMissileTop', 'x', 0, 90, 360)
        self.TopRightDoor = CreateRotator(self, 'UUX0111_RightMissileTop', 'x', 0, 90, 360)
        self.BottomLeftDoor = CreateRotator(self, 'UUX0111_LeftMissileBottom', 'x', 0, 90, 360)
        self.BottomRightDoor = CreateRotator(self, 'UUX0111_RightMissileBottom', 'x', 0, 90, 360)
		
	end,
	
	OnStopBeingBuilt = function(self,builder,layer)

		self.MaelstromEffects01 = {}
		
		if self.MaelstromEffects01 then
		
			for k, v in self.MaelstromEffects01 do
				v:Destroy()
			end
			
			self.MaelstromEffects01 = {}
			
		end
        
        local army = self:GetArmy()
		
		local LOUDINSERT = table.insert
		local LOUDATTACHEMITTER = CreateAttachedEmitter

		LOUDINSERT( self.MaelstromEffects01, LOUDATTACHEMITTER( self, 'UUX0111_Pelvis', army, '/mods/BlackopsUnleashed/effects/emitters/genmaelstrom_aura_02_emit.bp' ):ScaleEmitter(1):OffsetEmitter(0, -2.75, 0) )
		
		ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
		
		-- we're not really cloaking so turn this off
		-- we just use the CloakField radius to show the area of effect
		self:DisableUnitIntel('CloakField')
		
		-- turn on Maelstrom field --
		self:SetScriptBit('RULEUTC_ShieldToggle',true)
	end,	
	
	OnScriptBitSet = function(self, bit)
	
		if bit == 0 then
			self:GetBuffFieldByName('AeonMaelstromBuffField2'):Enable()
		end
	
	end,
	
	OnScriptBitClear = function(self, bit)
	
		if bit == 0 then
			self:GetBuffFieldByName('AeonMaelstromBuffField2'):Disable()
		end
	
	end,
	
	CreateExplosionDebris = function( self, army, bone )
	
        for k, v in Death02 do
            CreateAttachedEmitter( self, bone, army, v )
        end
		
    end,
    
}

TypeClass = WEL0405
