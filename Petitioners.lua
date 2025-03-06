--@ module = true

local dialogs = require('gui.dialogs')
local gui = require('gui')
local overlay = require('plugins.overlay')
local utils = require('utils')
local widgets = require('gui.widgets')

--
-- Other called functions
--

function get_caste_name(race, caste, profession)
    return dfhack.units.getCasteProfessionName(race, caste, profession)
end

function get_hfighex(hf_id) --keep
--- Retrieves the hex value of a histfig.
    return utils.binsearch(df.global.world.history.figures, hf_id, 'id')
end

function personalityissues(u)

    HATE_PROPENSITY =  u.status.current_soul.personality.traits[1]   
    if HATE_PROPENSITY >90 then
        HATE_PROPENSITY_D = "is often inflamed by hatred and easily develops hatred toward things. "
    elseif HATE_PROPENSITY >75 then
        HATE_PROPENSITY_D = "is prone to hatreds and often develops negative feelings. "
    else
        HATE_PROPENSITY_D = ""
    end
        
    DEPRESSION_PROPENSITY =  u.status.current_soul.personality.traits[4]
    if DEPRESSION_PROPENSITY >90 then
        DEPRESSION_PROPENSITY_D = "is frequently depressed. (More likely to slip into depression and be stricken by melancholy.) "
    elseif DEPRESSION_PROPENSITY >75 then
        DEPRESSION_PROPENSITY_D = "is often sad and dejected. (More likely to slip into depression and be stricken by melancholy.) "
    elseif DEPRESSION_PROPENSITY >60 then
        DEPRESSION_PROPENSITY_D = "often feels discouraged. (More likely to slip into depression and be stricken by melancholy.) "
    else
        DEPRESSION_PROPENSITY_D = ""
    end
    
    ANGER_PROPENSITY =  u.status.current_soul.personality.traits[5]   
    if ANGER_PROPENSITY >90 then
        ANGER_PROPENSITY_D = "is in a constant state of internal rage. (More likely to throw tantrums and go berserk.) "
    elseif ANGER_PROPENSITY >75 then
        ANGER_PROPENSITY_D = "is very quick to anger. (More likely to throw tantrums and go berserk.) "
    elseif ANGER_PROPENSITY >60 then
        ANGER_PROPENSITY_D = "is quick to anger. (More likely to throw tantrums and go berserk.) "
    else
        ANGER_PROPENSITY_D = ""
    end
    
    ANXIETY_PROPENSITY =  u.status.current_soul.personality.traits[6]
    if ANXIETY_PROPENSITY >90 then
        ANXIETY_PROPENSITY_D = "is a nervous wreck. (More likely to stumble obliviously and go stark raving mad.) "
    elseif ANXIETY_PROPENSITY >75 then
        ANXIETY_PROPENSITY_D = "is always tense and jittery. (More likely to stumble obliviously and go stark raving mad.) "
    elseif ANXIETY_PROPENSITY >60 then
        ANXIETY_PROPENSITY_D = "is often nervous. (More likely to stumble obliviously and go stark raving mad.) "
    else
        ANXIETY_PROPENSITY_D = ""
    end
    
    STRESS_VULNERABILITY =  u.status.current_soul.personality.traits[8]   
    if STRESS_VULNERABILITY >90 then
        STRESS_VULNERABILITY_D = "becomes completely helpless in stressful situations. (50% chance to become catatonic) "
    else
        STRESS_VULNERABILITY_D = ""
    end
    
    IMMODERATION =  u.status.current_soul.personality.traits[10]   
    if IMMODERATION >90 then
        IMMODERATION_D = "is ruled by irresistible cravings and urges. "
    elseif IMMODERATION >75 then
        IMMODERATION_D = "feels strong urges and seeks short-term rewards. "
    else
        IMMODERATION_D = ""
    end
    
    VIOLENT =  u.status.current_soul.personality.traits[11]    
    if VIOLENT >90 then
        VIOLENT_D = "is given to rough-and-tumble brawling, even to the point of starting fights for no reason. "
    elseif VIOLENT >75 then
        VIOLENT_D = "would never pass up a chance for a good fistfight. "
    elseif VIOLENT >60 then
        VIOLENT_D  = "likes to brawl. "
    else
        VIOLENT_D = ""
    end
    
    personalityissuesum =   DEPRESSION_PROPENSITY_D .. ANGER_PROPENSITY_D .. ANXIETY_PROPENSITY_D .. STRESS_VULNERABILITY_D .. IMMODERATION_D .. VIOLENT_D
    
    return  personalityissuesum
           
end

-- -------------------
-- PetitionerOverlay
--

PetitionerOverlay = defclass(PetitionerOverlay, overlay.OverlayWidget)
PetitionerOverlay.ATTRS{
    desc='Adds a button to launch the petitioner gui.',
    --default_pos={x=58,y=28},-- position just under Approve Deny buttons
    default_pos={x=85,y=22},-- position to the right of the Approve Deny buttons
    version=2,
    default_enabled=true,
    viewscreens={'dwarfmode/Petitions'},
    frame={w=20, h=5},
    frame_background=gui.CLEAR_PEN,
}


local function show_petioner_screen()
    return PetitionerScreen{
        dfhack.run_script('Petitioners'),
    }:show()
end

function PetitionerOverlay:init()
    self:addviews{
        widgets.Panel{
        frame={b=0, r=0, w=20, h=4},
        frame_style=gui.MEDIUM_FRAME,
        frame_background=gui.CLEAR_PEN,
        visible=true,
        subviews={
            widgets.Label{
                text={
                    '  Click to open', NEWLINE,
                    'petitioner screen  ',
                    },
                on_click= show_petioner_screen,
                --on_click=function()view = view and view:raise() or PetitionerScreen{}:show() end,
                },
            },
        },
    }
end

OVERLAY_WIDGETS = {PetitionerButton=PetitionerOverlay}

--
-- PetitionersWindow
--

PetitionersWindow = defclass(PetitionersWindow, widgets.Window)
PetitionersWindow.ATTRS {
    frame_title='Current Petitioners',
    frame={w=80, h=28, l=6, b=4},
    resizable=true,
    resize_min={w=50, h=20},
}


function PetitionersWindow:init()
    self:addviews{
        widgets.WrappedLabel{
            frame={l=0, r=0, t=0},
            text_to_wrap='Click on a petitioner to center on them for futher inspection.',
        },
        widgets.List{
            frame={l=0, r=0, t=3, b=6},
            view_id = 'list',
            on_select=self:callback('onZoom'),
            -- consider if this should just open the unit menus
        },
        widgets.Panel{
            view_id='footer',
            frame={l=0, r=0, b=0, h=10},
            frame_style=gui.FRAME_INTERIOR,
            subviews={
                widgets.WrappedLabel{
                    frame={l=0, h=7},
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

function PetitionersWindow:initListChoices()
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
                            local u_race = ""
                            if  dfhack.units.getRaceName(u) == "DWARF" then
                                u_race = " (" .. dfhack.units.getRaceName(u) .. ")"
                                else
                            end
                           
                            local petitioner_goal = dfhack.units.getGoalName(u,0)
                            local petitioner_pfacets = personalityissues(u)
                            local petitiontype = ""
                           
                            if df.global.world.agreements.all[agmt.id].details[0].type == 2 then
                                petitiontype = "Residency: "
                            elseif df.global.world.agreements.all[agmt.id].details[0].type == 3 then    
                                petitiontype = "Citizenship: "
                            end   
                           
                            text = petitiontype ..u_name .. " (" .. trans_name.. ") - " .. u_caste .. u_race
                            text_long = petitiontype ..u_name .. " (" .. trans_name.. ") - " .. u_caste .. u_race .. " \nGoal: " .. petitioner_goal .. " \nPossible Personality Issues: " .. petitioner_pfacets
                            
                            table.insert(choices, {text=text, text_long=text_long, data={unit=u, group=0}})
                           
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
                                local petitioner_pfacets = personalityissues(u)
                                local u_race = ""
                                if  dfhack.units.getRaceName(u) == "DWARF" then
                                    u_race = " (" .. dfhack.units.getRaceName(u) .. ")"
                                    else
                                end
                               
                                text = group_name..": ".. u_name .. " (" .. trans_name.. ") - " .. u_caste .. u_race  
                                text_long = group_name..": " ..u_name .. " (" .. trans_name.. ") - " .. u_caste .. u_race .. " \nGoal: " .. petitioner_goal .. " \nPossible Personality Issues: " .. petitioner_pfacets
                               
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

function PetitionersWindow:onZoom()
    local _, choice = self.subviews.list:getSelected()
    local unit = choice.data.unit
    local target = xyz2pos(dfhack.units.getPosition(unit))
    dfhack.gui.revealInDwarfmodeMap(target, true, true) --- draw focus to selected unit
   
    local desc = self.subviews.desc
    if desc.frame_body then desc:updateLayout() end --- update view with new focus text
   
end

-- -------------------
-- PetitionerScreen
--

PetitionerScreen = defclass(PetitionerScreen, gui.ZScreen)
PetitionerScreen.ATTRS {
    focus_path='PetitionerScreen',
}

function PetitionerScreen:init()
    self:addviews{PetitionersWindow{}}
end

function PetitionerScreen:onRenderFrame()
    if view and not self.is_valid_ui_state() then
        view:dismiss()
    end
end

function PetitionerScreen:onDismiss()
    view = nil
end
