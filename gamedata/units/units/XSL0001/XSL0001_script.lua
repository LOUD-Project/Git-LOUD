local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local Buff = import('/lua/sim/Buff.lua')
local BuffField = import('/lua/sim/BuffField.lua').BuffField

local SWeapons = import('/lua/seraphimweapons.lua')

local SDFChronotronCannonWeapon             = SWeapons.SDFChronotronCannonWeapon
local SDFChronotronOverChargeCannonWeapon   = SWeapons.SDFChronotronCannonOverChargeWeapon
local SIFCommanderDeathWeapon               = SWeapons.SIFCommanderDeathWeapon
local SIFLaanseTacticalMissileLauncher      = SWeapons.SIFLaanseTacticalMissileLauncher

SWeapons = nil,

local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

local AIUtils = import('/lua/ai/aiutilities.lua')

-- Setup as RemoteViewing child unit rather than SWalkingLandUnit
local RemoteViewing = import('/lua/RemoteViewing.lua').RemoteViewing

SWalkingLandUnit = RemoteViewing( SWalkingLandUnit ) 

XSL0001 = Class( SWalkingLandUnit ) {
    DeathThreadDestructionWaitTime = 2,
	
	BuffFields = {

		RegenField = Class(BuffField){},
		AdvancedRegenField = Class(BuffField){

            OnPreUnitEntersField = function(self, unit)
                SeraphimBuffField.OnPreUnitEntersField(self, unit)
                return (unit:GetHealth() / unit:GetMaxHealth())
            end,

            OnUnitEntersField = function(self, unit, OnPreUnitEntersFieldData)
                SeraphimBuffField.OnUnitEntersField(self, unit, OnPreUnitEntersFieldData)
                unit:SetHealth(unit, (OnPreUnitEntersFieldData * unit:GetMaxHealth()))
            end,

            OnPreUnitLeavesField = function(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData)
                SeraphimBuffField.OnPreUnitLeavesField(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData)
                return (unit:GetHealth() / unit:GetMaxHealth())
            end,

            OnUnitLeavesField = function(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData, OnPreUnitLeavesField)
                SeraphimBuffField.OnUnitLeavesField(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData, OnPreUnitLeavesField)
                unit:SetHealth(unit, (OnPreUnitLeavesField * unit:GetMaxHealth()))
            end,        
        },
	},
	
    Weapons = {
        DeathWeapon = Class(SIFCommanderDeathWeapon) {},
        
        ChronotronCannon = Class(SDFChronotronCannonWeapon) {
            OnCreate = function(self)
                SDFChronotronCannonWeapon.OnCreate(self)
                self.DamageMod = 0
                self.DamageRadiusMod = 0
            end,
        },
        
        Missile = Class(SIFLaanseTacticalMissileLauncher) {
            OnCreate = function(self)
                SIFLaanseTacticalMissileLauncher.OnCreate(self)
                self:SetWeaponEnabled(false)
            end,
        },
		
        OverCharge = Class(SDFChronotronOverChargeCannonWeapon) {

            OnCreate = function(self)

                SDFChronotronOverChargeCannonWeapon.OnCreate(self)

                self:SetWeaponEnabled(false)

                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)

				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)

                if self:BeenDestroyed() then return end

                SDFChronotronOverChargeCannonWeapon.OnEnableWeapon(self)

                self:SetWeaponEnabled(true)

                --self.unit:SetWeaponEnabledByLabel('ChronotronCannon', false)

                self.unit:BuildManipulatorSetEnabled(false)

                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)

                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end

                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
            end,
            
            OnWeaponFired = function(self)

                SDFChronotronOverChargeCannonWeapon.OnWeaponFired(self)

                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)

                if self.unit:BeenDestroyed() then return end

                self:SetWeaponEnabled(false)

                --self.unit:SetWeaponEnabledByLabel('ChronotronCannon', true)

                self.unit:BuildManipulatorSetEnabled(false)

                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)

                if self.unit.BuildArmManipulator then
                    self.unit.BuildArmManipulator:SetPrecedence(0)
                end
                
                self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
            end,
            
            PauseOvercharge = function(self)

                if not self.unit:IsOverchargePaused() then

                    self.unit:SetOverchargePaused(true)

                    WaitSeconds(1/self:GetBlueprint().RateOfFire)

                    self.unit:SetOverchargePaused(false)
                end
            end,
            
            OnFire = function(self)

                if not self.unit:IsOverchargePaused() then
                    SDFChronotronOverChargeCannonWeapon.OnFire(self)
                end
            end,

            IdleState = State(SDFChronotronOverChargeCannonWeapon.IdleState) {

                OnGotTarget = function(self)

                    if not self.unit:IsOverchargePaused() then
                        SDFChronotronOverChargeCannonWeapon.IdleState.OnGotTarget(self)
                    end
                end,            

                OnFire = function(self)

                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },

            RackSalvoFireReadyState = State(SDFChronotronOverChargeCannonWeapon.RackSalvoFireReadyState) {

                OnFire = function(self)

                    if not self.unit:IsOverchargePaused() then
                        SDFChronotronOverChargeCannonWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },  
        },
    },


    OnCreate = function(self)
        SWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:SetupBuildBones()
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        --SWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('ChronotronCannon', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        SWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        SWalkingLandUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        SWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:DisableRemoteViewingButtons()
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:ForkThread(self.GiveInitialResources)
        self.ShieldEffectsBag = {}
    end,

    OnFailedToBuild = function(self)
        SWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        local bp = self:GetBlueprint()
        if order != 'Upgrade' or bp.Display.ShowBuildEffectsDuringUpgrade then
            self:StartBuildingEffects(unitBeingBuilt, order)
        end
        self:DoOnStartBuildCallbacks(unitBeingBuilt)
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('Construct')
        self:PlayUnitAmbientSound('ConstructLoop')
        if bp.General.UpgradesTo and unitBeingBuilt:GetUnitId() == bp.General.UpgradesTo and order == 'Upgrade' then
            self.Upgrading = true
            self.BuildingUnit = false        
            unitBeingBuilt.DisallowCollisions = true
        end
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
    end,  

    OnStopBuild = function(self, unitBeingBuilt)
        SWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
    end,
    
    WarpInEffectThread = function(self)
        self:PlayUnitSound('CommanderArrival')
        self:CreateProjectile( '/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
        WaitSeconds(2.1)
        self:ShowBone(0, true)
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
        self:SetUnSelectable(false)
        self:SetBusy(false)
        self:SetBlockCommandQueue(false)

        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end

        WaitSeconds(6)
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    RegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.BUILTBYTIER3FACTORY + categories.BUILTBYQUANTUMGATE + categories.NEEDMOBILEBUILD, self:GetPosition(), self:GetBlueprint().Enhancements.RegenAura.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimACURegenAura')
            end
            
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,

    AdvancedRegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.BUILTBYTIER3FACTORY + categories.BUILTBYQUANTUMGATE + categories.NEEDMOBILEBUILD, self:GetPosition(), self:GetBlueprint().Enhancements.AdvancedRegenAura.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimAdvancedACURegenAura')
            end
            
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,

	
    CreateEnhancement = function(self, enh)
		
        local bp = self:GetBlueprint().Enhancements[enh]
		
        if enh == 'RegenAura' then
            SWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here else this happens twice for some other enhancements
            self:GetBuffFieldByName('SeraphimACURegenBuffField'):Enable()

        elseif enh == 'RegenAuraRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here else this happens twice for some other enhancements
            self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()

        elseif enh == 'AdvancedRegenAura' then
            SWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here else this happens twice for some other enhancements
            self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()
            self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Enable()
            
        elseif enh == 'AdvancedRegenAuraRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here else this happens twice for some other enhancements
            self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Disable()

        elseif enh == 'BlastAttackRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here else this happens twice for some other enhancements
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(-self:GetBlueprint().Enhancements['BlastAttack'].NewDamageRadius) # unlimited AOE bug fix by brute51 [117]
            wep:AddDamageMod(-self:GetBlueprint().Enhancements['BlastAttack'].AdditionalDamage)
        end        

        if enh == 'ResourceAllocation' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            
        elseif enh == 'ResourceAllocationRemove' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            
        elseif enh == 'ResourceAllocationAdvanced' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            
        elseif enh == 'ResourceAllocationAdvancedRemove' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)

        elseif enh == 'DamageStabilization' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            if not Buffs['SeraphimACUDamageStabilization'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilization',
                    DisplayName = 'SeraphimACUDamageStabilization',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end  
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilization')
            
      	elseif enh == 'DamageStabilizationAdvanced' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            if not Buffs['SeraphimACUDamageStabilizationAdv'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilizationAdv',
                    DisplayName = 'SeraphimACUDamageStabilizationAdv',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilizationAdv' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilizationAdv' )
            end  
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilizationAdv')
            
        elseif enh == 'DamageStabilizationAdvancedRemove' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            # since there's no way to just remove an upgrade anymore, if we're remove adv, we're removing both
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilizationAdv' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilizationAdv' )
            end
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end
            
        elseif enh == 'DamageStabilizationRemove' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end

        elseif enh == 'Teleporter' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Teleport')
            
        elseif enh == 'TeleporterRemove' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Teleport')

        elseif enh == 'Missile' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')        
            self:SetWeaponEnabledByLabel('Missile', true)
            
        elseif enh == 'MissileRemove' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')        
            self:SetWeaponEnabledByLabel('Missile', false)

        elseif enh =='AdvancedEngineering' then
		
			SWalkingLandUnit.CreateEnhancement(self, enh)
			
            local bp = self:GetBlueprint().Enhancements[enh]
			
            if not bp then return end
			
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
			
            self:RemoveBuildRestriction(cat)

            Buff.ApplyBuff(self, 'ACU_T2_Engineering')
			
        elseif enh =='AdvancedEngineeringRemove' then
		
			SWalkingLandUnit.CreateEnhancement(self, enh)
			
            local bp = self:GetBlueprint().Economy.BuildRate
			
            if not bp then return end
			
            self:RestoreBuildRestrictions()
			
            self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
			
            if Buff.HasBuff( self, 'ACU_T2_Engineering' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Engineering' )
            end

        elseif enh =='T3Engineering' then
		
			SWalkingLandUnit.CreateEnhancement(self, enh)
			
            local bp = self:GetBlueprint().Enhancements[enh]
			
            if not bp then return end
			
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
			
            self:RemoveBuildRestriction(cat)

            Buff.ApplyBuff(self, 'ACU_T3_Engineering')
			
        elseif enh =='T3EngineeringRemove' then
		
			SWalkingLandUnit.CreateEnhancement(self, enh)
			
            local bp = self:GetBlueprint().Economy.BuildRate
			
            if not bp then return end
			
            self:RestoreBuildRestrictions()
			
            if Buff.HasBuff( self, 'ACU_T3_Engineering' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Engineering' )
            end
			
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
			
        elseif enh =='T4Engineering' then
		
			SWalkingLandUnit.CreateEnhancement(self, enh)
			
            local bp = self:GetBlueprint().Enhancements[enh]
			
            if not bp then return end
			
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
			
            self:RemoveBuildRestriction(cat)

            Buff.ApplyBuff(self, 'ACU_T4_Engineering')
			
        elseif enh =='T4EngineeringRemove' then
		
			SWalkingLandUnit.CreateEnhancement(self, enh)
			
            local bp = self:GetBlueprint().Economy.BuildRate
			
            if not bp then return end
			
            self:RestoreBuildRestrictions()
			
            if Buff.HasBuff( self, 'ACU_T4_Engineering' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Engineering' )
            end
			
            self:AddBuildRestriction( categories.SERAPHIM * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )

        elseif enh == 'BlastAttack' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(bp.AdditionalDamage)

        elseif enh == 'RateOfFire' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
            
        elseif enh == 'RateOfFireRemove' then
			SWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius            
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)
            
        # Remote Viewing system
        #elseif enh == 'RemoteViewing' then
        #    self.Sync.Abilities = {[bp.NewAbility] = self:GetBlueprint().Abilities[bp.NewAbility]}
        #    self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
        #    self:SetMaintenanceConsumptionInactive()
        #    self:EnableRemoteViewingButtons()
        #elseif enh == 'RemoteViewingRemove' then
        #    self.Sync.Abilities = false
        #    self.RemoteViewingData.VisibleLocation = false
        #    self:DisableRemoteViewingButtons()
        end
    end,

    OnPaused = function(self)
        SWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            SWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end
    end,

    OnUnpaused = function(self)
        if self.BuildingUnit then
            SWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        SWalkingLandUnit.OnUnpaused(self)
    end,

}

TypeClass = XSL0001