local BrainMethods     = moho.aibrain_methods
local GetEconomyIncome = BrainMethods.GetEconomyIncome
local GetListOfUnits   = BrainMethods.GetListOfUnits

local LOUDFLOOR = math.floor
local LOUDMAX   = math.max
local LOUDMIN   = math.min
local LOUDGETN  = table.getn

-- ================
-- Consumption Data
-- ================

local MexUpgradeConsumption = {
    T2 = {
        mass = 8, energy = 48
    },
    T3 = {
        mass = 20, energy = 150 -- use T3+ consumption to provide a small buffer and slow the power requirement ramp
    },  
}

local FactoryUpgradeConsumption = {
    LAND = {
        T2 = { mass = 13, energy = 145 },
        T3 = { mass = 25, energy = 229 },
    },
    AIR = {
        T2 = { mass = 7, energy = 145 },
        T3 = { mass = 12, energy = 254 },
    },
    NAVAL = {
        T2 = { mass = 14, energy = 81 },
        T3 = { mass = 25, energy = 108 },
    }
}

local FactoryBuildConsumption = {
    LAND = {
        T1 = { mass = 10, energy = 50 },
        T2 = { mass = 17, energy = 100 },
        T3 = { mass = 25, energy = 250 },
    },
    AIR = {
        T1 = { mass = 3, energy = 199 },
        T2 = { mass = 10, energy = 524 },
        T3 = { mass = 20, energy = 1125 },
    },
    NAVAL = {
        T1 = { mass = 10, energy = 100 },
        T2 = { mass = 17, energy = 150 },
        T3 = { mass = 25, energy = 200 },
    }
}

-- =========
-- Functions
-- =========

-- Count up the number of T1 & T2 mexes and divide by the T3 mex upgrade limit
-- This gives a value representing the saturation of the current mex upgrade ratio
-- That value is then multiplied by the base mex upgrade ratio, clamped between that 0.1 and that base ratio
-- This sets the new income ratio with any surplus being split between factory building & ugprading
function IncomeRatioBudget(aiBrain)

    local incomeRatio = aiBrain.IncomeRatio
    local mexUpgrade  = aiBrain.MexUpgrade

    local baseMexUpgrade     = incomeRatio.BaseMexUpgrade
    local baseFactoryUpgrade = incomeRatio.BaseFactoryUpgrade
    local baseMaxFactory     = incomeRatio.BaseMaxFactory

    local lowTierMex, surplusRatio

    while not aiBrain:IsDefeated() do

        local ReportRatios = ScenarioInfo.ReportRatios or false
 
        local mexUpgradeSaturation = 1

        lowTierMex = LOUDGETN(GetListOfUnits(aiBrain, categories.MASSEXTRACTION - categories.TECH3, false, true))

        if mexUpgrade.T3BaseLimit ~= 0 then
            mexUpgradeSaturation = lowTierMex / mexUpgrade.T3BaseLimit
        end

        incomeRatio.MexUpgrade = LOUDMAX(0.1, LOUDMIN(baseMexUpgrade, baseMexUpgrade * mexUpgradeSaturation))

        surplusRatio = baseMexUpgrade - incomeRatio.MexUpgrade

        incomeRatio.MaxFactory = baseMaxFactory + (surplusRatio * 0.8)
        incomeRatio.FactoryUpgrade = baseFactoryUpgrade + (surplusRatio * 0.2)

        if ReportRatios then
            LOG(aiBrain.Nickname.." IncomeRatioBudget T1+T2/T3 mex: "..lowTierMex.."/"..mexUpgrade.T3BaseLimit.." gives an upgrade saturation: "..mexUpgradeSaturation
            .." with a surplus ratio of: "..surplusRatio.. " | ratios for maxfac/facup/mexup are now "..incomeRatio.MaxFactory.." / "..incomeRatio.FactoryUpgrade.." / "..incomeRatio.MexUpgrade)
        end

        WaitTicks(190)

    end

end

-- Using the current mass & energy income calculate the maximum T2/T3 upgrades that could be run
-- Multiply those maximum numbers by the base income ratio giving a T2 and T3 limits
-- The base income ratio is used as the income ratio itself will shift up and down
-- This requires it being calculted seperately for its own maxmimum value for use in determing the shift to income ratio
function MexUpgradeLimit(aiBrain)

    local baseIncomeRatio = aiBrain.IncomeRatio.BaseMexUpgrade

	local incomeRatio, massIncome, energyIncome, massLimit, energyLimit, T1Mex

    while not aiBrain:IsDefeated() do

        local StructureUpgradeDialog = ScenarioInfo.StructureUpgradeDialog or false        

        incomeRatio  = aiBrain.IncomeRatio.MexUpgrade

        massIncome   = GetEconomyIncome( aiBrain, 'MASS') * 10
        energyIncome = GetEconomyIncome( aiBrain, 'ENERGY') * 10

        for techLevel, rate in MexUpgradeConsumption do

            massLimit = (massIncome / rate.mass) * incomeRatio
            energyLimit = (energyIncome / rate.energy) * incomeRatio

            aiBrain.MexUpgrade[techLevel .. "Limit"] = LOUDFLOOR(LOUDMIN(massLimit, energyLimit) + 0.5)

            if techLevel == 'T3' then

                massLimit = (massIncome / rate.mass) * baseIncomeRatio
                energyLimit = (energyIncome / rate.energy) * baseIncomeRatio                

                aiBrain.MexUpgrade.T3BaseLimit = LOUDFLOOR(LOUDMIN(massLimit, energyLimit) + 0.5)

                -- If the mass income is still developing and there are still T1 mex then prevent T2->T3 upgrades
                T1Mex = LOUDGETN(GetListOfUnits(aiBrain, categories.MASSEXTRACTION * categories.TECH1, false, true))

                if T1Mex > 0 and massIncome < 60 then
                    aiBrain.MexUpgrade.T3Limit = 0
                end

            end

        end

        if StructureUpgradeDialog then
            LOG(aiBrain.Nickname.." MexUpgradeLimit T2 "..aiBrain.MexUpgrade.T2Active.."/"..aiBrain.MexUpgrade.T2Limit.." T3 "..aiBrain.MexUpgrade.T3Active.."/"..aiBrain.MexUpgrade.T3Limit..
            " from income "..string.format("%.0f", massIncome).."/"..string.format("%.0f", energyIncome))
        end

        WaitTicks(150)

    end

end

-- Using the current mass & energy income calculate the maximum T2/T3 upgrades that could be run
-- Multiply those maximum numbers by the base income ratio giving a T2 and T3 limits
-- Using a T2 & T3 threshold value the time at which he first upgrades is set
-- Those thresholds are multiplied by the reciprocal of the cheatvalue
function FactoryUpgradeLimit(aiBrain)

    local cheatValue = aiBrain.CheatValue
    local T2Threshold = 600 * (1 / cheatValue)
    local T3Threshold = 1800 * (1 / cheatValue)

    local factoryUpgrade = aiBrain.FactoryUpgrade
    local incomeRatio

    while not aiBrain:IsDefeated() do

        local StructureUpgradeDialog = ScenarioInfo.StructureUpgradeDialog or false

        local massIncome   = GetEconomyIncome( aiBrain, 'MASS') * 10
        local energyIncome = GetEconomyIncome( aiBrain, 'ENERGY') * 10

        for factoryType, techLevels in FactoryUpgradeConsumption do

            for techLevel, rate in techLevels do

                if (techLevel == "T2" and aiBrain.CycleTime < T2Threshold)
                or (techLevel == "T3" and aiBrain.CycleTime < T3Threshold) then

                    factoryUpgrade[techLevel..factoryType.."Limit"] = 0

                else

                    incomeRatio = aiBrain.IncomeRatio.FactoryUpgrade

                    local massLimit = (massIncome / rate.mass) * incomeRatio
                    local energyLimit = (energyIncome / rate.energy) * incomeRatio                    
                    
                    factoryUpgrade[techLevel..factoryType.."Limit"] = LOUDFLOOR(LOUDMIN(massLimit, energyLimit) + 0.5)

                end

            end

        end

        if StructureUpgradeDialog then
            LOG(aiBrain.Nickname.." FactoryUpgradeLimit T2 Land "..factoryUpgrade.T2LANDActive.."/"..factoryUpgrade.T2LANDLimit.." - T2 Air "..factoryUpgrade.T2AIRActive.."/"..factoryUpgrade.T2AIRLimit
            .." T3 Land "..factoryUpgrade.T3LANDActive.."/"..factoryUpgrade.T3LANDLimit.." - T3 Air "..factoryUpgrade.T3AIRActive.."/"..factoryUpgrade.T3AIRLimit..
            " | from income "..string.format("%.0f", massIncome).."/"..string.format("%.0f", energyIncome))
        end

        WaitTicks(170)

    end

end

-- A bias generated to control how many of each type of factory should be built
-- Land and air are clamped so they're always able to be built to the max the eco will allow
-- Air is clamped lower to maintain a better overall balance
-- Naval is zeroed when it is not a water map to prevent its early low ratio intefering with land and air
-- Naval is also zeroed when it is a water map but early on to encourage the 2nd factory build on land
function StrengthBias(aiBrain)
	local landRatio = 10 - LOUDMIN(aiBrain.LandRatio, 9)
	local airRatio = 10 - LOUDMIN(aiBrain.AirRatio, 7)
	local navalRatio = 10 - LOUDMIN(aiBrain.NavalRatio, 10)

	if not aiBrain.IsWaterMap or
	(aiBrain.IsWaterMap and aiBrain.CycleTime < 360) then
		navalRatio = 0
	end

	-- favour a strong land opening when there is a land connection to the enemy
	if aiBrain.CycleTime < 720 and aiBrain.HasLandEnemy then
		landRatio = 9.989
	end

	local ratioSum = LOUDMAX(0.01, landRatio + airRatio + navalRatio)

	return {
		LAND = landRatio / ratioSum,
		AIR = airRatio / ratioSum,
		NAVAL = navalRatio / ratioSum
	}

end

-- Count up all the factories by type as well as how many T2 & T3 there are
-- Using the T2 & T3 count determine what tech level LOUD is currently in
-- Then based upon that tech level find out the maximum number of each type of factory which could be supported
-- Multiply that by the ratio of income dedicated to factories and then by the strength bias
function MaxFactoryLimit(aiBrain)

    local maxFactory = aiBrain.MaxFactory

	local currentTechLevel

    while not aiBrain:IsDefeated() do 

        local engineerDialog = ScenarioInfo.EngineerDialog or false

        local massIncome   = GetEconomyIncome( aiBrain, 'MASS') * 10
	    local energyIncome = GetEconomyIncome( aiBrain, 'ENERGY') * 10

        local incomeRatio = aiBrain.IncomeRatio.MaxFactory
	    local strengthBias = StrengthBias(aiBrain)        

        local factories = GetListOfUnits(aiBrain, categories.FACTORY * categories.STRUCTURE - categories.GATE - categories.EXPERIMENTAL, false, false)

        local count = {
            LAND = 0, AIR = 0, NAVAL = 0, T2 = 0, T3 = 0
        }

        -- Count number of factories by type as well as how many T2 & T3 factories there are
        for _, factory in factories do

            if not factory:IsUnitState('Upgrading') then

                if EntityCategoryContains(categories.LAND, factory) then
                    count.LAND = count.LAND + 1
                elseif EntityCategoryContains(categories.AIR, factory) then
                    count.AIR = count.AIR + 1
                elseif EntityCategoryContains(categories.NAVAL, factory) then
                    count.NAVAL = count.NAVAL + 1
                end

                if EntityCategoryContains(categories.TECH2, factory) then
                    count.T2 = count.T2 + 1                
                elseif EntityCategoryContains(categories.TECH3, factory) then
                    count.T3 = count.T3 + 1
                end

            end

        end

        -- Determine current tech level based upon T2 & T3 count
        if count.T3 > 0 then
            currentTechLevel = 'T3'
        elseif count.T2 > 0 then
            currentTechLevel = 'T2'
        else
            currentTechLevel = 'T1'
        end

        for factoryType, techLevels in FactoryBuildConsumption do

            local rate = techLevels[currentTechLevel]

            local massLimit = (massIncome / rate.mass) * incomeRatio * strengthBias[factoryType]
            local energyLimit = (energyIncome / rate.energy) * incomeRatio * strengthBias[factoryType]                   

            maxFactory[factoryType.."Count"] = count[factoryType]
            maxFactory[factoryType.."Limit"] = LOUDFLOOR(LOUDMIN(massLimit, energyLimit) + 0.5)

        end

        -- Build first factory
        if count.LAND + count.AIR == 0 then
            maxFactory.LANDLimit = 1
            maxFactory.AIRLimit  = 1
        end

        local result = 0

        for k,v in aiBrain.BuilderManagers do
            result = result + EntityCategoryCount( categories.AIR, v.FactoryManager.FactoryList )
        end  

        if engineerDialog then
            LOG(aiBrain.Nickname.." MaxFactoryLimit - In "..currentTechLevel.." - Land "..maxFactory.LANDCount.."/"..maxFactory.LANDLimit..
            " Air "..maxFactory.AIRCount.."/"..maxFactory.AIRLimit.." Naval "..maxFactory.NAVALCount.."/"..maxFactory.NAVALLimit..
            " | "..string.format("%.0f", massIncome).." mass "..string.format("%.0f", energyIncome).." energy | "
            ..string.format("%.2f", LOUDMIN(aiBrain.LandRatio, 10)).." - "..string.format("%.2f", LOUDMIN(aiBrain.AirRatio, 10)).." - "..string.format("%.2f", LOUDMIN(aiBrain.NavalRatio, 10)))
        end

        WaitTicks(130)

    end

end