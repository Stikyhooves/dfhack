# Dfhack scripts:
## Script: relationsexporter.lua
The code in this script was heavily borrowed from Ramblur's now defunct family.lua script.  
(https://github.com/Ramblurr/dfhack/blob/f585ecf4831fc19badc97b37e27cd4ccc7874c44/scripts/family.lua (2/18/2025))  
The original script did single dwarf selection, exporting information for the selected dwarf's family only. It had the ability to pull distant relations such as grandparents for a single entity. I have updated his script to make it operational and you may see it posted here. 
My script differs greatly in that it runs a loop through all active dwarves to get immediate relations that are defined as hfigs. You can get generational relationships, but only for units in your fortress or the immediate external ones. For example, a unit whose parent's have died will still show those parents, but if the parents and grandparents have died, you will only see the parents. Essentially, this script lets you see the whole fort.     

### It generates three primary exports:  

1: A csv of the your citizens and thier relationships. This includes spouse, father, mother, lover, child, deity, and deceased pet relations. The limitation to relationships is based on what relationships are stored in the histfig data. This may be why (in my observation) only deceased pets are listed. There is also an indication of if the related entity is living or dead. You can use this information to create your own digraphs if you feel handy. Otherwise you can use the digraph code output to get a graph. The benefit of this file is it will show you the deities of your dwarves.     

The data is presented as:  
- **Fields Related to the main unit:** Dorf_uid,Dorf_hfid,Dorf_Race, Dorf_Name, Dorf_Gender, Dorf_BirthYear, Dorf_DeathYear, Dorf_Age, Dorf_Goal 
- **Fields Related to the related unit:** Relation_Code, Relation_Type, Relation_hfid, Relation_Name, Relation_Gender, Relation_Living
  
2: A csv of your dwarves and their goals. This is just something I wanted handy but it not related to relationships. In some ways it is just a simplified copy of the first export.   
- **Fields:** Unit_id,HxId,Name,Caste,Race,Gender,Born,Died,Age,Goal
         
3: The relationships for lovers, spouses, and children as a graphviz digraph code. This outputs directly to the dfhack output window so that it can be copy/pasted directly  into a visualizer. This can be used with any graphviz generator such as https://dreampuf.github.io/GraphvizOnline/   
This visualization is limited to lovers (indicated by think magenta lines), spouses (indicated by thick teal lines), and parents/children (indicated by dashed lines). I think it may inadventently omit deceased children at this time, but I know how this can be fixed, so I may update that soon.       
If a unit is not present in your fortress (either dead or elsewhere) their information will show in a simple circle rather than a gender colored box. 

To use this code output:    
  1. Clear the dfhack output window.     
  2. Run the script (relationsexporter).   
  3. Copy the code from the output window using the dfhack 'copy output to clipboard function'.   
  4. Paste that code into the graphviz digraph generator of your choice. (i.e. https://dreampuf.github.io/GraphvizOnline/   )
  5. Edit the code to remove anything that is not part of the digraph. (this should be obvious as I added text lines to indicate the break.) 
  6. ***Behold the relations.*** I designed this to work with dot and neato arrangements. I like both for different reasons. 


