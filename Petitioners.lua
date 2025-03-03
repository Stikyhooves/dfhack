local utils = require 'utils'
local gui = require('gui')
local widgets = require('gui.widgets')


function get_caste_name(race, caste, profession)
    return dfhack.units.getCasteProfessionName(race, caste, profession)
end


function get_hfighex(hf_id) --keep
--- Retrieves the hex value of a histfig. 
    return utils.binsearch(df.global.world.history.figures, hf_id, 'id')
end



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
        },
        widgets.Panel{
            view_id='footer',
            frame={l=0, r=0, b=0, h=7},
            frame_style=gui.FRAME_INTERIOR,
            subviews={
                widgets.WrappedLabel{
                    frame={l=0, h=6},
                    view_id='desc',
                    auto_height=false,
                    text_to_wrap=function()
                        local list = self.subviews.list
                        local _, choice = list:getSelected()
                        return choice and choice.text_long or ''
                    end,
                },
            },
        },
    }
    self:initListChoices()
end

function VistorsWindow:initListChoices()

        local choices = {}
        for _,p in pairs (df.global.plotinfo.petitions) do  -- for each petition on screen
        local petition_id = p
            for _,agmt in pairs(df.global.world.agreements.all) do --- Get agreement full list
                local agreement_id = agmt.id  -- compare agreement id to petition id
                if agreement_id == petition_id then      
                    if #df.global.world.agreements.all[agreement_id].parties[0].histfig_ids ~=0 then  -- filters out cases where the hisfig is empty - such as with troupes
                    
                        party0_unit = df.global.world.agreements.all[agreement_id].parties[0].histfig_ids[0]
                    
                        for _,u in pairs(df.global.world.units.active) do -- now check those hfigs against unit ids to get info on them (may be improved)
                            local petitioner_hxfig_id = u.hist_figure_id
                            if petitioner_hxfig_id == party0_unit then 
 
                                
                                local petitioner_hxfig_hex = get_hfighex(u.id)
                                
                                local u_name = dfhack.translation.translateName(u.name)
                                local trans_name = dfhack.translation.translateName(u.name, true, true)
                                local u_caste = get_caste_name(u.race, u.caste, u.profession)
                                local u_race = dfhack.units.getRaceName(u)
                                local petitioner_goal = dfhack.units.getGoalName(u,0)
                                
                                
                                --print(u_race)
                                if df.global.world.agreements.all[agmt.id].details[0].type == 2 then 
                                    text = "Residency: "..u_name .. " (" .. trans_name.. ") - " .. u_caste .. " (" .. u_race .. ")"
                                    text_long = "Residency: "..u_name .. " (" .. trans_name.. ") - " .. u_caste .. " (" .. u_race .. ") \nGoal: " .. petitioner_goal 
                                    --table.insert(choices, {text=text, data={unit=u, group=groupIndex}})
                                    table.insert(choices, {text=text, text_long=text_long, data={unit=u, group=0}})
                                
                                elseif df.global.world.agreements.all[agmt.id].details[0].type == 3 then     
                                    text = "Citizenship: ".. u_name .. " (" .. trans_name.. ") - " .. u_caste .. " (" .. u_race .. ")"    
                                    text_long = "Citizenship: ".. u_name .. " (" .. trans_name.. ") - " .. u_caste .. " (" .. u_race .. ") \nGoal: " .. petitioner_goal    
                                    --table.insert(choices, {text=text, data={unit=u, group=groupIndex}})
                                    table.insert(choices, {text=text, text_long=text_long, data={unit=u, group=0}})
                                end    
                            end
                        end
                    else -- assumes petition is from a group since it was not from an individual
                        local group_id = df.global.world.agreements.all[agreement_id].parties[0].entity_ids[0]
                        local group_name = dfhack.translation.translateName(df.global.world.entities.all[group_id].name, true, true)
                        
                        for _,ent in pairs(df.global.world.entities.all[group_id].hist_figures) do -- for each unit in the group

                            for _,u in pairs(df.global.world.units.active) do  -- check unit against active units (used to get unit hex from histfig)
                                local petitioner_hxfig_id = u.hist_figure_id
                                if petitioner_hxfig_id == ent.id then 
                                
                                    local u_name = dfhack.translation.translateName(u.name)
                                    local trans_name = dfhack.translation.translateName(u.name, true, true)
                                    local u_caste = get_caste_name(u.race, u.caste, u.profession)
                                    local u_race = dfhack.units.getRaceName(u)
                                    local petitioner_goal = dfhack.units.getGoalName(u,0)         
                                    
                                    text = group_name..": ".. u_name .. " (" .. trans_name.. ") - " .. u_caste .. " (" .. u_race .. ")"  
                                    
                                    text_long = group_name..": ".. u_name .. " (" .. trans_name.. ") - " .. u_caste .. " (" .. u_race .. ") \nGoal: " .. petitioner_goal    
                                    
                                    table.insert(choices, {text=text, text_long=text_long, data={unit=u, group=0}})
                                end
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
    dfhack.gui.revealInDwarfmodeMap(target, true, true) --- draw focus to selected unit
    
    local desc = self.subviews.desc
    if desc.frame_body then desc:updateLayout() end --- update view with new focus text 
end


VistorsWindow = defclass(VistorsWindow, widgets.Window)
VistorsWindow.ATTRS {
    frame_title='Current Petitioners',
    frame={w=80, h=31, r=3, b=5},
    resizable=true,
    resize_min={w=50, h=20},
    
}

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
