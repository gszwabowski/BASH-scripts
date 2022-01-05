#!/bin/bash
#Commentary by Greg Szwabowski 1/5/2022
#This script will create a job file for conformational on the HPC based on .mdb files located in a directory. Use the command 'chmod u+x confsearch_job_create.sh' to
#obtain ownership of the file and then use './confsearch_job_create.sh' to run the script. This script is best used after creating subsets of a database with the
#db_subset_generation.svl script located in the SVL-scripts/misc_tools/ directory
jobname=$1
i=1
path='/public/apps/moe/moe2020/bin/moebatch -exec'

for file in *.mdb

do 
	{	
		echo '#!/bin/csh'
		echo '#SBATCH --ntasks=4'
		echo '#SBATCH --partition=computeq'
		echo '#SBATCH --job-name=conf_search_'$i
		echo '#SBATCH --time=14400'
		echo $path "\"ConfSearch [infile: '${file}', outfile: 'diverset_compounds_prepped_${i}_confs.mdb', method: 'Stochastic', dbview: 0, maxconf: 10, invert_sp3: 1]\""
	} > conf_search_$i.sh

	let i=i+1

done
	
