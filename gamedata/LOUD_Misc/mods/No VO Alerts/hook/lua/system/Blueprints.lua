do
    local OldModBlueprints = ModBlueprints

    function ModBlueprints(all_blueprints)
        OldModBlueprints(all_blueprints)

        local modConfig = {}
        for _, v in __active_mods do
            if v.uid == "7be1d5f4-c544-11ea-87d0-noalerts0001" then
                modConfig = v.config
                break
            end
        end

        for id, bp in all_blueprints.Unit do
            if not bp.Audio then
                continue
            end

            if modConfig['Ferry'] == 'off' and
            (bp.Audio.FerryPointSetByAeon or
            bp.Audio.FerryPointSetByUEF or
            bp.Audio.FerryPointSetByCybran or
            bp.Audio.FerryPointSetBySeraphim) then
                bp.Audio.FerryPointSetByAeon = nil
                bp.Audio.FerryPointSetByUEF = nil
                bp.Audio.FerryPointSetByCybran = nil
                bp.Audio.FerryPointSetBySeraphim = nil
            end

            if modConfig['MexAttack'] == 'off' and
            (bp.Audio.UnitUnderAttackAeon or
            bp.Audio.UnitUnderAttackUEF or
            bp.Audio.UnitUnderAttackCybran or
            bp.Audio.UnitUnderAttackSeraphim) then
                bp.Audio.UnitUnderAttackAeon = nil
                bp.Audio.UnitUnderAttackUEF = nil
                bp.Audio.UnitUnderAttackCybran = nil
                bp.Audio.UnitUnderAttackSeraphim = nil
            end

            if modConfig['EnemyCom'] == 'off' and
            (bp.Audio.EnemyUnitDetectedAeon or
            bp.Audio.EnemyUnitDetectedUEF or
            bp.Audio.EnemyUnitDetectedCybran or
            bp.Audio.EnemyUnitDetectedSeraphim) then
                bp.Audio.EnemyUnitDetectedAeon = nil
                bp.Audio.EnemyUnitDetectedUEF = nil
                bp.Audio.EnemyUnitDetectedCybran = nil
                bp.Audio.EnemyUnitDetectedSeraphim = nil
            end
        end
    end
end