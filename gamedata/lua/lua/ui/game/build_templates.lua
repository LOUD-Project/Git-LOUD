-- File: lua/modules/ui/game/build_templates.lua
-- Author: Ted Snook
-- Summary: Build Templates UI
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.

local GameCommon = import('/lua/ui/game/gamecommon.lua')
local Prefs = import('/lua/user/prefs.lua')
local templates = Prefs.GetFromCurrentProfile('build_templates') or {}
local UIUtil = import('/lua/ui/uiutil.lua')

local function TemplateAxisOffset(unitbp, axe)
    return (math.mod(math.ceil(unitbp.Footprint and unitbp.Footprint[axe] or unitbp[axe] or 1), 2) == 1 and 0 or 0.5)
end

function CreateBuildTemplate()
    GenerateBuildTemplateFromSelection()
    local template = GetActiveBuildTemplate()
    ClearBuildTemplates()
    if next(template) then
        local str1bp = __blueprints[ template[3][1] ]
        local s1Xoffset = TemplateAxisOffset(str1bp, 'SizeX')
        local s1Yoffset = TemplateAxisOffset(str1bp, 'SizeZ')
        if s1Xoffset ~= 0 or s1Yoffset ~= 0 then
            for i=3, table.getn(template) do
                local str = template[i]
                str[3] = str[3] + s1Xoffset
                str[4] = str[4] + s1Yoffset
            end
        end
        AddTemplate(template)
    end
end

function Init()
    import('/lua/ui/game/gamemain.lua').RegisterChatFunc(ReceiveTemplate, 'Template')
end

function ReceiveTemplate(sender, msg)
    if Prefs.GetOption('accept_build_templates') == 'yes' then
        local tab = import('/lua/ui/game/construction.lua').GetTabByID('templates')
        if tab then
            import('/lua/ui/game/announcement.lua').CreateAnnouncement(LOC('<LOC template_0000>Build Template Received'), tab, LOCF('<LOC template_0001>From %s', sender))
        end
        AddTemplate(msg.data)
    end
end

function GetInitialName(template)
    for _, entry in template do
        if type(entry) != 'table' then continue end
        return __blueprints[entry[1]].Description
    end
end

function GetInitialIcon(template)
    for _, entry in template do
        if type(entry) != 'table' then continue end
        local _, valid = GameCommon.GetUnitIconPath(nil, entry[1])
        if valid then
            return entry[1]
        else
            return false
        end
    end
end

function AddTemplate(newTemplate)
    table.insert(templates, {
        templateData = newTemplate,
        name = GetInitialName(newTemplate),
        icon = GetInitialIcon(newTemplate)
    })
    Prefs.SetToCurrentProfile('build_templates', templates)
end

function GetTemplates()
    return Prefs.GetFromCurrentProfile('build_templates')
end

function ResetTemplates()
    Prefs.SetToCurrentProfile('build_templates', false)
end

function RemoveTemplate(templateID)
    table.remove(templates, templateID)
    Prefs.SetToCurrentProfile('build_templates', templates)
end

function RenameTemplate(templateID, name)
    templates[templateID].name = name
    Prefs.SetToCurrentProfile('build_templates', templates)
end

function SetTemplateIcon(templateID, iconPath)
    templates[templateID].icon = iconPath
    Prefs.SetToCurrentProfile('build_templates', templates)
end

function SendTemplate(templateID, armyIndex)
    armyIndex = armyIndex
    if table.getn(templates[templateID].templateData) > 22 then
        UIUtil.QuickDialog(GetFrame(0), "<LOC build_templates_0000>You may only send build templates with 20 or less buildings.", 
            "<LOC _Ok>", nil, nil, nil, nil, nil,
            true,  {worldCover = true, enterButton = 1, escapeButton = 1})
    else
        SessionSendChatMessage(armyIndex, {Template = true, data = templates[templateID].templateData})
    end
end

function SetTemplateKey(templateID, key)
    local used = false
    for i, template in templates do
        if i == templateID then continue end
        if template.key and template.key == key then
            used = true
            break
        end
    end
    if used then
        return false
    else
        templates[templateID].key = key
        Prefs.SetToCurrentProfile('build_templates', templates)
        return true
    end
end

function ClearTemplateKey(templateID)
    templates[templateID].key = nil
    Prefs.SetToCurrentProfile('build_templates', templates)
end
