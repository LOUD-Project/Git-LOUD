--  Summary  :  Cybran Destroyer Script

local CSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local CybranWeapons = import('/lua/cybranweapons.lua')

local CAAAutocannon             = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CANNaniteTorpedoWeapon    = CybranWeapons.CANNaniteTorpedoWeapon
local CIFSmartCharge            = CybranWeapons.CIFSmartCharge

CybranWeapons = nil

local BrewLANLOUDPath = import( '/lua/game.lua' ).BrewLANLOUDPath()
local AssistThread = import(BrewLANLOUDPath .. '/lua/fieldengineers.lua').AssistThread
local EffectUtil = import('/lua/EffectUtilities.lua')

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

SRS0319 = Class(CSeaUnit) {
    SwitchAnims = true,
    Walking = false,
    IsWaiting = false,

    Weapons = {
        AAGun = Class(CAAAutocannon) {},
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
        AntiTorpedo = Class(CIFSmartCharge) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
        CSeaUnit.OnStopBeingBuilt(self,builder,layer)
        -- If created with F2 on land, then play the transform anim.
        if(self:GetCurrentLayer() == 'Land') then
            self.AT1 = self:ForkThread(self.TransformThread, true)
        end
        self:ForkThread(AssistThread)
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,
    
    OnStopBuild = function(self, unitBeingBuilt)
    
        if self.Dead then return end

        -- reattach the permanent projectile
        for _, v in self.BuildProjectile do 
        
            TrashDestroy ( v.BuildEffectsBag )
        
            if v.Detached then
                v:AttachTo( self, v.Name )
            end
            
            v.Detached = false
            
            -- and scale down the emitters
            v.Emitter:ScaleEmitter(0.05)
            v.Sparker:ScaleEmitter(0.05)
        end
        
        CSeaUnit.OnStopBuild(self, unitBeingBuilt)
        
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
            -- Change movement speed to the multiplier in blueprint
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
            -- Revert speed to maximum speed
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
                else --VAPORIZED
                    self.CreateUnitDestructionDebris( self, true, true, true )
                end
            end

            WaitSeconds(2)
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

TypeClass = SRS0319
