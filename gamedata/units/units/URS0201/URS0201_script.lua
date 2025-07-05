local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local CybranWeapons = import('/lua/cybranweapons.lua')

local AA        = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local Cannon    = CybranWeapons.CDFProtonCannonWeapon
local Torpedo   = CybranWeapons.CANNaniteTorpedoWeapon

local AeonWeapons = import('/lua/aeonweapons.lua')
local AntiTorpedo = AeonWeapons.AIFQuasarAntiTorpedoWeapon
local DepthCharge = AeonWeapons.AANDepthChargeBombWeapon

local WeaponsFile = import('/lua/terranweapons.lua')
local SmartCharge = WeaponsFile.TIFSmartCharge

AeonWeapons = nil
CybranWeapons = nil
WeaponsFile = nil

URS0201 = Class(CSeaUnit) {

    SwitchAnims = true,
    Walking = false,
    IsWaiting = false,

    Weapons = {
        ParticleGun     = Class(Cannon) {},
        AAGun           = Class(AA) {},
        DepthCharge     = Class(DepthCharge) {
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(12)
                
                DepthCharge.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( DepthCharge.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(8)
                
                    DepthCharge.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( DepthCharge.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(18) self:ChangeMinRadius(18) WaitTicks(49) self:ChangeMaxRadius(8) self:ChangeMinRadius(0) end)
                    
                    DepthCharge.RackSalvoReloadState.Main(self)

                end,
            },
        },
        Torpedo         = Class(Torpedo) { FxMuzzleFlash = false },
        AntiTorpedo     = Class(AntiTorpedo) {},
        Decoy           = Class(SmartCharge) {},

    },

    OnCreate = function(self)
	
        CSeaUnit.OnCreate(self)

    end,

    OnStopBeingBuilt = function(self,builder,layer)
	
        CSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        -- If created with F2 on land, then play the transform anim.
        if(self:GetCurrentLayer() == 'Land') then
            self.AT1 = self:ForkThread(self.TransformThread, true)
        end
		
    end,

    OnMotionHorzEventChange = function(self, new, old)
	
        CSeaUnit.OnMotionHorzEventChange(self, new, old)
		
        if self:IsDead() then return end
		
        if( not self.IsWaiting ) then
		
            if( self.Walking ) then
			
                if( old == 'Stopped' ) then
				
                    if( self.SwitchAnims ) then
					
                        self.SwitchAnims = false
                        self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationWalk, true):SetRate(self:GetBlueprint().Display.AnimationWalkRate or 1.1)
						
                    else
					
                        self.AnimManip:SetRate(2.8)
						
                    end
					
                elseif( new == 'Stopped' ) then
				
                    self.AnimManip:SetRate(0)
					
                end
				
            end
			
        end
    end,

    OnLayerChange = function(self, new, old)
	
        CSeaUnit.OnLayerChange(self, new, old)
		
        if( old != 'None' ) then
		
            if( self.AT1 ) then
                self.AT1:Destroy()
                self.AT1 = nil
            end
			
            local myBlueprint = self:GetBlueprint()
			
            if( new == 'Land' ) then
			
                self.AT1 = self:ForkThread(self.TransformThread, true)
				
            elseif( new == 'Water' ) then
			
                self.AT1 = self:ForkThread(self.TransformThread, false)
				
            end
			
        end
		
    end,

    TransformThread = function(self, land)
	
        if( not self.AnimManip ) then
            self.AnimManip = CreateAnimator(self)
        end
		
        local bp = self:GetBlueprint()
        local scale = bp.Display.UniformScale or 1

        if( land ) then
            # Change movement speed to the multiplier in blueprint
            self:SetSpeedMult(bp.Physics.LandSpeedMultiplier)
            self:SetImmobile(true)
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationTransform)
            self.AnimManip:SetRate(2)
            self.IsWaiting = true
            WaitFor(self.AnimManip)
            self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0,(bp.CollisionOffsetY + (bp.SizeY*1.0)) or 0,bp.CollisionOffsetZ or 0, bp.SizeX * scale, bp.SizeY * scale, bp.SizeZ * scale )
            self.IsWaiting = false
            self:SetImmobile(false)
            self.SwitchAnims = true
            self.Walking = true
            self.Trash:Add(self.AnimManip)
        else
            self:SetImmobile(true)
            # Revert speed to maximum speed
            self:SetSpeedMult(1)
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationTransform)
            self.AnimManip:SetAnimationFraction(1)
            self.AnimManip:SetRate(-2)
            self.IsWaiting = true
            WaitFor(self.AnimManip)
            self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0,(bp.CollisionOffsetY + (bp.SizeY * 0.5)) or 0,bp.CollisionOffsetZ or 0, bp.SizeX * scale, bp.SizeY * scale, bp.SizeZ * scale )
            self.IsWaiting = false
            self.AnimManip:Destroy()
            self.AnimManip = nil
            self:SetImmobile(false)
            self.Walking = false
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
        self.Trash:Destroy()
        self.Trash = TrashBag()
		
        if(self:GetCurrentLayer() != 'Water') then
		
            self:GetBlueprint().Display.AnimationDeath = self:GetBlueprint().Display.LandAnimationDeath
			
        else
		
            self:GetBlueprint().Display.AnimationDeath = self:GetBlueprint().Display.WaterAnimationDeath
			
        end
		
        CSeaUnit.OnKilled(self, instigator, type, overkillRatio)
		
    end,
    
    DeathThread = function(self, overkillRatio)
	
        if (self:GetCurrentLayer() != 'Water') then
		
            self:PlayUnitSound('Destroyed')
			
            local army = self:GetArmy()
			
            if self.PlayDestructionEffects then
                self:CreateDestructionEffects( self, overkillRatio )
            end

            -- Create Initial explosion effects
            if( self.ShowUnitDestructionDebris and overkillRatio ) then
			
                if overkillRatio <= 1 then
                    self.CreateUnitDestructionDebris( self, true, true, false )
                elseif overkillRatio <= 2 then
                    self.CreateUnitDestructionDebris( self, true, true, false )
                elseif overkillRatio <= 3 then
                    self.CreateUnitDestructionDebris( self, true, true, true )
                else #VAPORIZED
                    self.CreateUnitDestructionDebris( self, true, true, true )
                end
				
            end

            WaitSeconds(1.5)
			
            if self.PlayDestructionEffects then
                self:CreateDestructionEffects( self, overkillRatio )
            end 
			
            WaitSeconds(1)
			
            if self.PlayDestructionEffects then
                self:CreateDestructionEffects( self, overkillRatio )
            end                                    
			
            self:CreateWreckage(0.1)
			
            self:Destroy()
			
        else
		
            CSeaUnit.DeathThread(self, overkillRatio)
			
        end
		
    end,
}

TypeClass = URS0201
