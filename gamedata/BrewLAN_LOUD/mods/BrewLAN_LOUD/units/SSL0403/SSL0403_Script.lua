--------------------------------------------------------------------------------
--  Summary:  Iyadesu Script
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
local SConstructionUnit = import('/lua/seraphimunits.lua').SConstructionUnit

local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local EffectUtil = import('/lua/EffectUtilities.lua')

local SDFUltraChromaticBeamGenerator = import('/lua/seraphimweapons.lua').SDFUltraChromaticBeamGenerator

local tablefind = table.find -- local this to lower the overhead slightly.
local BrewLANLOUDPath = import('/lua/game.lua').BrewLANLOUDPath()
local VersionIsFAF = import(BrewLANLOUDPath .. "/lua/legacy/versioncheck.lua").VersionIsFAF()

SSL0403 = Class(SConstructionUnit) {

    Weapons = {
        MainTurret = Class(SDFUltraChromaticBeamGenerator) {},
    },

    OnCreate = function(self)

        SConstructionUnit.OnCreate(self)

        self:CreateIdleEffects()
        self:AddBuildRestriction(categories.SELECTABLE)
        self.Pods = { }

        local pod = {
            PodAttachpoint = 'AttachSpecial0',
            PodName = 'Pod',
            PodUnitID = 'SSA0001',
            Entity = {},
            Active = false,
        }

        for i = 1, 8 do
            self.Pods[i] = {}
            for k, v in pod do
                if k == "PodAttachpoint" or k == "PodName" then
                    self.Pods[i][k] = v .. tostring(i)
                else
                    self.Pods[i][k] = v
                end
            end
        end
    end,

    OnStopBeingBuilt = function(self, ...)
        SConstructionUnit.OnStopBeingBuilt(self, unpack(arg) )
        self:MoveArms(0)
    end,

    StartBeingBuiltEffects = function(self, builder, layer)
        SConstructionUnit.StartBeingBuiltEffects(self, builder, layer)
        self:ForkThread( EffectUtil.CreateSeraphimExperimentalBuildBaseThread, builder, self.OnBeingBuiltEffectsBag )
    end,

    OnStartReclaim = function(self, target)
        local TargetId = target.AssociatedBP or target:GetBlueprint().BlueprintId
        if TargetId and not string.find(TargetId, "/") then
            self.ReclaimID = {id = TargetId}
        elseif target:GetBlueprint().AssociatedBP then
            self.ReclaimID = {id = target:GetBlueprint().AssociatedBP}
        end
        self:MoveArms()
        SConstructionUnit.OnStartReclaim(self, target)
    end,

    OnStopReclaim = function(self, target)
        if not target and self.ReclaimID.id then
            self:CreatePod(self.ReclaimID.id)
        end
        self.ReclaimID = {}
        self:MoveArms(0)
        SConstructionUnit.OnStopReclaim(self, target)
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        SConstructionUnit.OnStartBuild(self, unitBeingBuilt, order)
        self:MoveArms(100)
    end,

    OnStopBuild = function(self)
        SConstructionUnit.OnStopBuild(self)
        self:MoveArms(0)
    end,

    OnProductionPaused = function(self)
        self:MoveArms(0)
        SConstructionUnit.OnProductionPaused(self)
    end,

    OnProductionUnpaused = function(self)
        self:MoveArms(100)
        SConstructionUnit.OnProductionUnpaused(self)
    end,

    MoveArms = function(self, num)
        if self.SARotators then
            for i = 1, 6 do
                self.SARotators[i]:SetGoal(- (num or 100) + math.random(0,30))
            end
        else
            self.SARotators = {}
            for i = 1, 6 do
                self.SARotators[i] = CreateRotator(self, 'Small_Blade_00' .. i, 'x', - (num or 100) + math.random(0,30), 300, 100)
            end
        end
    end,

    CheckBuildRestrictionsAllow = function(self, WorkID)
	
        local Restrictions = ScenarioInfo.Options.RestrictedCategories or false
		
        if not Restrictions or (Restrictions and table.getn(Restrictions) == 0) then
		
            return true
			
        elseif VersionIsFAF then
		
            return not import('/lua/game.lua').IsRestricted(WorkID)
			
        else
		
            LOG("Checking we aren't being a cheatyface")
			
            local restrictedData = import('/lua/ui/lobby/restrictedunitsdata.lua').restrictedUnits
			
            for i, group in Restrictions do
                for j, cat in restrictedData[group].categories do --
                    if WorkID == cat or tablefind(__blueprints[WorkID].Categories, cat) then
                        return false
                    end
                end
            end
			
        end
		
        return true
    end,
	
    CreatePod = function(self, WorkID)
	
        --This first section is for compatibility with R&D.
        if tablefind(__blueprints[WorkID].Categories, 'SELECTABLE') and (tablefind(__blueprints[WorkID].Categories, 'TECH1') or tablefind(__blueprints[WorkID].Categories, 'TECH2') or tablefind(__blueprints[WorkID].Categories, 'TECH3') or tablefind(__blueprints[WorkID].Categories, 'EXPERIMENTAL')) and self:CheckBuildRestrictionsAllow(WorkID) then
            if true then --[TO DO!!!] MAKE SURE THIS ISN'T AGAINST BUILD RESTRICTIONS!!
                RemoveBuildRestriction(self:GetArmy(), categories[WorkID] )
            end
        end
		
        --And now regular stuff
        self:RemoveBuildRestriction(categories[WorkID])
		
        if self:CanBuild(WorkID) then
		
            for i, pod in self.Pods do
			
                if not pod.Active then
				
                    local location = self:GetPosition(pod.PodAttachpoint)
					
                    pod.Entity = CreateUnitHPR(pod.PodUnitID, self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
                    pod.StorageID = WorkID
                    pod.Active = true
                    pod.Entity:SetCustomName(LOC(__blueprints[WorkID].Description))
                    pod.Entity:SetParent(self, i)
                    pod.Entity:SetCreator(self)
					
                    break
					
                end
				
            end
        end
        self:RefreshBuildRestrictions()
    end,

    NotifyOfPodDeath = function(self, pod)
        self.Pods[pod].Active = false
        self.Pods[pod].StorageID = nil
        self:RefreshBuildRestrictions()
    end,

    RefreshBuildRestrictions = function(self)
        self:RestoreBuildRestrictions()
        self:AddBuildRestriction(categories.SELECTABLE)
        for i, pod in self.Pods do
            if pod.StorageID then
                self:RemoveBuildRestriction(categories[pod.StorageID])
            end
        end
        self:RequestRefreshUI()
    end,

    OnMotionHorzEventChange = function( self, new, old )
        SConstructionUnit.OnMotionHorzEventChange(self, new, old)

        if ( old == 'Stopped' ) then
            if (not self.Animator) then
                self.Animator = CreateAnimator(self, true)
            end
            local bpDisplay = self:GetBlueprint().Display
            if bpDisplay.AnimationWalk then
                self.Animator:PlayAnim(bpDisplay.AnimationWalk, true)
                self.Animator:SetRate(bpDisplay.AnimationWalkRate or 1)
            end
        elseif ( new == 'Stopped' ) then
            -- only keep the animator around if we are dying and playing a death anim
            -- or if we have an idle anim
            if(self.IdleAnim and not self.Dead) then
                self.Animator:PlayAnim(self.IdleAnim, true)
            elseif(not self.DeathAnim or not self.Dead) then
                self.Animator:Destroy()
                self.Animator = false
            end
        end
    end,
}

TypeClass = SSL0403
