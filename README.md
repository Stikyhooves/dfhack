# Dfhack scripts:
## Script: relationsexporter.lua
The code in this script was heavily borrowed from Ramblur's now defunct family.lua script.  
(https://github.com/Ramblurr/dfhack/blob/f585ecf4831fc19badc97b37e27cd4ccc7874c44/scripts/family.lua (2/18/2025))  
The original script did single dwarf selection, exporting information for the selected dwarf's family only.   
This script runs a loop through all active dwarves to get immediate relations that are defined as hfigs.   

It generates three primary exports:  

1: A csv of the your citizens and thier relationships. This includes spouse, father, mother, lover, child, diety, and deceased pet relations. The limitation to relationships is based on what relationships are stored in the histfig data. This may be why (in my observation) only deceased pets are listed. There is also an indication of if the related entity is living or dead.   

The data is presented as:  
- **Fields Related to the main unit:** Dorf_uid,Dorf_hfid,Dorf_Race, Dorf_Name, Dorf_Gender, Dorf_BirthYear, Dorf_DeathYear, Dorf_Age, Dorf_Goal 
- **Fields Related to the related unit:** Relation_Code, Relation_Type, Relation_hfid, Relation_Name, Relation_Gender, Relation_Living
  
2: A csv of your dwarves and their goals. This is just something I wanted handy but it not related to relationships. In some ways it is just a simplifed copy of the first export.   
- **Fields:** Unit_id,HxId,Name,Caste,Race,Gender,Born,Died,Age,Goal
         
3: The relationships for lovers, spouses, and children as a graphviz digraph code. This outputs directly to the df hack output window so that it can be copy/pasted directly  into a visualizer. This can be used with any graphviz generator such as https://dreampuf.github.io/GraphvizOnline/  
