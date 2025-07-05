local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')
local AntiTorpedo = AeonWeapons.AIFQuasarAntiTorpedoWeapon

local WeaponFile = import('/lua/terranweapons.lua')

local Railgun = WeaponFile.TAALinkedRailgun
local Cannon  = WeaponFile.TDFGaussCannonWeapon
local Torpedo = WeaponFile.TANTorpedoAngler

AeonWeapons = nil
WeaponFile = nil

local WaitFor = WaitFor

UES0201 = Class(TSeaUnit) {

    DestructionTicks = 200,

    Weapons = {
	
        TurretF     = Class(Cannon) {},
        TurretB     = Class(Cannon) {},
        AATurret    = Class(Railgun) {},
        Torpedo     = Class(Torpedo) { FxMuzzleFlash = false },
        AntiTorpedo = Class(AntiTorpedo) {},
    },

    RadarThread = function(self)
	
        local spinner = CreateRotator(self, 'Spinner02', 'x', nil, 0, 90, -90)

        self.Trash:Add(spinner)
		
        while true do
            WaitFor(spinner)
            spinner:SetTargetSpeed(90)
            WaitFor(spinner)
            spinner:SetTargetSpeed(-90)
        end
		
    end,

    OnStopBeingBuilt = function(self,builder,layer)
	
        TSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.Trash:Add(CreateRotator(self, 'Spinner01', 'y', nil, 180, 0, 180))
		
        self:ForkThread(self.RadarThread)
		
        self:HideBone( 'Back_Turret02', true )
		
    end,
	
}

TypeClass = UES0201