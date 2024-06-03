local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

SEB2308 = Class(TStructureUnit) {

    UpsideDown = false,

    Weapons = {
        Torpedo = Class(TANTorpedoAngler) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		TStructureUnit.OnStopBeingBuilt(self,builder,layer)

        -- if built in water - turn on torp defense - turn off normal vision
        if layer == 'Sub' or layer == 'Seabed' or layer == 'Water' then
        
            -- create Torp Defense emitter
            local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
            for _,v in bp.AttachBone do

                local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

                TrashAdd( self.Trash, antiMissile1)

            end
            
            bp = __blueprints[self.BlueprintID].Intel
            
            if layer == 'Seabed' then
                self:SetIntelRadius( 'Vision', bp.VisionRadius * 0.5 )
            end
        
        -- if not built in water, turn off watervision
        else
            self:SetIntelRadius( 'WaterVision', 4 )
        end

	end,

    HideLandBones = function(self)

        local pos = self:GetPosition()

        if pos[2] == GetTerrainHeight(pos[1],pos[3]) then
            for k, v in self.LandBuiltHiddenBones do
                if self:IsValidBone(v) then
                    self:HideBone(v, true)
                end
            end
        end

    end,
}

TypeClass = SEB2308
