local TMobileFactoryUnit = import('/lua/terranunits.lua').TMobileFactoryUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon  = WeaponsFile.TDFLandGaussCannonWeapon
local TDFRiotWeapon         = WeaponsFile.TDFRiotWeapon
local TAALinkedRailgun      = WeaponsFile.TAALinkedRailgun
local TANTorpedoAngler      = WeaponsFile.TANTorpedoAngler

WeaponsFile = nil

local EffectTemplate = import('/lua/EffectTemplates.lua')

local LOUDINSERT = table.insert
local LOUDSTATE = ChangeState
local WaitFor = WaitFor

UEL0401 = Class(TMobileFactoryUnit) {

    Weapons = {
	
        Turret  = Class(TDFGaussCannonWeapon) {},
		
        Riotgun = Class(TDFRiotWeapon) { FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank },
		
        AAGun   = Class(TAALinkedRailgun) {},

        Torpedo = Class(TANTorpedoAngler) {},
    },

    FxDamageScale = 2.5,
    PrepareToBuildAnimRate = 5,
    BuildAttachBone = 'Build_Attachpoint',

    RollOffBones = { 'Arm_Right03_Build_Emitter', 'Arm_Left03_Build_Emitter',},

    OnStopBeingBuilt = function(self,builder,layer)
        TMobileFactoryUnit.OnStopBeingBuilt(self,builder,layer)
        self.EffectsBag = {}
        self.PrepareToBuildManipulator = CreateAnimator(self)
        self.PrepareToBuildManipulator:PlayAnim(self:GetBlueprint().Display.AnimationBuild, false):SetRate(0)
        self.ReleaseEffectsBag = {}
        self.AttachmentSliderManip = CreateSlider(self, self.BuildAttachBone)
        LOUDSTATE(self, self.IdleState)
    end,

    OnFailedToBuild = function(self)
        TMobileFactoryUnit.OnFailedToBuild(self)
        LOUDSTATE(self, self.IdleState)
    end,

    OnLayerChange = function(self, new, old)
        TMobileFactoryUnit.OnLayerChange(self, new, old)
        if new == 'Land' then
            self:RestoreBuildRestrictions()
            self:RequestRefreshUI()
        elseif new == 'Seabed' then
            self:AddBuildRestriction(categories.ALLUNITS)
            self:RequestRefreshUI()         
        end
    end,

    IdleState = State {
        OnStartBuild = function(self, unitBuilding, order)
            --self:SetBusy(true)
            TMobileFactoryUnit.OnStartBuild(self, unitBuilding, order)
            self.UnitBeingBuilt = unitBuilding
            self.PrepareToBuildManipulator:SetRate(self.PrepareToBuildAnimRate)
            LOUDSTATE(self, self.BuildingState)
        end,

        Main = function(self)
            self.PrepareToBuildManipulator:SetRate(-self.PrepareToBuildAnimRate)
            self:DetachAll(self.BuildAttachBone)
            --self:SetBusy(false)
        end,

    },


    BuildingState = State {

        Main = function(self)
            local unitBuilding = self.UnitBeingBuilt
            self.PrepareToBuildManipulator:SetRate(self.PrepareToBuildAnimRate)
            local bone = self.BuildAttachBone
            self:DetachAll(bone)
            if not self.UnitBeingBuilt:IsDead() then
                unitBuilding:AttachBoneTo( -2, self, bone )
                local unitHeight = unitBuilding:GetBlueprint().SizeY
                self.AttachmentSliderManip:SetGoal(0, unitHeight, 0 )
                self.AttachmentSliderManip:SetSpeed(-1)
                unitBuilding:HideBone(0,true)
            end
            WaitSeconds(3)
            unitBuilding:ShowBone(0,true)
            WaitFor( self.PrepareToBuildManipulator )
            local unitBuilding = self.UnitBeingBuilt
            self.UnitDoneBeingBuilt = false
        end,

        OnStopBuild = function(self, unitBeingBuilt)
            TMobileFactoryUnit.OnStopBuild(self, unitBeingBuilt)

            LOUDSTATE(self, self.RollingOffState)
        end,

    },

    RollingOffState = State {

        Main = function(self)
            local unitBuilding = self.UnitBeingBuilt
            if not unitBuilding:IsDead() then
                unitBuilding:ShowBone(0,true)
            end
            WaitFor(self.PrepareToBuildManipulator)
            WaitFor(self.AttachmentSliderManip)
            self:CreateRollOffEffects()
            self.AttachmentSliderManip:SetSpeed(10)
            self.AttachmentSliderManip:SetGoal(0, 0, 17)
            WaitFor( self.AttachmentSliderManip )
            self.AttachmentSliderManip:SetGoal(0, -3, 17)
            WaitFor( self.AttachmentSliderManip )
            if not unitBuilding:IsDead() then
                unitBuilding:DetachFrom(true)
                self:DetachAll(self.BuildAttachBone)
                local  worldPos = self:CalculateWorldPositionFromRelative({0, 0, -15})
                IssueMoveOffFactory({unitBuilding}, worldPos)
            end
            self:DestroyRollOffEffects()
            LOUDSTATE(self, self.IdleState)
        end,
    },

    CreateRollOffEffects = function(self)
        local army = self:GetArmy()
        local unitB = self.UnitBeingBuilt
        
        for _, v in self.RollOffBones do
            local fx = AttachBeamEntityToEntity(self, v, unitB, -1, army, EffectTemplate.TTransportBeam01)
            LOUDINSERT( self.ReleaseEffectsBag, fx)
            self.Trash:Add(fx)
            fx = AttachBeamEntityToEntity( unitB, -1, self, v, army, EffectTemplate.TTransportBeam02)
            LOUDINSERT( self.ReleaseEffectsBag, fx)
            self.Trash:Add(fx)
            fx = CreateEmitterAtBone( self, v, army, EffectTemplate.TTransportGlow01)
            LOUDINSERT( self.ReleaseEffectsBag, fx)
            self.Trash:Add(fx)
        end
    end,

    DestroyRollOffEffects = function(self)
        for _, v in self.ReleaseEffectsBag do
            v:Destroy()
        end
        self.ReleaseEffectsBag = {}
    end,

}

TypeClass = UEL0401