local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local BFGShellWeapon = import('/mods/4DC/lua/4D_weapons.lua').BFGShellWeapon

local CreateAttachedEmitter = CreateAttachedEmitter
local ScaleEmitter = moho.IEffect.ScaleEmitter

local LOUDINSERT = table.insert

local TrashAdd = TrashBag.Add

UAB2306 = Class(AStructureUnit) {

    Weapons = {

		BFG = Class(BFGShellWeapon) {

            PlayFxMuzzleChargeSequence = function(self, muzzle)
                self.unit:AddBeamFX()
                BFGShellWeapon.PlayFxMuzzleChargeSequence(self, muzzle)
            end,                

            PlayFxRackReloadSequence = function(self)          
                self.unit:RemoveBeamFX() 
                BFGShellWeapon.PlayFxRackReloadSequence(self)             
            end,

            OnLostTarget = function(self)
                self.unit:RemoveBeamFX() 
                BFGShellWeapon.OnLostTarget(self)                
            end,             			
        },
    },       

    OnStopBeingBuilt = function(self, builder, layer)
    
        AStructureUnit.OnStopBeingBuilt(self, builder, layer)

        self.SphereFxBag = {}
        self.BeamFxBag = {}

        self.FxStatus = false

        self:InitializeFX()                
    end,
    
    InitializeFX = function(self)

        TrashAdd( self.Trash, CreateRotator(self, 'beam_emitter', 'z', nil, 0, 15, 80) )

        self:HideBone('sphere', true)
        
        local Army = self.Sync.army

        local FX1 = CreateAttachedEmitter(self, 'sphere', Army, '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_02_emit.bp'):ScaleEmitter(0.5)-- Bright Blue Glow                      
        local FX2 = CreateAttachedEmitter(self, 'sphere', Army, '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_03_emit.bp'):ScaleEmitter(0.4)-- Dark FX Aura                             
        local FX3 = CreateAttachedEmitter(self, 'sphere', Army, '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_06_emit.bp'):ScaleEmitter(0.25)-- Electricity Sphere Aura 

        LOUDINSERT(self.SphereFxBag, FX1)
        LOUDINSERT(self.SphereFxBag, FX2)
        LOUDINSERT(self.SphereFxBag, FX3)             

        self.Trash:Add(FX1, FX2, FX3)                                              

        TrashAdd( self.Trash, AttachBeamEntityToEntity(self, 'beam_point01', self, 'sphere', Army, '/mods/4DC/effects/Emitters/bfg_fx_02_beam_emit.bp')) -- Small Energy Beams
        TrashAdd( self.Trash, AttachBeamEntityToEntity(self, 'beam_point02', self, 'sphere', Army, '/mods/4DC/effects/Emitters/bfg_fx_02_beam_emit.bp')) -- Small Energy Beams               
        TrashAdd( self.Trash, AttachBeamEntityToEntity(self, 'beam_point03', self, 'sphere', Army, '/mods/4DC/effects/Emitters/bfg_fx_02_beam_emit.bp')) -- Small Energy Beams     
    end,

    AddBeamFX = function(self)

        if self.FxStatus == false then

            self.FxStatus = true
            
            local FX1 = AttachBeamEntityToEntity(self, 'sphere', self, 'beam_emitter', self.Sync.army, '/mods/4DC/effects/Emitters/bfg_fx_01_beam_emit.bp') -- Large Energy Beams     
            local FX2 = CreateAttachedEmitter(self, 'sphere', self.Sync.army, '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_05_emit.bp'):ScaleEmitter(0.4) -- Random Arc Effects  

            LOUDINSERT(self.BeamFxBag, FX1)
            LOUDINSERT(self.BeamFxBag, FX2)

            self.Trash:Add(FX1, FX2)

            ScaleEmitter( self.SphereFxBag[1], 0.75)
            ScaleEmitter( self.SphereFxBag[2], 0.6)
            ScaleEmitter( self.SphereFxBag[3], 0.5)           
        end
    end,     
    
    RemoveBeamFX = function(self)

        if self.FxStatus == true then
        
            self.FxStatus = false

            if self.BeamFxBag then            
                for k, v in self.BeamFxBag do
                    v:Destroy()
                end
                self.BeamEffectsBag = {}    
            end
            
            ScaleEmitter( self.SphereFxBag[1], 0.5)
            ScaleEmitter( self.SphereFxBag[2], 0.4)
            ScaleEmitter( self.SphereFxBag[3], 0.25)                       
        end
    end,

    OnDestroy = function(self)

        if self.FxStatus then
            self:RemoveBeamFX() 
        end

		if self.SphereFxBag then
			for k, v in self.SphereFxBag do
				v:Destroy()
			end
		end

    	if self.Trash then
            self.Trash:Destroy()
        end
    end,
}
TypeClass = UAB2306