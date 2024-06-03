local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')
local AIFQuasarAntiTorpedoWeapon = AeonWeapons.AIFQuasarAntiTorpedoWeapon

local WeaponFile = import('/lua/terranweapons.lua')

local TAALinkedRailgun      = WeaponFile.TAALinkedRailgun
local TDFGaussCannonWeapon  = WeaponFile.TDFGaussCannonWeapon
local TANTorpedoAngler      = WeaponFile.TANTorpedoAngler
local TIFSmartCharge        = WeaponFile.TIFSmartCharge

AeonWeapons = nil
WeaponFile = nil

local WaitFor = WaitFor

UES0201 = Class(TSeaUnit) {

    DestructionTicks = 200,

    Weapons = {
	
        Turret = Class(TDFGaussCannonWeapon) {},
        AATurret = Class(TAALinkedRailgun) {},
        Torpedo = Class(TANTorpedoAngler) {},
        AntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},
		
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