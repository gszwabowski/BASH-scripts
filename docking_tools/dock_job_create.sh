#!/bin/bash
#Commentary by Greg Szwabowski 12/4/2020
#This script will create a job file for docking on the HPC based on .svl docking scripts located in a directory. Use the command 'chmod u+x dock_job_create.sh' to
#obtain ownership of the file and then use './dock_job_create.sh jobname' to run the script, where jobname is what you want to name the job.

jobname=$1
i=1
path='/public/apps/moe/moe_2019.0102/bin/moebatch -run'
for file in *.svl

do 
	{	
		echo '#!/bin/csh'
		echo '#SBATCH --ntasks=4'
		echo '#SBATCH --partition=computeq'
		echo '#SBATCH --job-name='$jobname
		echo $path $file
	} > dock$i.sh

	let i=i+1

done
	
