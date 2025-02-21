# Dfhack scripts:
# Notes on: relationsexporter.lua
The code in this script was heavily borrowed from Ramblur's now defunct family.lua script.  
(https://github.com/Ramblurr/dfhack/blob/f585ecf4831fc19badc97b37e27cd4ccc7874c44/scripts/family.lua (2/18/2025))  
The original script did single dwarf selection, exporting information for the selected dwarf's family only.   
This script runs a loop through all active dwarves to get immediate relations that are defined as hfigs.   

It generates three primary exports:  
 		1: A csv of the relationships. This includes diety and deceased pet relations.   
 		2: A csv of your dwarves and their goals. This is just something I wanted handy but it not related to relationships.  
 		3: The relationships for lovers, spouses, and children as a graphviz digraph code. This outputs directly to the df hack output window so that it can be   
    copy/pasted directly  into a visualizer. This can be used with any graphviz generator such as https://dreampuf.github.io/GraphvizOnline/  
