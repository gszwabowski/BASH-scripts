#!/bin/bash

ligand=$1

for file in *.pdb

	do cat $file $ligand > ${file%.*}_${ligand%.pdb}.pdb
    
done
