#!/bin/bash
#Commentary by Greg Szwabowski 12/4/2020
#This script will clean every .pdb file in a directory using Rosetta. Use the command 'chmod u+x cleanpdbs.bash' to
#obtain ownership of the file and then use './cleanpdbs.bash' to run the script.
file <- file.endswith ".pdb"
for file in *
    do /public/apps/rosetta/2017.29.59598/tools/protein_tools/scripts/clean_pdb.py $file 1
    
done