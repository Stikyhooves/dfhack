local utils = require 'utils'
local gui = require('gui')
local widgets = require('gui.widgets')


function get_caste_name(race, caste, profession)
    return dfhack.units.getCasteProfessionName(race, caste, profession)
end

VistorsWindow = defclass(VistorsWindow, widgets.Window)
VistorsWindow.ATTRS {
    frame_title='Current Petitioners',
    frame={w=80, h=31},
    resizable=true,
    resize_min={w=50, h=20},
}

function VistorsWindow:init()
    self:addviews{
	    widgets.WrappedLabel{  -- Holding this space in case 
            frame={l=0, r=0, t=0},
            text_to_wrap='Click on a petitioner to center on them for futher inspection.', 
        },
        widgets.List{
            frame={l=0, r=0, t=3, b=6},
            view_id = 'list',
            on_select=self:callback('onZoom'),
           -- on_double_click=self:callback('onIgnore'),
           -- on_double_click2=self:callback('onToggleGroup'),
        },
    }
    self:initListChoices()
end

function VistorsWindow:initListChoices()
 
-- Checks for current peitions/petitioners 
-- Not tested for troupes

        local choices = {}
        for _,p in pairs (df.global.plotinfo.petitions) do  -- for each petition on screen
        local petition_id = p
            for _,agmt in pairs(df.global.world.agreements.all) do --- Get agreement full list
                local agreement_id = agmt.id  -- compare agreement id to petition id
                if agreement_id == petition_id then                     
                    party0_unit = df.global.world.agreements.all[agreement_id].parties[0].histfig_ids[0]
                
                    for _,u in pairs(df.global.world.units.active) do -- now check those hfigs against unit ids to get info on them (may be improved)
			local unit_hxfig_id = u.hist_figure_id
			if unit_hxfig_id == party0_unit then 
				--print(unit_hxfig_id, " - " , party0_unit)
				local u_name = dfhack.translation.translateName(u.name)
				local trans_name = dfhack.translation.translateName(u.name, true, true)
				local u_caste = get_caste_name(u.race, u.caste, u.profession)
				local u_race = dfhack.units.getRaceName(u)
				--print(u_race)
				if df.global.world.agreements.all[agmt.id].details[0].type == 2 then 
					text = "Residency: "..u_name .. " (" .. trans_name.. ") - " .. u_caste .. " (" .. u_race .. ")"
					--table.insert(choices, {text=text, data={unit=u, group=groupIndex}})
					table.insert(choices, {text=text, data={unit=u, group=0}})
				
				elseif df.global.world.agreements.all[i.id].details[0].type == 3 then     
					text = "Citizenship: ".. u_name .. " (" .. trans_name.. ") - " .. u_caste        
					--table.insert(choices, {text=text, data={unit=u, group=groupIndex}})
					table.insert(choices, {text=text, data={unit=u, group=0}})
					
				end
			end
                    end
                end
            end
        end
        self.subviews.list:setChoices(choices)     
end

function VistorsWindow:onZoom()
    local _, choice = self.subviews.list:getSelected()
    local unit = choice.data.unit

    local target = xyz2pos(dfhack.units.getPosition(unit))
    dfhack.gui.revealInDwarfmodeMap(target, true, true)
end

VistorsScreen = defclass(VistorsScreen, gui.ZScreen)
VistorsScreen.ATTRS {
    focus_path='VistorsScreen',
}

function VistorsScreen:init()
    self:addviews{VistorsWindow{}}
end

function VistorsScreen:onDismiss()
    view = nil
end

view = view and view:raise() or VistorsScreen{}:show()
