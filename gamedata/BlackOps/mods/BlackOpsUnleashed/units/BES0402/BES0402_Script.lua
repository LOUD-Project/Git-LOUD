local TSeaUnit = import('/lua/terranunits.lua').TSeaUnit

local ZCannonWeapon = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').ZCannonWeapon

local TDFShipGaussCannonWeapon = import('/lua/terranweapons.lua').TDFShipGaussCannonWeapon
local TAALinkedRailgun = import('/lua/terranweapons.lua').TAALinkedRailgun

local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BES0402 = Class(TSeaUnit) {

	SteamEffects = BlackOpsEffectTemplate.WeaponSteam02,

    Weapons = {
	
    	FrontAMCCannon01 = Class(ZCannonWeapon) {
		
			PlayFxRackSalvoReloadSequence = function(self)
			
				for i = 1, 40 do
				
					local fxname
					
					if i < 10 then
						fxname = 'AMC1Steam0' .. i
					else
						fxname = 'AMC1Steam' .. i
					end
					
					local CreateAttachedEmitter = CreateAttachedEmitter
					
					for k, v in self.unit.SteamEffects do
					
						table.insert( self.unit.SteamEffectsBag, CreateAttachedEmitter( self.unit, fxname, self.unit:GetArmy(), v ))
						
					end
					
				end
				
				ZCannonWeapon.PlayFxRackSalvoChargeSequence(self)
				
			end,
		},
		
        FrontAMCCannon02 = Class(ZCannonWeapon) {
		
			PlayFxRackSalvoReloadSequence = function(self)
			
				for i = 1, 40 do
				
					local fxname
					
					if i < 10 then
						fxname = 'AMC2Steam0' .. i
					else
						fxname = 'AMC2Steam' .. i
					end
					
					local CreateAttachedEmitter = CreateAttachedEmitter
					
					for k, v in self.unit.SteamEffects do
						table.insert( self.unit.SteamEffectsBag, CreateAttachedEmitter( self.unit, fxname, self.unit:GetArmy(), v ))
					end
					
				end
				
                ZCannonWeapon.PlayFxRackSalvoChargeSequence(self)
				
            end,
		},
		
        BackAMCCannon = Class(ZCannonWeapon) {
		
			PlayFxRackSalvoReloadSequence = function(self)
			
				for i = 1, 40 do
				
					local fxname
					
					if i < 10 then
						fxname = 'AMC3Steam0' .. i
					else
						fxname = 'AMC3Steam' .. i
					end
					
					local CreateAttachedEmitter = CreateAttachedEmitter
					
					for k, v in self.unit.SteamEffects do
						table.insert( self.unit.SteamEffectsBag, CreateAttachedEmitter( self.unit, fxname, self.unit:GetArmy(), v ))
					end
					
				end
				
                ZCannonWeapon.PlayFxRackSalvoChargeSequence(self)
				
            end,
		},
		
        AAGun = Class(TAALinkedRailgun) {},

        Deckgun = Class(TDFShipGaussCannonWeapon) {},

    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        TSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.Trash:Add(CreateRotator(self, 'Spinner01', 'y', nil, -45))
        self.Trash:Add(CreateRotator(self, 'Spinner02', 'y', nil, 90))
		
		self.SteamEffectsBag = {}
    end,
}

TypeClass = BES0402