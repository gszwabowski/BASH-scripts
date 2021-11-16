#!/bin/bash
#Commentary by Greg Szwabowski 12/4/2020
#This script is used to generate .sh job files for a docking run. For example, an original
# 'dock1.sh' run with the job name 'PAR1_1' and MOE batch file name 'PAR1_1_batch.svl' will
# be renamed to 'PAR1_2' and 'PAR1_2_batch.svl' using the command:
# './dock_batch_create/sh dock1.sh PAR1_1 PAR1'

dockfile=$1
search=$2
replacement=$3

for i in {2..10}
do sed "s/$search/${replacement}_${i}/g" $dockfile > dock$i.sh
done
