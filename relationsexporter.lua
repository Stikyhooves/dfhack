local utils = require 'utils'


----------------------------------------------------------
---- Note: This code was heavily borrowed from Ramblur's now defunct family.lua script. 
---- from: https://github.com/Ramblurr/dfhack/blob/f585ecf4831fc19badc97b37e27cd4ccc7874c44/scripts/family.lua (2/18/2025)
---- The original script did single dwarf selection, exporting information for the selected dwarf's family only. 
---- This script runs a loop through all active dwarves to get immediate relations that are defined as hfigs. 
----- It generates three primary exports:
----- 		1: A csv of the relationships. This includes diety and deceased pet relations. 
----- 		2: A csv of your dwarves and their goals. This is just something I wanted handy but it not related to relationships.
----- 		3: The relationships for lovers, spouses, and children as a graphviz digraph code. This outputs directly to the df hack output window so that it can be ----- 		   copy/pasted directly into a visualizer. This can be used with any graphviz generator such as https://dreampuf.github.io/GraphvizOnline/
----------------------------------------------------------

function get_caste_name(race, caste, profession)
    return dfhack.units.getCasteProfessionName(race, caste, profession)
end

function get_birthyear(hf_id)
	return get_hfighex(hf_id).born_year
end

function get_deathyear(hf_id)
	local deathyear = get_hfighex(hf_id).died_year
    if deathyear == -1 then
        deathyear = ''
    end
	return deathyear
end

function gender_read(sex)
--- Function is used to define gender types based on the enum values. 
    if sex == 0 then
        return  "female"
    elseif sex == 1 then
        return "male"
    end
    return "unknown"
end


function get_hfighex(hf_id) --keep
--- Retrieves the hex value of a histfig. 
    return utils.binsearch(df.global.world.history.figures, hf_id, 'id')
end

function wrap(id, gen)
    return {['id'] = id, ['gen'] = gen}
end


function get_reltype(linkrelation)
--- Function is used to define relatiohsip types based on the enum values. 
	if linkrelation == 0 then
		return 'Mother'
	elseif linkrelation == 1 then
		return 'Father'
	elseif linkrelation == 2 then
		return 'Spouse'
	elseif linkrelation == 3	then
		return 'Child'
	elseif linkrelation == 4	then
		return 'Diety'
	elseif linkrelation == 5	then
		return 'Lover'
	elseif linkrelation == 14 then
		return 'Pet - Deceased'
	else 
		return 'Unknown'
	end

end

function get_gendercolor(dorf_gender)
--- Function is used to assign node colors in digraph based on gender
	if dorf_gender == 'female' then 
		return 'plum3' 
	elseif  dorf_gender == 'male' then 
		return 'cornflowerblue'
	else
		return 'grey'
	end

end


function generategraphnode_hfig(hfig_id)

	hfig_name = dfhack.translation.translateName(get_hfighex(hfig_id).name)
	hfig_gender = gender_read(get_hfighex(hfig_id).sex)
	hfig_caste = ""
	-------------------------
	--checks if fig is in the fort
	hfigfortcount = 0
	for _, dorfcitz in ipairs(dfhack.units.getCitizens(true, true)) do
		
		if dorfcitz.hist_figure_id == hfig_id then
			hfigfortcount = hfigfortcount +1
			hfig_caste = get_caste_name(dorfcitz.race, dorfcitz.caste, dorfcitz.profession)
		end
	end
	
	if hfigfortcount >0 then	
		hfig_infort = 'Present'
	else
		hfig_infort = 'Absent'
	end
	-------------------------

	if get_deathyear(hfig_id) ~= '' then 
		hfig_status = '(Deceased)'
		hfig_nodecolor = 'grey52'
	else 
		hfig_status = '' 
		if hfig_infort == 'Present' then
			hfig_nodecolor = get_gendercolor(hfig_gender)
		else
			hfig_nodecolor = 'grey80'
		end
	end
	
	print("\""..hfig_id.."\"", " [label= \""..hfig_name.. "\\n" ..hfig_status .. hfig_caste .. "\"".. "style=filled color=", hfig_nodecolor, " shape=Mrecord]") 


end


local function relations()

	local FortSite = dfhack.world.getCurrentSite()
	local FortName = dfhack.translation.translateName(FortSite.name)
	
	------- Create Tables and Headers ------ 
	local CitizenTable = {}
    local CitizenTable_header = "Unit_id,HxId,Name,Caste,Race,Gender,Born,Died,Age,Goal,Relatives_living,Spouses,Lovers,Children \n"
	
	local Relations ={}
	local relationheader ="Dorf_uid,Dorf_hfid,Dorf_Race, Dorf_Name, Dorf_Gender, Dorf_BirthYear, Dorf_DeathYear, Dorf_Age, Dorf_Goal ,Relation_Code, Relation_Type, Relation_hfid, Relation_Name, Relation_Gender, Relation_Living \n"
	--------------------------------------
	
	i = 1 --clear count
	
	----------Begin Output for Digraph Code ------------------
	-------- This acts like a header for the graph defs ------ 
	print("----------START OF DIGRAPH----------")
	print("")
	print("")
	print("")
	print("Digraph Dorf_Relations {")
	print("concentrate=true overlap=none graph[rankdir=RL] labelloc=",'"t"'," label=",'"',"The Fortress of ", FortName ,'"'," fontsize=",'"',"30pt",'"'," fontname=",'"',"Helvetica,Arial,sans-serif",'"'," node [fontsize=",'"',"12pt",'"'," fontname=",'"',"Helvetica,Arial,sans-serif",'"',"]")
	
	---------------------------------------------------------

	
    for _, dorfcitz in ipairs(dfhack.units.getCitizens(true, true)) do
		
		local dorf_hex = dorfcitz
		local dorf_uid = dorfcitz.id
		local dorf_hxfig_hex = get_hfighex(dorfcitz.id)
		local dorf_hxfig_id = dorfcitz.hist_figure_id
		local dorf_name = dfhack.translation.translateName(dorf_hex.name)
		local dorf_gender = gender_read(dorf_hex.sex)
		local dorf_age = math.floor(dfhack.units.getAge(dorf_hex, true))
		local caste = get_caste_name(dorfcitz.race, dorfcitz.caste, dorfcitz.profession)
		local dorf_race = dfhack.units.getRaceName(dorf_hex) --mostly duh...  
		local dorf_goal = dfhack.units.getGoalName(dorf_hex,0)
		
		if get_deathyear(dorf_hxfig_id) ~= '' then 
			dorf_gendercolor = "grey" 
		else
			dorf_gendercolor = get_gendercolor(dorf_gender)
		end
		
		---- The code related to branching is from to Ramblurr's original family.lua (see notes above)
		---- not all of it is nessecary, but it is delicate so I left it intact to keep it from breaking. 
		
		local queue = {}
		-- nil = unseen, false = queued, true = visted
		local visited = {}
		local MAX = 10000 -- prevent very long running ops
		local counter = 0
		local max_generations =  1
		local max_spouse_branches = 0
		local spouse_gen = max_generations - max_spouse_branches
		
		-----------------------------------------------------------------		
		-------- THIS IS PURPOSEFULLY DUPLICATIVE CODE ------------------
		----- This checks for the count of relations for the digraph ---- 
		-----------------------------------------------------------------
		queue[1] = wrap(dorf_hxfig_id, 0) -- starting dwarf is generation 0
		while counter < MAX and #queue > 0 do
			counter = counter+1
			local node = queue[1]
			table.remove(queue, 1)
			visited[node.id] = true
			relcount = 0
			relcount_living = 0
			relcount_children = 0
			relcount_spouse = 0
			relcount_lover = 0
			local hfig_hex = utils.binsearch(df.global.world.history.figures, node.id, 'id')
			if node.gen < max_generations then -- this is not in use as we only go by 1st connections
				for _,link in ipairs(hfig_hex.histfig_links) do
					reldorf = link.target_hf
					relcode = link:getType()
					reltype = get_reltype(relcode)

					if reltype == 'Mother' then 
						relcount = relcount +1
						if get_deathyear(reldorf) == '' then 
							relcount_living = relcount_living +1
						end
					elseif reltype == 'Father' then 
						relcount = relcount +1
						if get_deathyear(reldorf) == '' then 
							relcount_living = relcount_living +1
						end
					elseif reltype == 'Spouse' then 
						relcount = relcount +1
						if get_deathyear(reldorf) == '' then 
							relcount_living = relcount_living +1
							relcount_spouse = relcount_spouse +1
						end
					elseif reltype == 'Child' then 
						relcount = relcount +1
						if get_deathyear(reldorf) == '' then 
							relcount_living = relcount_living +1
							relcount_children = relcount_children +1
						end
					elseif reltype == 'Lover' then 
						relcount = relcount +1
						if get_deathyear(reldorf) == '' then 
							relcount_living = relcount_living +1
							relcount_lover = relcount_lover +1
						end
					end
					
				end
			end
			
		end
		-----------------------------------------------------------------
	
		-- Add row to citizen table
		CitizenTable[dorf_hex] = string.format('%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s \n', dorf_uid,dorf_hxfig_id,dorf_name,caste,dorf_race,dorf_gender,get_birthyear(dorf_hxfig_id),get_deathyear(dorf_hxfig_id),dorf_age,dorf_goal,relcount_living,relcount_spouse,relcount_lover,relcount_children)

		---------------------------------		
		----- As noted before: 
		---- The code related to branching is from to Ramblurr's original family.lua (see notes above)
		---- not all of it is nessecary, but it is delicate so I left it intact to keep it from breaking. 
		queue[1] = wrap(dorf_hxfig_id, 0) -- starting dwarf is generation 0
		while counter < MAX and #queue > 0 do
			counter = counter+1
			local node = queue[1]
			table.remove(queue, 1)
			visited[node.id] = true

			local hfig_hex = utils.binsearch(df.global.world.history.figures, node.id, 'id')
			if node.gen < max_generations then -- this is not in use as we only go by 1st connections
				for _,link in ipairs(hfig_hex.histfig_links) do
					reldorf = link.target_hf
					relcode = link:getType()
					reltype = get_reltype(relcode)
					reldorfname = dfhack.translation.translateName(get_hfighex(reldorf).name)
					if reltype == 'Diety' then relstatus = 'Unknown' 
						elseif get_deathyear(reldorf) ~= '' then relstatus = 'Deceased'
						else relstatus = 'Alive'
					end
					reldorfgender = gender_read(get_hfighex(reldorf).sex)
					if get_deathyear(reldorf) ~= '' then 
						relgendercolor = "grey"
					else
						relgendercolor = get_gendercolor(reldorfgender) 
					end
					
					---------------------------------					
					---- Add row to relations table
					Relations[i] = string.format(
						'%s,%s,%s,%s,%s,%s ,%s,%s ,%s,%s ,%s,%s ,%s,%s ,%s \n',
						dorf_uid, dorf_hxfig_id, dfhack.units.getRaceName(dorf_hex),dorf_name, dorf_gender, get_birthyear(dorf_hxfig_id),get_deathyear(dorf_hxfig_id),dorf_age ,dorf_goal,
						relcode, reltype, reldorf, reldorfname, reldorfgender, relstatus )

					--------------------------------
					---------------------------------
					---- Print Edge For Graphviz ----
					---- Omitting dieties as they make the graph messy --
					---- Note: Pet relations seem to only be for deceased pets --- 
				
					--- Define starting node
					RelationStart = math.max(dorf_hxfig_id,reldorf) 
					if RelationStart == dorf_hxfig_id then
						RelationStartName = dorf_name
						---start is main fort dorf
					else 
						--start is related dorf
						RelationStartName = reldorfname				
					end
					
					--- Define ending node
					RelationEnd = math.min(dorf_hxfig_id,reldorf)
					if RelationEnd == dorf_hxfig_id then
						---end is main fort dorf
						RelationEndName = dorf_name
					else 
						--end is related dorf
						RelationEndName = reldorfname			
					end			
					
					if reltype == 'Mother' then 
						generategraphnode_hfig(dorf_hxfig_id)
						generategraphnode_hfig(reldorf)
						print("\""..RelationStart.."\"->\"".. RelationEnd .."\"[style=dashed dir=both color=plum3  arrowhead=none arrowtail=normal]")
					elseif reltype == 'Father' then 
						generategraphnode_hfig(dorf_hxfig_id)
						generategraphnode_hfig(reldorf)
						print("\""..RelationStart.."\"->\"".. RelationEnd .."\"[style=dashed dir=both color=cornflowerblue arrowhead=none arrowtail=normal]")
					elseif reltype == 'Spouse' then 
						generategraphnode_hfig(dorf_hxfig_id)
						generategraphnode_hfig(reldorf)
						print("\""..RelationStart.."\"->\"".. RelationEnd .."\" [style=solid color=darkslategray4  dir=both penwidth = 2 arrowhead=inv arrowtail=inv]")
					elseif reltype == 'Child' then 
						generategraphnode_hfig(dorf_hxfig_id)
						generategraphnode_hfig(reldorf)
						print("\""..RelationStart.."\"->\"".. RelationEnd .."\"[style=dashed color=" .. relgendercolor.. "  dir=both arrowhead=none arrowtail=normal]")
						--end
					elseif reltype == 'Lover' then 
						generategraphnode_hfig(dorf_hxfig_id)
						generategraphnode_hfig(reldorf)
						print("\""..RelationStart.."\"->\"".. RelationEnd .."\"[style=solid color=magenta dir=both penwidth = 2 arrowhead=inv arrowtail=inv]")
					end
					---------------------------------
						i = i+1
						
				end
			end
		end

   end

	print("}")
	print("")
	print("")
	print("")
	print("----------END OF DIGRAPH----------")
	
	
	local f = io.open(FortName .. "_RelationsTable_" .. os.date("%Y".. "_" .. "%m".."_".. "%d") .. ".csv", "w")
    f:write(relationheader)
    for _,p in pairs(Relations) do
        f:write(p)
    end
    f:close()

	local f = io.open(FortName .. "_CitizenTable_" .. os.date("%Y".. "_" .. "%m".."_".. "%d") .. ".csv", "w")
    f:write(CitizenTable_header)
    for _,p in pairs(CitizenTable) do
        f:write(p)
    end
    f:close()
	
	print("Exported: " .. FortName .. "_RelationsTable_" .. os.date("%Y".. "_" .. "%m".."_".. "%d") .. ".csv")
    print("Exported: " .. FortName .. "_CitizenTable_" .. os.date("%Y".. "_" .. "%m".."_".. "%d") .. ".csv")
	
end

relations()
