
local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit
local BFGShellWeapon = import('/mods/4DC/lua/4D_weapons.lua').BFGShellWeapon

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
        -- Initialize FX tables
        self.SphereFxBag = {}
        self.BeamFxBag = {}
        -- Prevents the FX from being toggled twice
        self.FxStatus = false
        -- Start FX   
        self:InitializeFX()                
    end,
    
    InitializeFX = function(self)
		-- Beam emitter rotator
        self.Trash:Add(CreateRotator(self, 'beam_emitter', 'z', nil, 0, 15, 80))
		-- Hide unwanted bones
        self:HideBone('sphere', true)
		-- Sphere energy effects      
        local FX1 = CreateAttachedEmitter(self, 'sphere', self:GetArmy(), '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_02_emit.bp'):ScaleEmitter(0.5)-- Bright Blue Glow                      
        local FX2 = CreateAttachedEmitter(self, 'sphere', self:GetArmy(), '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_03_emit.bp'):ScaleEmitter(0.4)-- Dark FX Aura                             
        local FX3 = CreateAttachedEmitter(self, 'sphere', self:GetArmy(), '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_06_emit.bp'):ScaleEmitter(0.25)-- Electricity Sphere Aura 
		-- Save FX into table for later use
        table.insert(self.SphereFxBag, FX1)
        table.insert(self.SphereFxBag, FX2)
        table.insert(self.SphereFxBag, FX3)             
		-- Clean up       
        self.Trash:Add(FX1, FX2, FX3)                                              
		-- Minor Beam FX
        self.Trash:Add(AttachBeamEntityToEntity(self, 'beam_point01', self, 'sphere', self:GetArmy(), '/mods/4DC/effects/Emitters/bfg_fx_02_beam_emit.bp')) -- Small Energy Beams                
        self.Trash:Add(AttachBeamEntityToEntity(self, 'beam_point02', self, 'sphere', self:GetArmy(), '/mods/4DC/effects/Emitters/bfg_fx_02_beam_emit.bp')) -- Small Energy Beams               
        self.Trash:Add(AttachBeamEntityToEntity(self, 'beam_point03', self, 'sphere', self:GetArmy(), '/mods/4DC/effects/Emitters/bfg_fx_02_beam_emit.bp')) -- Small Energy Beams     
    end,

    AddBeamFX = function(self)
        -- LOG('AddBeamFX')
        if self.FxStatus == false then
			-- Add large Beam FX
            self.FxStatus = true
            local FX1 = AttachBeamEntityToEntity(self, 'sphere', self, 'beam_emitter', self:GetArmy(), '/mods/4DC/effects/Emitters/bfg_fx_01_beam_emit.bp') -- Large Energy Beams     
            local FX2 = CreateAttachedEmitter(self, 'sphere', self:GetArmy(), '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_05_emit.bp'):ScaleEmitter(0.4) -- Random Arc Effects  
			-- Save FX into table for later use            
            table.insert(self.BeamFxBag, FX1)
            table.insert(self.BeamFxBag, FX2)
			-- Clean up                          
            self.Trash:Add(FX1, FX2)
			-- Increase the Sphere FX sizes during Charge Sequence
            self.SphereFxBag[1]:ScaleEmitter(0.75)
            self.SphereFxBag[2]:ScaleEmitter(0.6)
            self.SphereFxBag[3]:ScaleEmitter(0.5)           
        end
    end,     
    
    RemoveBeamFX = function(self)
	
        BFGShellWeapon.OnLostTarget(self)
        -- LOG('RemoveBeamFX')
        if self.FxStatus == true then
            self.FxStatus = false
			-- Remove large beam FX
            if self.BeamFxBag then            
                for k, v in self.BeamFxBag do
                    v:Destroy()
                end
                self.BeamEffectsBag = {}    
            end
			-- Reset the Sphere FX sizes after Charge Sequence
            self.SphereFxBag[1]:ScaleEmitter(0.5)
            self.SphereFxBag[2]:ScaleEmitter(0.4)
            self.SphereFxBag[3]:ScaleEmitter(0.25)                            
        end
    end,

    OnDestroy = function(self)
		-- Remove all Beam FX
        if self.FxStatus then
            self:RemoveBeamFX() 
        end
		-- Remove all Sphere FX
		if self.SphereFxBag then
			for k, v in self.SphereFxBag do
				v:Destroy()
			end
		end
		-- Remove trash               
    	if self.Trash then
            self.Trash:Destroy()
        end
    end,
}
TypeClass = UAB2306