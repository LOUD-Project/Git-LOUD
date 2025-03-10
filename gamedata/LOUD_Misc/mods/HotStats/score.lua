local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local EffectHelpers = import('/lua/maui/effecthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Button = import('/lua/maui/button.lua').Button
local Text = import('/lua/maui/text.lua').Text
local MultiLineText = import('/lua/maui/multilinetext.lua').MultiLineText
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local RadioGroup = import('/lua/maui/mauiutil.lua').RadioGroup
local Tooltip = import('/lua/ui/game/tooltip.lua')
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local score = import('/lua/ui/dialogs/score.lua')
local Group = import('/lua/maui/group.lua').Group
local scoreAccum = import('/mods/hotstats/scoreaccum.lua')
local scoreData = scoreAccum.scoreData
local scoreInterval = import('/mods/hotstats/scoreaccum.lua').scoreInterval

--LayoutHelpers.SetPixelScaleFactor(1.0)

page_active=false
page_active_graph = false
page_active_graph2 = false
create_anime_graph=false
create_anime_graph2=false
graph_pos={Left=function() return LayoutHelpers.ScaleNumber(110) end, Top=function() return LayoutHelpers.ScaleNumber(120) end, Right=function() return GetFrame(0).Right()-LayoutHelpers.ScaleNumber(100) end, Bottom=function() return GetFrame(0).Bottom()-LayoutHelpers.ScaleNumber(160) end}
bar_pos={Left=function() return LayoutHelpers.ScaleNumber(90) end, Top=function() return LayoutHelpers.ScaleNumber(140) end, Right=function() return GetFrame(0).Right()-LayoutHelpers.ScaleNumber(60) end, Bottom=function() return GetFrame(0).Bottom()-LayoutHelpers.ScaleNumber(150) end}
bt_pos_top=LayoutHelpers.ScaleNumber(160)

local pathui = '/mods/hotstats/hook'
local pathTex='/mods/hotstats/textures'
local pathuiimg = pathTex
local sca_utils = '/mods/hotstats/'
local gamemain = import('/lua/ui/game/gamemain.lua')
local skinning= import(sca_utils .. 'skinning.lua')
local info_dialog = {   -- CHANGE THE TEXT IN DIALOG_TXT.LUA !!!!!
 {name="total units built", path={"general","built","count"},key=1},
 {name="units still alive", path={"general","currentunits","count"},key=2},
 {name="total energy in", path={"resources","energyin","total"},key=8},
 {name="total mass in", path={"resources","massin","total"},key=11},
 {name="score", path={"general","score",false},key=5},
 {name="total kills", path={"general","kills","count"},key=6},
 {name="total lost", path={"general","lost","count"},key=7},
-- {name="energy all", path={"general","built","energy"},key=3},
 {name="energy rate", path={"resources","energyin","rate",fac_mul=10},key=59},
 {name="total energy out", path={"resources","energyout","total"},key=9},
 {name="total energy wasted", path={"resources","energyover",false},key=10},
-- {name="mass all", path={"general","built","mass"},key=4},
  {name="mass rate", path={"resources","massin","rate",fac_mul=10},key=59},
 {name="total mass out", path={"resources","massout","total"},key=12},
 {name="total mass wasted", path={"resources","massover",false},key=13},
 {name="units air built", path={"units","air","built"},key=14},
 {name="units air kills", path={"units","air","kills"},key=15},
 {name="units air lost", path={"units","air","lost"},key=16},
 {name= "units land built", path={"units","land","built"},key=17},
 {name="units land kills", path={"units","land","kills"},key=18},
 {name="units land lost", path={"units","land","lost"},key=19},
 {name= "units naval built", path={"units","naval","built"},key=20},
 {name="units naval kills", path={"units","naval","kills"},key=21},
 {name="units naval lost", path={"units","naval","lost"},key=22},
 {name= "units xp built", path={"units","experimental","built"},key=23},
 {name="units xp kills", path={"units","experimental","kills"},key=24},
{name= "units xp lost", path={"units","experimental","lost"},key=25},
{ name= "units struct built", path={"units","structures","built"},key=26},
{name= "units struct kills", path={"units","structures","kills"},key=27},
{name= "units struct lost", path={"units","structures","lost"},key=28},
-- {name="units cdr built", path={"units","cdr","built"},key=29},
 {name="units cdr kills", path={"units","cdr","kills"},key=30},
 {name="units cdr lost", path={"units","cdr","lost"},key=31}}
 
function mySkinnableFile(file)
  -- Should be, but I have no idea where to place that file or what to do at all
  --return UIUtil.SkinnableFile(file)
  return file
end 

function modcontrols_trad(id)
--    return id
  text = import(sca_utils .. 'dialog_txt.lua').trad(id)
  if text then
    return text
  end
  LOG("Translate ID not found: " .. id)
  return id
end

--local modcontrols= import(sca_utils .. 'modcontrols_lua')
function modcontrols_tooltips(parent,help_tips)
	if help_tips!=nil and help_tips!=false then
		local oldHandleEvent = parent.HandleEvent
		parent.HandleEvent = function(self, event)
			if event.Type == 'MouseEnter' then
				Tooltip.CreateMouseoverDisplay(self, modcontrols_trad(help_tips), .5) --, true)
			elseif event.Type == 'MouseExit' then
				Tooltip.DestroyMouseoverDisplay()
			end
			oldHandleEvent(self,event)
		end
	end
end	

local SCAEffect = import(sca_utils.. 'myeffecthelpers.lua')

local chartInfoText = false

--mySkinnableFile("/game/resources/mass_btn_up.dds")
local histo={
        main_histo={ 
			 [1]={name="mass",icon=mySkinnableFile("/game/unit_view_icons/mass.dds"),label1="mass",link="mass_histo",Tooltip="mass",
				data={{name="mass incombe",icon="",path={"resources","massin","total"},color="green",Tooltip="Mass_incoming"},
					{name="mass wasted",icon=mySkinnableFile("/game/icons/icon-trash-lg_btn_up.png"),path={"resources","massover",false},color="2e6405",Tooltip="Mass_wasted"} }},
			 [2]={name="energy",icon=mySkinnableFile("/game/unit_view_icons/energy.dds"),label1="energy",link="energy_histo",Tooltip="energy",
				data={{name="energy incombe",icon="",path={"resources","energyin","total"},color="orange",Tooltip="Energy_incoming"},
					{name="energy wasted",icon=mySkinnableFile("/game/icons/icon-trash-lg_btn_up.png"),path={"resources","energyover",false},color="c77d1e",Tooltip="Energy_wasted"} }},
			[3]={name="units built",icon=mySkinnableFile("/game/unit_view_icons/build.dds"),label1="built",label2="",link="built_histo",Tooltip="built_units",
				data={{name="air unit",icon=pathTex .. "/icons_strategic/fighter_generic.dds",path={"units","air","built"},color="39b0be",Tooltip="air"},
					{name="land unit",icon=pathTex .. "/icons_strategic/land_generic.dds",path={"units","land","built"},color="64421a",Tooltip="land"},
					{name="naval unit",icon=pathTex .. "/icons_strategic/ship_generic.dds",path={"units","naval","built"},color="000080",Tooltip="naval"},
					{name="xp unit",icon=pathTex .. "/icons_strategic/experimental_generic.dds",path={"units","experimental","built"},color="641a5e",Tooltip="xp"},
					{name="cdr unit",icon=pathTex .. "/icons_strategic/commander_generic.dds",path={"units","cdr","built"},color="white",Tooltip="cdr"},
					{name="structures",icon=pathTex .. "/icons_strategic/factory_generic.dds",path={"units","structures","built"},color="3b3b3b",Tooltip="struct"} }},					
			 [4]={name="units kills",icon=mySkinnableFile("/game/unit_view_icons/kills.dds"),label1="kills",label2="",Tooltip="kills_units",link="kills_histo",
				data={{name="air unit",icon=pathTex .. "/icons_strategic/fighter_generic.dds",path={"units","air","kills"},color="39b0be",Tooltip="air"},
					{name="land unit",icon=pathTex .. "/icons_strategic/land_generic.dds",path={"units","land","kills"},color="64421a",Tooltip="land"},
					{name="naval unit",icon=pathTex .. "/icons_strategic/ship_generic.dds",path={"units","naval","kills"},color="000080",Tooltip="naval"},
					{name="xp unit",icon=pathTex .. "/icons_strategic/experimental_generic.dds",path={"units","experimental","kills"},color="641a5e",Tooltip="xp"},
					{name="cdr unit",icon=pathTex .. "/icons_strategic/commander_generic.dds",path={"units","cdr","kills"},color="white",Tooltip="cdr"},
					{name="structures",icon=pathTex .. "/icons_strategic/factory_generic.dds",path={"units","structures","kills"},color="3b3b3b",Tooltip="struct"} }},
			 },
	mass_histo={[1]={name="mass",icon=pathTex .. "/score/mass-in-icon.dds",label1="in",label2="",Tooltip="Mass_incoming",link="main_histo",
				data={{name="mass in",icon="",path={"resources","massin","total"},color="green",Tooltip="Mass_incoming"}}},
				[2]={name="mass",icon=pathTex .. "/score/mass-out-icon.dds",label1="out",label2="",Tooltip="Mass_outgoing",link="main_histo",
				data={{name="mass out",icon="",path={"resources","massout","total"},color="5fdc5c",Tooltip="Mass_outgoing"} }},
				[3]={name="mass",icon=pathTex .. "/score/mass-waste-icon.dds",label1="wasted",label2="",Tooltip="Mass_wasted",link="main_histo",
				data={{name="mass wasted",icon=mySkinnableFile("/game/icons/icon-trash-lg_btn_up.png"),path={"resources","massover",false},color="2e6405",Tooltip="Mass_wasted"} }}},

	energy_histo={[1]={name="energy",icon=pathTex .. "/score/energy-in-icon.dds",label1="in",label2="",Tooltip="Energy_incoming",link="main_histo",
				data={{name="energy in",icon="",path={"resources","energyin","total"},color="orange",Tooltip="Energy_incoming"}}},
				[2]={name="energy",icon=pathTex .. "/score/energy-out-icon.dds",label1="out",label2="",Tooltip="Energy_outgoing",link="main_histo",
				data={{name="energy out",icon="",path={"resources","energyout","total"},color="dcb05c",Tooltip="Energy_outgoing"} }},
				[3]={name="energy",icon=pathTex .. "/score/energy-waste-icon.dds",label1="wasted",label2="",Tooltip="Energy_wasted",link="main_histo",
				data={{name="energy wasted",icon=mySkinnableFile("/game/icons/icon-trash-lg_btn_up.png"),path={"resources","energyover",false},color="c77d1e",Tooltip="Energy_wasted"} }}},

	built_histo={[1]={name="units built",icon=pathTex .. "/score/fighter-icon.dds",label1="air",label2="",Tooltip="air",link="main_histo",
				data={{name="air unit",icon=pathTex .. "/icons_strategic/fighter_generic.dds",path={"units","air","built"},color="39b0be",Tooltip="air"}}},
				[2]={name="units built",icon=pathTex .. "/score/land-icon.dds",label1="land",label2="",Tooltip="land",link="main_histo",
				data={{name="land unit",icon=pathTex .. "/icons_strategic/land_generic.dds",path={"units","land","built"},color="64421a",Tooltip="land"}}},
				[3]={name="units built",icon=pathTex .. "/score/ship-icon.dds",label1="naval",label2="",Tooltip="naval",link="main_histo",
				data={{name="naval unit",icon=pathTex .. "/icons_strategic/ship_generic.dds",path={"units","naval","built"},color="000080",Tooltip="naval"}}},
				[4]={name="units built",icon=pathTex .. "/score/experimental-icon.dds",label1="xp",label2="",Tooltip="xp",link="main_histo",
				data={{name="cdr unit",icon=pathTex .. "/icons_strategic/commander_generic.dds",path={"units","cdr","built"},color="white",Tooltip="cdr"}},
				data={{name="xp unit",icon=pathTex .. "/icons_strategic/experimental_generic.dds",path={"units","experimental","built"},color="641a5e",Tooltip="xp"}}},
				--[5]={name="units built",icon=pathTex .. "/score/commander-icon.dds",label1="cdr",label2="",Tooltip="cdr",
				[6]={name="units built",icon=pathTex .. "/score/factory-icon.dds",label1="struct",label2="",Tooltip="struct",link="main_histo",
				data={{name="structures",icon=pathTex .. "/icons_strategic/factory_generic.dds",path={"units","structures","built"},color="3b3b3b",Tooltip="struct"} }}
			 },
	kills_histo={[1]={name="units kills",icon=pathTex .. "/score/fighter-icon.dds",label1="air",label2="",Tooltip="air",link="main_histo",
				data={{name="air unit",icon=pathTex .. "/icons_strategic/fighter_generic.dds",path={"units","air","kills"},color="39b0be",Tooltip="air"}}},
				[2]={name="units kills",icon=pathTex .. "/score/land-icon.dds",label1="land",label2="",Tooltip="land",link="main_histo",
				data={{name="land unit",icon=pathTex .. "/icons_strategic/land_generic.dds",path={"units","land","kills"},color="64421a",Tooltip="land"}}},
				[3]={name="units kills",icon=pathTex .. "/score/ship-icon.dds",label1="naval",label2="",Tooltip="naval",link="main_histo",
				data={{name="naval unit",icon=pathTex .. "/icons_strategic/ship_generic.dds",path={"units","naval","kills"},color="000080",Tooltip="naval"}}},
				[4]={name="units kills",icon=pathTex .. "/score/experimental-icon.dds",label1="xp",label2="",Tooltip="xp",link="main_histo",
				data={{name="cdr unit",icon=pathTex .. "/icons_strategic/commander_generic.dds",path={"units","cdr","kills"},color="white",Tooltip="cdr"}},
				data={{name="xp unit",icon=pathTex .. "/icons_strategic/experimental_generic.dds",path={"units","experimental","kills"},color="641a5e",Tooltip="xp"}}},
				--[5]={name="units kills",icon=pathTex .. "/score/commander-icon.dds",label1="cdr",label2="",Tooltip="cdr",
				[6]={name="units kills",icon=pathTex .. "/score/factory-icon.dds",label1="struct",label2="",Tooltip="struct",link="main_histo",
				data={{name="structures",icon=pathTex .. "/icons_strategic/factory_generic.dds",path={"units","structures","kills"},color="3b3b3b",Tooltip="struct"} }}
			 },
			 
	 
	}

local main_graph={[1]={name="score",path={"general","score",false}, index = 5},
				   [2]={name="mass",path={"resources","massin","total"}, index = 4},
				   [3]={name="energy",path={"resources","energyin","total"}, index = 3},
				   [4]={name="total_built",path={"general","built","count"}, index = 1},
				   [5]={name="total_kills",path={"general","kills","count"}, index = 6},
				   --{name="total_lost",path={"general","lost","count"}},
				   }
	
function FillParentPreserveAspectRatioNoExpand(control, parent,offsetx,offsety)
   
        local ratio = parent.Height() / control.BitmapHeight()
        if ratio * control.BitmapWidth() > parent.Width() then
            ratio = parent.Width() / control.BitmapWidth()
        end
	ratio=math.abs(ratio)
	 if ratio>.5 then ratio=.5 end
     
    control.Top:Set(function() return 
        math.floor(parent.Top() + ((parent.Height() - (control.Height() * ratio)) / 2))+offsety
    end)     
    control.Bottom:Set(function()
        return math.floor(parent.Bottom() - ((parent.Height() - (control.Height() * ratio)) / 2))+offsety
    end)     
    control.Left:Set(function()
        return math.floor(parent.Left() + ((parent.Width() - (control.Width() * ratio)) / 2))+offsetx
    end)     
    control.Right:Set(function()
        return math.floor(parent.Right() - ((parent.Width() - (control.Width() * ratio)) / 2))+offsetx
    end)     
end

-- what to do/display if no data ??
function nodata()
	local nodata=UIUtil.CreateText(GetFrame(0),modcontrols_trad("noData"), 22, UIUtil.titleFont)
	nodata:SetColor("black")
	Title_score:Hide()
	LayoutHelpers.AtCenterIn(nodata, GetFrame(0))
	nodata.Depth:Set(GetFrame(0):GetTopmostDepth())
end

function create_graph_bar(parent,name,x1,y1,x2,y2,data_previous)
	local data_nbr=table.getsize(scoreData.historical) -- data_nbr is the number of group of data saved
	LOG("Number of data found:",data_nbr)
	if data_nbr<=0 then nodata() return nil end

	----------------LOG(repr(scoreData.current[1]))
	local data_histo=histo[name]
	local grp=Group(parent)
	grp.Left:Set(0)
	grp.Top:Set(0)
	grp.Right:Set(0)
	grp.Bottom:Set(0)
	Title_score:SetText(modcontrols_trad(name))
	page_active_graph2=grp
	
	local part_num_player=1

	local player={}
	local armiesInfo = GetArmiesTable()
	local player_nbr=0
	local columns_nbr=table.getsize(data_histo)
	local graphic={}
	local value={}
	local m=0
	for k, v in armiesInfo.armiesTable do
		m=m+1
		if not v.civilian and v.nickname!=nil then
			player_nbr=player_nbr+1
			player[player_nbr]={}
			player[player_nbr].name=v.nickname
			player[player_nbr].color=v.color
			player[player_nbr].index=m
			player[player_nbr].faction=v.faction
			graphic[player_nbr]={}
			end
	end	
	local row_nbr=1
	local player_nbr_by_row=player_nbr
	if player_nbr>4 then row_nbr=2  player_nbr_by_row=math.ceil(player_nbr/2) end
	
	space_bg_height=math.max((y2-y1)*(row_nbr-1)*.1,35*(row_nbr-1))
	bg_height=(y2-y1-space_bg_height)/row_nbr
	
	space_between_columns=math.floor(LayoutHelpers.ScaleNumber(30)/player_nbr_by_row)
	space_bg_width=space_between_columns*LayoutHelpers.ScaleNumber(7)

	local bg_width=math.min((x2-x1-space_bg_width*(player_nbr_by_row-1))/player_nbr_by_row,LayoutHelpers.ScaleNumber(400))
	local x_center=math.floor((x2-x1-player_nbr_by_row*bg_width - (player_nbr_by_row-1)*space_bg_width)/2)
	dec={left=math.floor(bg_height*.1),top=LayoutHelpers.ScaleNumber(50)/row_nbr,right=LayoutHelpers.ScaleNumber(80)/player_nbr_by_row,bottom=math.max(math.floor(bg_height*.15),LayoutHelpers.ScaleNumber(30))}
	
	
	local columns_width=(bg_width-dec.left-dec.right-(columns_nbr-1)*space_between_columns)/columns_nbr    
	local row=0
	local p=0
	for k,play in player do
		p=p+1
		if row==0 and row_nbr>1 and p>(player_nbr/row_nbr) then p=1 row=row+1 end
		graphic[play.index].bg=Bitmap(grp)
		graphic[play.index].bg.Left:Set(parent.Left() + x1 + x_center +(p-1)*(space_bg_width+bg_width))
		graphic[play.index].bg.Top:Set(parent.Top() + y1 + (bg_height+space_bg_height)*row)
		graphic[play.index].bg.Right:Set( graphic[play.index].bg.Left() + bg_width)
		graphic[play.index].bg.Bottom:Set(graphic[play.index].bg.Top() + bg_height)
		graphic[play.index].bg:SetSolidColor(play.color)
--TEST		graphic[play.index].bg:SetAlpha(.65)
		graphic[play.index].bg:SetAlpha(.08)
		
		graphic[play.index].bg2=Bitmap(grp)
		LayoutHelpers.FillParent(graphic[play.index].bg2,graphic[play.index].bg)
		graphic[play.index].bg2:SetTexture(mySkinnableFile(pathuiimg..'/fond.dds'))
--		graphic[play.index].bg2:SetAlpha(.55)		
		graphic[play.index].bg2:SetAlpha(.05)		
		
		graphic[play.index].title_label=UIUtil.CreateText(grp, string.sub(play.name,1,math.floor(bg_width/10)),math.floor(16-player_nbr_by_row/2), UIUtil.titleFont)
		LayoutHelpers.AtLeftIn(graphic[play.index].title_label, graphic[play.index].bg, 5)
		graphic[play.index].title_label:SetColor("white") --play.color)
		graphic[play.index].title_label:SetDropShadow(true)
		LayoutHelpers.AnchorToTop(graphic[play.index].title_label, graphic[play.index].bg, 5)
		
		graphic[play.index].faction= Bitmap(grp) 
		graphic[play.index].faction:SetTexture(UIUtil.UIFile(UIUtil.GetFactionIcon(play.faction)))
		graphic[play.index].title_label.Left:Set(graphic[play.index].bg.Left()+LayoutHelpers.ScaleNumber(5)+graphic[play.index].faction.Width()+LayoutHelpers.ScaleNumber(9))
		LayoutHelpers.AnchorToLeft(graphic[play.index].faction, graphic[play.index].title_label, 5)
		graphic[play.index].factionbg= Bitmap(grp)
		LayoutHelpers.FillParent(graphic[play.index].factionbg,graphic[play.index].faction)
		graphic[play.index].factionbg:SetSolidColor(play.color)
		graphic[play.index].factionbg.Depth:Set(graphic[play.index].faction.Depth()-1)
		graphic[play.index].faction.Bottom:Set(graphic[play.index].title_label.Bottom)
	end
	
		
	local columns_num=0
	for index_col,columns in data_histo do
		columns_num=columns_num+1
		
		--columns.name
		-- deal with columns.icon
	--graphic={ 
	--	index_player={bg, title_player,titleplayer_shadow,faction,
	--		index_columns={icon,label1,label2,label_value,
	--			index_part={	bmp, icon,
	
	--value={
	--	index_columns={max_columns_value,factor,left,right,bottom,top
	--		index_player={columns_value
	--			index_part={value
			value[columns_num]={}
			value[columns_num].max_columns_value=0
			for k, play in player do
				value[columns_num][play.index]={}
				value[columns_num][play.index].columns_value=0
				value[columns_num][play.index].winner=false
				part_num=0
				for k,part in columns.data do
					pat_num=part_num+1
					value[columns_num][play.index][part_num]={}
					value[columns_num][play.index][part_num].value=return_value(0,play.index,part.path)
					value[columns_num][play.index].columns_value=value[columns_num][play.index].columns_value+ value[columns_num][play.index][part_num].value
				end
				if value[columns_num][play.index].columns_value!=nil and math.floor(value[columns_num][play.index].columns_value)!=0 and value[columns_num][play.index].columns_value>=value[columns_num].max_columns_value then 
					if value[columns_num][play.index].columns_value>value[columns_num].max_columns_value then
						for k2, play2 in player do
							if value[columns_num][play2.index].winner!=nil then value[columns_num][play2.index].winner=false end
						end
					end
					value[columns_num].max_columns_value=value[columns_num][play.index].columns_value
					value[columns_num][play.index].winner=true
				end
			end
			value[columns_num].factor=value[columns_num].max_columns_value/(bg_height-dec.top-dec.bottom)
			if value[columns_num].factor<.1 then value[columns_num].factor=.1 end
			
			--[[for k,part in columns.data do
				local i=0
				for k2, play2 in player do
					if value[columns_num][play2.index].winner!=nil and value[columns_num][play2.index].winner then i=i+1 end
				end
				if i
			end--]]
			
		local part_num_player=0 
		for k,play in player do
			part_num_player=part_num_player+1
			value[columns_num].max_columns_value=0
			value[columns_num].left=graphic[play.index].bg.Left()+dec.left+(columns_num-1)*(columns_width+space_between_columns)
			value[columns_num].right=value[columns_num].left+columns_width
			value[columns_num].bottom=graphic[play.index].bg.Bottom()-dec.bottom
			value[columns_num].top=graphic[play.index].bg.Top()+dec.top
			graphic[play.index][columns_num]={}
			graphic[play.index][columns_num].grp=Group(grp)	
			local tmp_index=play.index
            LayoutHelpers.AtLeftTopIn(graphic[play.index][columns_num].grp, graphic[tmp_index].bg, dec.left, dec.top)	
			LayoutHelpers.AtRightBottomIn(graphic[play.index][columns_num].grp, graphic[tmp_index].bg, dec.right, dec.bottom)

			local part_num=0
			local y=graphic[play.index].bg.Bottom()-dec.bottom
			if value[columns_num][play.index].winner then 
				graphic[play.index][columns_num].icon = Bitmap(graphic[play.index][columns_num].grp)
				graphic[play.index][columns_num].icon:SetTexture(pathuiimg..'/cup.dds')
				graphic[play.index][columns_num].icon.Top:Set(value[columns_num].bottom+16/player_nbr_by_row)
				graphic[play.index][columns_num].icon.Left:Set(value[columns_num].left+columns_width/2-graphic[play.index][columns_num].icon.BitmapWidth()/2)
				graphic[play.index][columns_num].icon_glow = Bitmap(graphic[play.index][columns_num].grp)
				graphic[play.index][columns_num].icon_glow:SetTexture(pathuiimg..'/cup_glow.dds')
				graphic[play.index][columns_num].icon_glow.Top:Set(value[columns_num].bottom+16/player_nbr_by_row)
				graphic[play.index][columns_num].icon_glow.Left:Set(value[columns_num].left+columns_width/2-graphic[play.index][columns_num].icon.BitmapWidth()/2)
--				EffectHelpers.Pulse(graphic[play.index][columns_num].icon_glow,1,.5,1)
				EffectHelpers.Pulse(graphic[play.index][columns_num].icon_glow,1,.8,1)
				modcontrols_tooltips(graphic[play.index][columns_num].icon,"winner")
				--graphic[play.index][columns_num][part_num].icon = Bitmap(graphic[play.index][columns_num][part_num].bmp)
				--graphic[play.index][columns_num][part_num].icon:SetTexture(pathuiimg..'/cup.dds')
				--FillParentPreserveAspectRatioNoExpand(graphic[play.index][columns_num][part_num].icon,graphic[play.index][columns_num][part_num].bmp,0,0)
			elseif (columns.icon!="" and columns.icon!=nil) then
				graphic[play.index][columns_num].icon = Bitmap(graphic[play.index][columns_num].grp)
				graphic[play.index][columns_num].icon:SetTexture(columns.icon)
				graphic[play.index][columns_num].icon.Top:Set(value[columns_num].bottom+16/player_nbr_by_row)
				graphic[play.index][columns_num].icon.Left:Set(value[columns_num].left+columns_width/2-graphic[play.index][columns_num].icon.BitmapWidth()/2)
				if columns.Tooltip!="" and columns.Tooltip!=nil then modcontrols_tooltips(graphic[play.index][columns_num].icon,columns.Tooltip) end
			end
	--[[		if columns.label1 !="" and columns.label1!=nil then
				graphic[play.index][columns_num].label1=UIUtil.CreateText(graphic[tmp_index][columns_num].grp,columns.label1, 12-player_nbr/2, UIUtil.titleFont)
				graphic[play.index][columns_num].label1.Top:Set(value[columns_num].bottom+LayoutHelpers.ScaleNumber(20))
				graphic[play.index][columns_num].label1.Left:Set(value[columns_num].left+columns_width/2-graphic[play.index][columns_num].label1.Width()/2)
			end
			if columns.label2!="" and columns.label2!=nil then
					graphic[play.index][columns_num].label2=UIUtil.CreateText(graphic[tmp_index][columns_num].grp,columns.label2, 12-player_nbr/2, UIUtil.titleFont)
					graphic[play.index][columns_num].label2.Top:Set(value[columns_num].bottom+LayoutHelpers.ScaleNumber(32))
					graphic[play.index][columns_num].label2.Left:Set(value[columns_num].left+columns_width/2-graphic[play.index][columns_num].label2.Width()/2)
			end--]]
			for k,part in columns.data do
				part_num=part_num+1
				graphic[play.index][columns_num][part_num]={}
			
				
				graphic[play.index][columns_num][part_num].bmp=Bitmap(graphic[play.index][columns_num].grp)
				graphic[play.index][columns_num][part_num].bmp.Left:Set(value[columns_num].left)
				graphic[play.index][columns_num][part_num].bmp.Right:Set( value[columns_num].left +columns_width )
				graphic[play.index][columns_num][part_num].bmp.Bottom:Set(y)
				y=y-return_value(0,play.index,part.path)/value[columns_num].factor
				
				graphic[play.index][columns_num][part_num].bmp.Top:Set(y)
				graphic[play.index][columns_num][part_num].bmp:SetSolidColor(part.color)
				LayoutHelpers.ResetWidth(graphic[play.index][columns_num][part_num].bmp)
				LayoutHelpers.ResetHeight(graphic[play.index][columns_num][part_num].bmp)
				graphic[play.index][columns_num][part_num].bmp2=Bitmap(graphic[play.index][columns_num].grp)
				LayoutHelpers.FillParent(graphic[play.index][columns_num][part_num].bmp2,graphic[play.index][columns_num][part_num].bmp)
				graphic[play.index][columns_num][part_num].bmp2:SetTexture(mySkinnableFile(pathuiimg..'/fond.dds'))
				graphic[play.index][columns_num][part_num].bmp.Depth:Set(GetFrame(0):GetTopmostDepth())
				graphic[play.index][columns_num][part_num].bmp2.Depth:Set(GetFrame(0):GetTopmostDepth())
				if columns.link!="" and columns.link!=nil then
					local oldHandleEvent = parent.HandleEvent
					local tmp=columns.link
					local player = play.index
					local path = part.path
					graphic[play.index][columns_num][part_num].bmp.HandleEvent = function(self, event)--OnClick = function(self, modifiers)
						--show value under mouse
						local posX = function() return event.MouseX end -- - bg.Left() end
						local posY = function() return event.MouseY end -- - bg.Top() end
						if chartInfoText != false then
							chartInfoText:Destroy()
							chartInfoText = false
						end
					
						local  value = math.floor(return_value(0,player,path) + 0.5)
						chartInfoText = UIUtil.CreateText(self, value, 14, UIUtil.titleFont)		
						chartInfoText.Left:Set(function() return posX()-(chartInfoText.Width()/2) end)
						chartInfoText.Bottom:Set(function() return posY()-LayoutHelpers.ScaleNumber(7) end)
						chartInfoText.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
						chartInfoText:SetColor("white")
						chartInfoText:DisableHitTest()
				
						local infoPopupbg = Bitmap(chartInfoText) -- the borders of the windows
						infoPopupbg:SetSolidColor('white')
						infoPopupbg:SetAlpha(.6)
						infoPopupbg.Depth:Set(function() return chartInfoText.Depth()-2 end)
						local infoPopup = Bitmap(chartInfoText)
						infoPopup:SetSolidColor('black')
						infoPopup:SetAlpha(.6)	
						infoPopupbg.Depth:Set(function() return chartInfoText.Depth()-1 end)

						infoPopup.Width:Set(function() return chartInfoText.Width() + LayoutHelpers.ScaleNumber(8) end)
						infoPopup.Height:Set(function() return chartInfoText.Height() + LayoutHelpers.ScaleNumber(8) end)
						LayoutHelpers.AtLeftBottomIn(infoPopup, chartInfoText, -4, -4)
						infoPopupbg.Width:Set(function() return infoPopup.Width() + LayoutHelpers.ScaleNumber(2) end)
						infoPopupbg.Height:Set(function() return infoPopup.Height() + LayoutHelpers.ScaleNumber(2) end)
						LayoutHelpers.AtLeftBottomIn(infoPopupbg, infoPopup, -1, -1)

						if event.Type == 'ButtonPress' then
							create_graph_bar(parent,tmp,x1,y1,x2,y2,data_histo)
							grp:Destroy()
						else
							oldHandleEvent(self,event)
						end
						return
					end
				end
				
				
				if part.Tooltip!="" and part.Tooltip!=nil then modcontrols_tooltips(graphic[play.index][columns_num][part_num].bmp,part.Tooltip) end
				
				if (part.icon!="") then
					graphic[play.index][columns_num][part_num].icon = Bitmap(graphic[play.index][columns_num][part_num].bmp)
					graphic[play.index][columns_num][part_num].icon:SetTexture(part.icon)
					FillParentPreserveAspectRatioNoExpand(graphic[play.index][columns_num][part_num].icon,graphic[play.index][columns_num][part_num].bmp,0,0)
				end
				
			end
			graphic[play.index][columns_num].label_value=UIUtil.CreateText(graphic[play.index][columns_num].grp,makeKMG(value[columns_num][play.index].columns_value), math.floor(13-player_nbr_by_row/2), UIUtil.titleFont)
			graphic[play.index][columns_num].label_value.Top:Set(math.floor(y-LayoutHelpers.ScaleNumber(15)))
			graphic[play.index][columns_num].label_value.Left:Set(math.floor(value[columns_num].left+columns_width/2-graphic[play.index][columns_num].label_value.Width()/2))
			graphic[play.index][columns_num].label_value:SetDropShadow(true)

		--	part.name
		--	part.path
		--	build square above
		end
	end
	return grp
end
			 
function line(parent,x1,y1,x2,y2,color, size)
	local grp=Group(parent)
	grp.Left:Set(0)
	grp.Top:Set(0)
	grp.Right:Set(0)
	grp.Bottom:Set(0)
	function add_pixel(grp,parent,x1,y1,color,size)
		local bmp=Bitmap(grp)
		bmp.Left:Set(parent.Left() +x1 )
		bmp.Top:Set(parent.Top() +y1 )
		bmp.Right:Set( bmp.Left() +size )
		bmp.Bottom:Set( bmp.Top() +size )
		bmp:SetSolidColor(color)
	end
	local dist=math.sqrt(math.pow((x2-x1),2)+math.pow(y2-y1,2))/size
	local x_factor=(x2-x1)/dist
	local y_factor=(y2-y1)/dist
	local i=0
	local x=x1
	local y=y1
	while i<dist do
		i=i+1
		add_pixel(grp, parent,x,y,color,size)
		x=x+x_factor
		y=y+y_factor
	end
	return grp
end


function tps_format(val)
	if val<60 then return math.floor(val).."s" end
	m=math.floor(val/60)
	if m<60 then 
		if math.floor(val-60*m)!=0 then return m.."m"..math.floor(val-60*m) else return m.."m" end
	end
	h=math.floor(val/3600) 
	if math.floor((val-3600*h)/60)==0 then return h.."h" end
	return h.."h"..math.floor((val-3600*h)/60)
	
end

-- allow to find the best value upper to one (ie if int=3785 -->5000)
function arrange(int)
	local lg=math.log10(int)
	digit=int/math.pow(10,math.floor(lg)) -- the first number
	if digit<2.4 then return 2.5*math.pow(10,math.floor(lg))
	elseif digit<4.9 then return 5*math.pow(10,math.floor(lg))
	elseif digit<7.5 then return 7.5*math.pow(10,math.floor(lg))
	else return math.pow(10,math.floor(lg)+1)
	end
end

function makeKMG(int)
	local lg=math.log10(int)
	if lg<=3 then return math.floor(int) end
	if lg<=6 then return (math.floor(int/1000)).."."..(math.floor((int/1000)-math.floor(int/1000))*10).." k" end
	if lg<=9 then return (math.floor(int/1000000)).."."..(math.floor((int/1000000)-math.floor(int/1000000))*10).." M" end
	return (math.floor(int/1000000000)).."."..(math.floor((int/1000000000)-math.floor(int/1000000000))*10).." G"
end

-- if periode=0 then return the current value
function return_value(periode,player,path)
	local val=0
	if periode==0 then
		if path[3]==nil or path[3]==false then val=scoreData.current[player][path[1]][path[2]]
		else val=scoreData.current[player][path[1]][path[2]][path[3]] end
	else
		if path[3]==nil or path[3]==false then val=scoreData.historical[periode][player][path[1]][path[2]]
			else val=scoreData.historical[periode][player][path[1]][path[2]][path[3]] end
	end
	if path.fac_mul !=nil then val=val*path.fac_mul end
	if val==nil then val=-5 end
	return val
end

function page_graph(parent)
	LOG("HotStats: PAGE_GRAPH called")
	local data_nbr=table.getsize(scoreData.historical) -- data_nbr is the number of group of data saved
	LOG("HotStats: Number of data found:",data_nbr)
	if data_nbr<=0 then nodata() return nil end
	clean_view()
	page_active=Group(parent)
	page_active.Left:Set(0)
	page_active.Top:Set(0)
	page_active.Right:Set(0)
	page_active.Bottom:Set(0)
	page_active_graph=create_graph(parent,info_dialog[5].path,graph_pos.Left(),graph_pos.Top(),graph_pos.Right(),graph_pos.Bottom())
	
	-- build the list box	
	local graph_list={}
	local Combo = import('/lua/ui/controls/combo.lua').Combo
	local BitmapCombo = import('/lua/ui/controls/combo.lua').BitmapCombo
	combo_graph=Combo(page_active, 17, 10, nil, nil, "UI_Tab_Click_01", "UI_Tab_Rollover_01")
	combo_graph.Right:Set(graph_pos.Right) --function() return 300 end)
    LayoutHelpers.AtTopIn(combo_graph, graph_pos, -25) --function() return 300 end)
	LayoutHelpers.SetWidth(combo_graph, 250)
	combo_graph.keyMap={}
	combo_graph.Key=1
	local i=0

	for k,v in info_dialog do
		i=i+1
		graph_list[i]=v.name
		combo_graph.keyMap[i]=v.key
	end
	combo_graph:AddItems(graph_list,5)	-- here is the default display value
	if table.getsize(graph_list) == 1 then
                combo_graph:Disable()
      else
            combo_graph:Enable()
       end
	combo_graph.OnClick = function(self, index, text) 
             self.Key = index
		self.text=text
		self.path=info_dialog[index].path
		if page_active_graph then page_active_graph:Destroy() page_active_graph=false end
		page_active_graph=create_graph(parent,info_dialog[index].path,graph_pos.Left(),graph_pos.Top(),graph_pos.Right(),graph_pos.Bottom())
		Title_score:SetText(modcontrols_trad(info_dialog[index].name))
	end
	combo_graph.Key=2 -- here the defalut used value in key and in text
	combo_graph.text=graph_list[2]

	local i=0
	for name,data in main_graph do
		local btn = UIUtil.CreateButtonStd(page_active, '/menus/main03/large', modcontrols_trad(data.name.."_btn"), 14, 0, 0, "UI_Menu_MouseDown", "UI_Opt_Affirm_Over")
		local index = data.index
		
		--btn.Left:Set((math.min((x2-2*x1)/table.getsize(histo),200) )*i+x1)
		btn.Left:Set((((graph_pos.Right()-LayoutHelpers.ScaleNumber(100))-btn.Width()*.5*(table.getsize(main_graph)))/(table.getsize(main_graph)+1)+btn.Width()*.5)*i+LayoutHelpers.ScaleNumber(100))
		LayoutHelpers.AnchorToBottom(btn, graph_pos, 25)
		EffectHelpers.ScaleTo(btn, .5, 0)
		btn:UseAlphaHitTest(false)
		local tmp=data.path
		local tmp_index=info_dialog[index].name
		
		btn.OnClick = function(self, modifiers)
			if page_active_graph then page_active_graph:Destroy() page_active_graph=false end
			--LOG(repr(name))
			page_active_graph=create_graph(parent,tmp,graph_pos.Left(),graph_pos.Top(),graph_pos.Right(),graph_pos.Bottom())
			Title_score:SetText(modcontrols_trad(tmp_index))
			LOG("-----------------------",tmp_index)
			
			return
		end
		i=i+1
	end
	
	return
end

function page_bar(parent)
	local data_nbr=table.getsize(scoreData.historical) -- data_nbr is the number of group of data saved
	LOG("Number of data found:",data_nbr)
	if data_nbr<=0 then nodata() return nil end
	clean_view()
	page_active=Group(parent)
	page_active.Left:Set(0)
	page_active.Top:Set(0)
	page_active.Right:Set(0)
	page_active.Bottom:Set(0)
	
	page_active_graph2=create_graph_bar(parent,"main_histo",bar_pos.Left(),bar_pos.Top(),bar_pos.Right(),bar_pos.Bottom())
	
	local i=0
	for name,data in histo do
		local btn = UIUtil.CreateButtonStd(page_active, '/menus/main03/large', modcontrols_trad(name.."_btn"), 14, 0, 0, "UI_Menu_MouseDown", "UI_Opt_Affirm_Over")
		
		btn.Left:Set((((bar_pos.Right()-LayoutHelpers.ScaleNumber(100))-btn.Width()*.5*(table.getsize(main_graph)))/(table.getsize(main_graph)+1)+btn.Width()*.5)*i+LayoutHelpers.ScaleNumber(100))
		LayoutHelpers.AnchorToBottom(btn, bar_pos, 15)
		EffectHelpers.ScaleTo(btn, .5, 0)
		btn:UseAlphaHitTest(false)
		local tmp=name
		btn.OnClick = function(self, modifiers)
			if page_active_graph2 then page_active_graph2:Destroy() page_active_graph2=false end
			--LOG(repr(name))
			page_active_graph2=create_graph_bar(parent,tmp,bar_pos.Left(),bar_pos.Top(),bar_pos.Right(),bar_pos.Bottom())
			return
		end
		i=i+1
	end
	
	
	return page_active_graph2
end

function page_dual(parent)
	local data_nbr=table.getsize(scoreData.historical) -- data_nbr is the number of group of data saved
	LOG("Number of data found:",data_nbr)
	if data_nbr<=0 then nodata() return nil end
	page_active_graph=create_graph(parent,info_dialog[5].path,LayoutHelpers.ScaleNumber(110),LayoutHelpers.ScaleNumber(120),GetFrame(0).Right()-LayoutHelpers.ScaleNumber(100),GetFrame(0).Bottom()/2-LayoutHelpers.ScaleNumber(15))
	page_active_graph2=create_graph_bar(parent,"main_histo",LayoutHelpers.ScaleNumber(90),GetFrame(0).Bottom()/2+LayoutHelpers.ScaleNumber(40),GetFrame(0).Right()-LayoutHelpers.ScaleNumber(100),GetFrame(0).Bottom()-LayoutHelpers.ScaleNumber(110))

end

function clean_view()
	if  create_anime_graph!=nil and create_anime_graph then KillThread(create_anime_graph) end
	if page_active!=nil and page_active then page_active:Destroy() page_active=false end
	if page_active_graph!=nil and page_active_graph then page_active_graph:Destroy() page_active_graph=false end
	if page_active_graph2!=nil and page_active_graph2 then page_active_graph2:Destroy() page_active_graph2=false end
end

-- path is where is data is stored in scoredata
-- xi,yi is the windows based on parent of the background
function create_graph(parent,path,x1,y1,x2,y2)
	local data_nbr=table.getsize(scoreData.historical) -- data_nbr is the number of group of data saved
	LOG("Number of data found:",data_nbr)
	if data_nbr<=0 then nodata() return nil end

	local player={} -- would be the name/color of the player in the left-top corner
	--scoreInterval is the time between to data saved
	
	
	-- parent group
	local grp=Group(parent)
	grp.Left:Set(0)	grp.Top:Set(0) grp.Right:Set(0) grp.Bottom:Set(0)
	page_active_graph=grp
	-- gray background that receive all
	bg=Bitmap(grp)
	bg.Left:Set(function() return parent.Left() + x1 end)
	bg.Top:Set(function() return parent.Top() + y1 - LayoutHelpers.ScaleNumber(2) end)
	bg.Right:Set(function() return parent.Left() + x2 + LayoutHelpers.ScaleNumber(2) end)
	bg.Bottom:Set(function() return parent.Top() + y2 + LayoutHelpers.ScaleNumber(1)  end)
	bg:SetSolidColor("black")
	bg:SetAlpha(0.98)
--ZZZ	bg:SetAlpha(0.65)

	bg2=Bitmap(grp)
	LayoutHelpers.FillParent(bg2,bg)
--ZZZ	bg:SetAlpha(0.65)			
	

	-- build parent-name in the left-top of the screen
	local armiesInfo = GetArmiesTable()
	local i=1
	local m=0
	for k, v in armiesInfo.armiesTable do
		m=m+1
		if not v.civilian and v.nickname!=nil then
			player[i]={}
			player[i].name=v.nickname
			player[i].color=v.color
			player[i].index=m
			
			player[i].title_label=UIUtil.CreateText(grp,v.nickname, 14, UIUtil.titleFont)
			player[i].title_label.Left:Set(x1 + LayoutHelpers.ScaleNumber(5))
			player[i].title_label.Top:Set(y1 + LayoutHelpers.ScaleNumber(23) * (i-1) + LayoutHelpers.ScaleNumber(5))
			player[i].title_label:SetColor("black")
			player[i].title_label2=UIUtil.CreateText(grp,v.nickname, 14, UIUtil.titleFont)
			player[i].title_label2.Left:Set(x1 + LayoutHelpers.ScaleNumber(4))
			player[i].title_label2.Top:Set(y1 + LayoutHelpers.ScaleNumber(23) * (i-1) + LayoutHelpers.ScaleNumber(4))
			player[i].title_label2:SetColor(v.color)
			local acuKills = return_value(0,player[i].index,{"units","cdr","kills"})
			if acuKills > 0 then
				player[i].killIcon = {}
				for kill = 1, acuKills do
					local index = kill
					player[i].killIcon[index] = Bitmap(grp, pathuiimg.. '/score/commander-kills-icon.dds')
					if index == 1 then
						LayoutHelpers.RightOf(player[i].killIcon[index], player[i].title_label)
					else
						LayoutHelpers.RightOf(player[i].killIcon[index], player[i].killIcon[index-1])
					end
					modcontrols_tooltips(player[i].killIcon[index],"cmd_kill")
					player[i].killIcon[index].Depth:Set(bg.Depth()+500)
				end
			end
			i=i+1
		end
	end		
	local player_nbr=i-1
	-- searching the highest value
	local maxvalue=0
	local periode=-1
	
	while periode<data_nbr do
		periode=periode+1
		for index, dat in player do
			local val=return_value(periode,dat.index,path)	-- return the value
			if maxvalue<val then	maxvalue=val end
		end
	end
	LOG(maxvalue)
	--arranging the highest value to be nice to see
	maxvalue=arrange(maxvalue*1.02)
	
	-- calculate the scale factor on y
	local factor=(y2-y1)/maxvalue
	LOG("Value the highest:",maxvalue,"   final time saved:",scoreInterval*data_nbr,"   scale factor on y:",factor)
	
	-- drawing the axies/quadrillage
	local j=1
	local quadrillage_horiz={}
	local nbr_quadrillage_horiz=6 -- how many horizontal axies
	local nbr_quadrillage_vertical=8 -- how many vertical axies
	while j<nbr_quadrillage_horiz do
		local tmp=j
		quadrillage_horiz[j]=Bitmap(grp)
		quadrillage_horiz[j].Left:Set(function() return parent.Left() + x1 + LayoutHelpers.ScaleNumber(1) end)
		quadrillage_horiz[j].Top:Set(function() return parent.Top() + y2 - (y2-y1) * ((tmp-1) / (nbr_quadrillage_horiz-2)) - LayoutHelpers.ScaleNumber(1) end)
		quadrillage_horiz[j].Right:Set(function() return parent.Left() + x2 + LayoutHelpers.ScaleNumber(2) end)
        LayoutHelpers.AnchorToTop(quadrillage_horiz[j], quadrillage_horiz[tmp], -1)
		quadrillage_horiz[j]:SetSolidColor("white")
		quadrillage_horiz[j].Depth:Set(grp.Depth)
		
		quadrillage_horiz[j].title_label=UIUtil.CreateText(grp,math.floor((j-1)/(nbr_quadrillage_horiz-2)*maxvalue), 14, UIUtil.titleFont)
		quadrillage_horiz[j].title_label.Right:Set(parent.Left() + x1 - LayoutHelpers.ScaleNumber(8))
		quadrillage_horiz[j].title_label.Bottom:Set(parent.Top() + y2 - (y2-y1) * ((tmp-1) / (nbr_quadrillage_horiz-2)) + LayoutHelpers.ScaleNumber(1))
		quadrillage_horiz[j].title_label:SetColor("white")
		j=j+1
	end
	local j=1
	local quadrillage_vertical={}
	while j<nbr_quadrillage_vertical do
		local tmp=j
		quadrillage_vertical[j]=Bitmap(grp)
		quadrillage_vertical[j].Left:Set(function() return parent.Left() + x1 + ((x2-x1)) * ((tmp-1) / (nbr_quadrillage_vertical-2)) + LayoutHelpers.ScaleNumber(1)  end)
		quadrillage_vertical[j].Top:Set(function() return parent.Left() + y1 - LayoutHelpers.ScaleNumber(1)  end) 
		LayoutHelpers.AnchorToLeft(quadrillage_vertical[j], quadrillage_vertical[tmp], -1)
		quadrillage_vertical[j].Bottom:Set(function() return parent.Top() + y2 end)
		quadrillage_vertical[j]:SetSolidColor("white")
		quadrillage_vertical[j].Depth:Set(grp.Depth)
		
		quadrillage_vertical[j].title_label=UIUtil.CreateText(grp,tps_format((j-1)/(nbr_quadrillage_vertical-2)*data_nbr*scoreInterval), 14, UIUtil.titleFont)
		quadrillage_vertical[j].title_label.Left:Set(parent.Left() + x1 + ((x2-x1))*((tmp-1)/(nbr_quadrillage_vertical-2))+LayoutHelpers.ScaleNumber(1))
		quadrillage_vertical[j].title_label.Top:Set(parent.Top() + y2 + LayoutHelpers.ScaleNumber(10))
		quadrillage_vertical[j].title_label:SetColor("white")
		j=j+1
	end


	--after having draw the background exist if no data
	
	local size=1 -- Size of the pixel which compose the line, make the line wider

	
	-- ============================= the main function creating the graph
	--
	-- everything that needed the graphs are done are at the end of this thread
	if create_anime_graph then KillThread(create_anime_graph) end
if true then
	create_anime_graph = ForkThread(function()
		local periode=0  -- the number of the saved used
		local x=parent.Left()+ x1  -- the current position on x
		local dist=(x2-x1)/(data_nbr) -- the distance on the screen between two saved
		--LOG("dist:",dist)
		local delta_refresh=(x2-x1)/(6*size) -- the distance in time between the smallest halt possible to make a refresh
		local delta=0 -- counter for refresh and small halt
		
		local line={} -- containe for the actual periode of time all the data to be draw
		
		--if graph!=nil and graph then graph:Destroy() graph=false end
		graph={} -- will containt a table for each line and each line will be a table of bitmap
		for index, dat in player do 	graph[dat.index]={}  	end -- init the different line
		
		local current_player_index=0  -- if 0 we are in replay, otherwise will show the graph to emphasize
		if not gamemain.GetReplayState() then current_player_index=GetFocusArmy() end
		
		WaitSeconds(0.001) -- give time to refresh and displayed the background
		
		inc_periode=((data_nbr)/(x2-x1)) -- give the increment on the screen between each periode (i.e. between each saved)
		if inc_periode<1 then inc_periode=1 end -- can not be <1 => use the whole screen
		
		local nbr=0 -- couting the number of iterancy done
		-- ============ starting
		t=CurrentTime()
		WaitFrames(10)
		t1=CurrentTime()
		LOG("------- calculating the timing of the frame")
		LOG("Time to display 1 frame (calculate with 10 frames):",(t1-t)/10,'  t:',t,'   t1:',t1)
		delta_refresh=(x2-x1)*(t1-t)/10*( (player_nbr+1)/4)
		LOG("So refresh all the ",delta_refresh," pixels displayed (delta_refresh:)")
		while periode<data_nbr do
			nbr=nbr+1
			periode=math.floor(nbr*inc_periode) -- calculate the next periode to use (i.e. skip some of them it more value than the screen can display)
			
			-- prepare the data, calculate the ya=start y position and the yb=end position of the ligne for each player for this periode
			for index, dat in player do
				if periode==1 then val=0 else val=return_value(periode-1,dat.index,path) end 
				ya=parent.Top() +y2 - val*factor 
				local val=return_value(periode,dat.index,path)
				yb=parent.Top() +y2  - val*factor

				-- put all the data in this table
				line[dat.index]={grp=grp,ya=ya,yb=yb,y=ya,  -- note: y is the current position for this graph; the x is commun to all graph
					color=dat.color,index=dat.index,
					y_factor=(yb-ya)/dist*size} -- important: the factor of deplacement for the bitmap
			end

			local sav_x=x
			while (x<(parent.Left()+ x1 + nbr*dist) and x<(x2+parent.Left()))  do 
				for name,data in line do
					graph[data.index][x-x1]=Bitmap(grp)
					graph[data.index][x-x1].Left:Set(parent.Left() +x )
					if data.y_factor!=0 then
					local yn=parent.Top() +data.y+data.y_factor/math.abs(data.y_factor)*size*((math.abs(data.y_factor)+1) )
						if data.y_factor<0 and (yn+size)<data.yb then yn=data.yb-size end
						if data.y_factor>0 and (yn-size)>data.yb then yn=data.yb-size end
						graph[data.index][x-x1].Top:Set(yn)
					else
						graph[data.index][x-x1].Top:Set(parent.Top() +data.y-size)
					end
					graph[data.index][x-x1].Right:Set( graph[data.index][x-x1].Left() +size )
					graph[data.index][x-x1].Bottom:Set(parent.Top() +data.y)
					graph[data.index][x-x1]:SetSolidColor(data.color)
					graph[data.index][x-x1]:Depth(bg.Depth()+5)
					data.y=data.y+data.y_factor
				end
				
				x=x+size
				delta=delta+1
				if delta>delta_refresh then 
					WaitFrames(1) -- do the reshresh, should be far smaller to be smooth...
					delta=0 
				end
				
			end
		
		end
		for index, data in player do
			graph[data.index][x2]=Bitmap(grp)
			graph[data.index][x2].Left:Set(x2)
			if data.y_factor!=0 then
				val=return_value(math.floor((nbr-1)*inc_periode),data.index,path)
				LOG("1st:",val)
				ya=parent.Top() +y2 - val*factor 
				ya=graph[data.index][x-x1-size].Top()
				local val=return_value(0,data.index,path)
				LOG("2nd:",val)				
				yb=parent.Top() +y2  - val*factor
				if yb<y1 then yb=y1+2 end
				if yb>y2 then yb=y2-2 end
				--local yn=parent.Top() +data.y+data.y_factor/math.abs(data.y_factor)*size*((math.abs(data.y_factor)+1) )
				--if data.y_factor<0 and (yn+size)<data.yb then yn=data.yb-size end
				--if data.y_factor>0 and (yn-size)>data.yb then yn=data.yb-size end
				--	graph[data.index][x2].Top:Set(yn)
				--else
					graph[data.index][x2].Top:Set(parent.Top() +yb)
				--end
				LOG("x: ",x2,"  ya:",ya,"  yb:",yb)
				graph[data.index][x2].Right:Set( graph[data.index][x2].Left() +size )
				graph[data.index][x2].Bottom:Set(parent.Top() +ya)
				graph[data.index][x2]:SetSolidColor(data.color)
			end
		end
		
		-- ========= end of the drawing of the graph
		t=CurrentTime()
		LOG("total time:",t-t1)
		-- display the max value
		local value_graph_label={}
		for index, dat in player do
			value_graph_label[dat.index]={}
			val=math.floor(return_value(periode,dat.index,path))
			value_graph_label[dat.index].title_label=UIUtil.CreateText(grp,val, 14, UIUtil.titleFont)
			value_graph_label[dat.index].title_label.Right:Set(x-LayoutHelpers.ScaleNumber(1))
			value_graph_label[dat.index].title_label.Bottom:Set(line[dat.index].y - LayoutHelpers.ScaleNumber(1))
			value_graph_label[dat.index].title_label:SetColor(dat.color)
			value_graph_label[dat.index].title_label:SetDropShadow(true)
		end

		-- pulse the player graph if not in replay  TODO: fix the bug that we are nil when recreating the graph
		if current_player_index !=0 and current_player_index!=nil and graph[current_player_index][1]!=nil then
			for i,bmp in graph[current_player_index] do
				EffectHelpers.Pulse(bmp,1,.65,1)
			end
		end

		-- for the windows under the mouse on the background
		local infoText = false
		--displays the value when the mouse is over a graph
		bg.HandleEvent = function(self, event)
			local posX = function() return event.MouseX end -- - bg.Left() end
			local posY = function() return event.MouseY end -- - bg.Top() end
			if infoText != false then
				infoText:Destroy()
				infoText = false
			end
		
			if posX()>x1 and posX()<x2 and posY()>y1 and posY()<y2 then
				local  value = tps_format((posX()-x1)/(x2-x1)*scoreInterval*data_nbr) .. " / " .. math.floor(((y2-posY())/factor))
				infoText = UIUtil.CreateText(grp,value, 14, UIUtil.titleFont)		
				infoText.Left:Set(function() return posX()-(infoText.Width()/2) end)
				infoText.Bottom:Set(function() return posY()-LayoutHelpers.ScaleNumber(7) end)
				infoText:SetColor("white")
				infoText:DisableHitTest()
		
				local infoPopupbg = Bitmap(infoText) -- the borders of the windows
				infoPopupbg:SetSolidColor('white')
				infoPopupbg:SetAlpha(.6)
				infoPopupbg.Depth:Set(function() return infoText.Depth()-2 end)
				local infoPopup = Bitmap(infoText)
				infoPopup:SetSolidColor('black')
				infoPopup:SetAlpha(.6)	
				infoPopupbg.Depth:Set(function() return infoText.Depth()-1 end)
		
				infoPopup.Width:Set(function() return infoText.Width() + LayoutHelpers.ScaleNumber(8) end)
				infoPopup.Height:Set(function() return infoText.Height() + LayoutHelpers.ScaleNumber(8) end)
				LayoutHelpers.AtLeftBottomIn(infoPopup, infoText, -4, -4)
				infoPopupbg.Width:Set(function() return infoPopup.Width() + LayoutHelpers.ScaleNumber(2) end)
				infoPopupbg.Height:Set(function() return infoPopup.Height() + LayoutHelpers.ScaleNumber(2) end)
				LayoutHelpers.AtLeftBottomIn(infoPopupbg, infoPopup, -1, -1)
			end
		end
	end)
end
	if create_anime_graph2 then KillThread(create_anime_graph2) end
		create_anime_graph2 = ForkThread(function()
		local periode=0  -- the number of the saved used
		local x=parent.Left()+ x1  -- the current position on x
		local dist=(x2-x1)/(data_nbr) -- the distance on the screen between two saved
		--LOG("dist:",dist)
		local delta_refresh=(x2-x1)/(6*size) -- the distance in time between the smallest halt possible to make a refresh
		local delta=0 -- counter for refresh and small halt
		
		local line={} -- containe for the actual periode of time all the data to be draw
		
		--if graph!=nil and graph then graph:Destroy() graph=false end
		graph2={} -- will containt a table for each line and each line will be a table of bitmap
		for index, dat in player do 	graph2[dat.index]={}  	end -- init the different line
		
		local current_player_index=0  -- if 0 we are in replay, otherwise will show the graph to emphasize
		if not gamemain.GetReplayState() then current_player_index=GetFocusArmy() end
		
		WaitSeconds(0.001) -- give time to refresh and displayed the background
		
		inc_periode=((data_nbr)/(x2-x1)) -- give the increment on the screen between each periode (i.e. between each saved)
		if inc_periode<1 then inc_periode=1 end -- can not be <1 => use the whole screen
		
		local nbr=1 -- couting the number of iterancy done
		-- ============ starting
		t=CurrentTime()
		WaitFrames(10)
		t1=CurrentTime()
		LOG("------- calculating the timing of the frame")
		LOG("Time to display 1 frame (calculate with 10 frames):",(t1-t)/10,'  t:',t,'   t1:',t1)
		delta_refresh=(x2-x1)*(t1-t)/10*( (player_nbr+1)/4)
		LOG("So refresh all the ",delta_refresh," pixels displayed (delta_refresh:)")
		while periode<data_nbr do
			nbr=nbr+1
			periode=math.floor(nbr*inc_periode) -- calculate the next periode to use (i.e. skip some of them it more value than the screen can display)
			local tot=0
			-- prepare the data, calculate the ya=start y position and the yb=end position of the ligne for each player for this periode
			for index, dat in player do
				if periode==1 then val=0 else val=return_value(periode-1,dat.index,path) end 
				if val==nil or val<0.01 or val==false then val=0 end
				ya=val
				local val=return_value(periode,dat.index,path) --{"general","currentunits","count"}
				if val==nil or val<0.01 or val==false then val=0 end
				yb=val
				-- put all the data in this table
				line[dat.index]={grp=grp,ya=ya,yb=yb,y=ya,  -- note: y is the current position for this graph; the x is commun to all graph
					color=dat.color,index=dat.index,value=val,
					y_factor=(yb-ya)/dist*size} -- important: the factor of deplacement for the bitmap
			end

			local totaux=0

			local sav_x=x
			while (x<(parent.Left()+ x1 + nbr*dist) and x<(x2+parent.Left()))  do 
				totaux=0
				for name,data in line do
					totaux=totaux+ data.ya+(data.yb - data.ya)*((x-sav_x)/dist)
					--data.ya*(1-data.yb*(x/sav_x)/data.ya)
				end
				local factor=0
				if totaux!=0 then  factor=(y2-y1)/totaux end
				
				local ya_draw=y2
				local yb_draw=0
				for name,data in line do
					yb_draw=ya_draw
					ya_draw=ya_draw-(data.ya+(data.yb - data.ya)*((x-sav_x)/dist))*factor
					--if ya_draw>y2 or ya_draw<0 then ya_draw=y2 end
					--if yb_draw>y2 or ya_draw<0 then yb_draw=y2 end
					--LOG(ya_draw, '     ',yb_draw)
					--data.ya*(1-data.yb*(x/sav_x)/data.ya)*factor
					--data.ya*factor*(x/sva_x)
					graph2[data.index][x-x1]=Bitmap(grp)
					graph2[data.index][x-x1].Left:Set(parent.Left() +x )
					--local yn=parent.Top() +data.y+data.y_factor/math.abs(data.y_factor)*size*((math.abs(data.y_factor)+1) )

					graph2[data.index][x-x1].Top:Set(parent.Top()+ya_draw)

					graph2[data.index][x-x1].Right:Set( graph2[data.index][x-x1].Left() +size )
					graph2[data.index][x-x1].Bottom:Set(parent.Top() +yb_draw) --+data.y)
					graph2[data.index][x-x1]:SetSolidColor(data.color)
					graph2[data.index][x-x1]:Depth(bg.Depth()+1)
--ZZZ					graph2[data.index][x-x1]:SetAlpha(.15)
					graph2[data.index][x-x1]:SetAlpha(.15)
				end
				
				x=x+size
				delta=delta+1
				if delta>delta_refresh then 
					WaitFrames(1) -- do the reshresh, should be far smaller to be smooth...
					delta=0 
				end
				
			end
		
		end
		
		-- ========= end of the drawing of the graph
		t=CurrentTime()
		LOG("total time:",t-t1)


			local j=1
	local quadrillage_horiz2={}
	local nbr_quadrillage_horiz2=4 -- how many horizontal axies
	while j<nbr_quadrillage_horiz2 do
		local tmp=j
		quadrillage_horiz2[j]={}
		quadrillage_horiz2[j].title_label=UIUtil.CreateText(grp,(math.floor((j-1)/(nbr_quadrillage_horiz2-2)*LayoutHelpers.ScaleNumber(100))).." %", 14, UIUtil.titleFont)
		quadrillage_horiz2[j].title_label.Left:Set(parent.Left() + x2 + LayoutHelpers.ScaleNumber(10))
		quadrillage_horiz2[j].title_label.Bottom:Set(parent.Top() + y2 - (y2-y1-LayoutHelpers.ScaleNumber(15))*((tmp-1)/(nbr_quadrillage_horiz2-2))+LayoutHelpers.ScaleNumber(1))
		quadrillage_horiz2[j].title_label:SetColor("gray")
		j=j+1
	end

		
	end)
	return grp
end

function CreateDialogTabs(parent, label, pos)
	local button = Checkbox(parent, pathuiimg.. '/score/score-tab-' ..pos.. '-normal.dds', pathuiimg.. '/score/score-tab-' ..pos.. '-active.dds', pathuiimg.. '/score/score-tab-' ..pos.. '-normal.dds', pathuiimg.. '/score/score-tab-' ..pos.. '-active.dds', pathuiimg.. '/score/score-tab-' ..pos.. '-normal.dds', pathuiimg.. '/score/score-tab-' ..pos.. '-normal.dds', "UI_Tab_Click_02", "UI_Tab_Rollover_02")
	button.label = UIUtil.CreateText(button, label, 16)
	LayoutHelpers.AtCenterIn(button.label, button)
	button.label:DisableHitTest()
	button.glow = Bitmap(button, pathuiimg.. '/score/button-glow.dds')
	LayoutHelpers.AtCenterIn(button.glow, button)
	
	button.glow:SetAlpha(0)
	local oldHandleEvent = button.HandleEvent
	button.HandleEvent = function(self, event)
		if not self:IsChecked() then
			if event.Type == 'MouseEnter' then
				button.glow:SetTexture(pathuiimg.. '/score/button-glow.dds')
				SCAEffect.FadeIn(button.glow, 0.3, 0, 0.5)
			elseif event.Type == 'MouseExit' then
				SCAEffect.FadeOut(button.glow, 0.3, 0.5, 0)
			elseif event.Type == 'ButtonPress' then
				button.glow:SetTexture(pathuiimg.. '/score/button-flash.dds')
				SCAEffect.PulseOnceAndFade(button.glow, 0.6, 0, 1, 0.5)
			end
			oldHandleEvent(self, event)
		end
	end
	return button
end


-- the starting function launch by the hook
function Set_graph(victory, showCampaign, operationVictoryTable, dialog, standardScore)
    LOG("called Set_graph...")
	scoreAccum.StopScoreUpdate()
	standardScore:Hide()
	page_active=Group(dialog)
	page_active.Left:Set(0)
	page_active.Top:Set(0)
	page_active.Right:Set(0)
	page_active.Bottom:Set(0)
	
	dialogBG = Bitmap(dialog)
	LayoutHelpers.FillParent(dialogBG, dialog)
	local obj=skinning.Set_Auto_9_Texture('main-bg', dialogBG, dialog, pathuiimg.. '/score/')
	dialogBG.Depth:Set(dialog.Depth() - 1)
	
    standardBtn = CreateDialogTabs(dialog, modcontrols_trad("Standard"), "l")
	LayoutHelpers.AtLeftIn(standardBtn, dialog, 44)
	LayoutHelpers.AtBottomIn(standardBtn, dialog, 73)
	standardBtn.Depth:Set(dialog.Depth() + 100)
	standardBtn.OnClick = function(self)
		if self:IsChecked() then
			return
		else
			clean_view()
			Title_score:SetText("")
			standardScore:Show()
			self:SetCheck(true)
			bar_btn:SetCheck(false)
			graph_btn:SetCheck(false)
			dual_btn:SetCheck(false)
		end
	end
	
	-- main title
	Title_score=UIUtil.CreateText(dialog,modcontrols_trad("Score"), 24, UIUtil.titleFont)
	Title_score:SetColor("white")	
	LayoutHelpers.AtLeftTopIn(Title_score, GetFrame(0), 100, 78)

	bar_btn = CreateDialogTabs(dialog, modcontrols_trad("Chart"), "m")
	LayoutHelpers.AtLeftIn(bar_btn, dialog, 185)
	LayoutHelpers.AtBottomIn(bar_btn, dialog, 73)
	bar_btn:UseAlphaHitTest(false)
	bar_btn.Depth:Set(dialog.Depth() + 100)
	bar_btn.OnClick = function(self)
		if self:IsChecked() then
			return
		else
			page_bar(dialog)
			standardScore:Hide()
			self:SetCheck(true)
			standardBtn:SetCheck(false)
			graph_btn:SetCheck(false)
			dual_btn:SetCheck(false)
		end
	end	


	graph_btn = CreateDialogTabs(dialog, modcontrols_trad("Graph"), "m")
	LayoutHelpers.AtLeftIn(graph_btn, dialog, 326)
	LayoutHelpers.AtBottomIn(graph_btn, dialog, 73)
	graph_btn:UseAlphaHitTest(false)
	graph_btn.Depth:Set(dialog.Depth() + 100)
	graph_btn.OnClick = function(self)
		if self:IsChecked() then
			return
		else
			page_graph(dialog)	
			standardScore:Hide()
			Title_score:SetText(modcontrols_trad("Score"))
			self:SetCheck(true)
			bar_btn:SetCheck(false)
			standardBtn:SetCheck(false)
			dual_btn:SetCheck(false)
		end
	end	
	
	dual_btn = CreateDialogTabs(dialog, "Dual", "r")
	LayoutHelpers.AtLeftIn(dual_btn, dialog, 467)
	LayoutHelpers.AtBottomIn(dual_btn, dialog, 73)
	dual_btn:UseAlphaHitTest(false)
	dual_btn.Depth:Set(dialog.Depth() + 100)
	dual_btn.OnClick = function(self)
		if self:IsChecked() then
			return
		else
			clean_view()
			page_dual(dialog)
			standardScore:Hide()
			Title_score:SetText(modcontrols_trad("Score"))
			self:SetCheck(true)
			bar_btn:SetCheck(false)
			standardBtn:SetCheck(false)
			graph_btn:SetCheck(false)
		end
	end	
	
	
	graph_btn:SetCheck(true)
	page_graph(dialog)
	-- create first graph
	--graph=create_graph(dialog,info.dialog[5].path,120,140,GetFrame(0).Right()-120,GetFrame(0).Bottom()-140)



	local beta=Bitmap(dialog)
	beta:SetTexture(mySkinnableFile(pathuiimg..'/bt_sca.dds'))
	LayoutHelpers.AtRightTopIn(beta,GetFrame(0),99,67)
	
end
