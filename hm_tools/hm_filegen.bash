#!/bin/bash
#Commentary by Greg Szwabowski 9/16/2022
#This script is used to create files used for loop modeling in Rosetta. Use the command 'chmod u+x hm_filegen.bash' to
#obtain ownership of the file and then use './hm_filegen.bash' to run the script. When this script runs, 5 directories
#will be created (A, B, C, D, E) that each contain job files to generate 50 loop models suffixed A, B, C, D, E (250 total).

#As this script runs, it will ask for residue numbers and filenames. Residue numbers represent the loop start/end and
#3.25/45.50 cysteine residues as they are numbered in your .pdb file and should be entered as integers. Filenames should
#be suffixed with their filetype (e.g. frags.txt).

#The following files should be in the directory this script is run in:
#   * .pdb file containing receptor structure with template ligand in binding pocket
#   * XXX_9_frag.txt and XXX_3_frag.txt fragment files saved from Robetta
#   * .sdf file of the template ligand


#loop parameters
read -p "$(tput setaf 5)Enter receptor name: $(tput sgr 0)" NAME
read -p "$(tput setaf 5)Enter loop start residue number: $(tput sgr 0)" START
read -p "$(tput setaf 5)Enter loop end residue number: $(tput sgr 0)" END	
echo

# hm.loops File Template
echo -e "$(tput setaf 3)Generating loops file...$(tput sgr 0)"
cat << EOF > hm.loops
# rosetta loops file
# columns:

# "LOOP" 
# start_residue  
# end_residue 
# cutpoint (0: let LoopRebuild choose cutpoint randomly.) 
# Skip rate (default - never skip)
# Extend loop. Default false

LOOP   $START  $END    0  0.0  1
EOF

echo -e "$(tput setaf 2)Loops file generated.\n$(tput sgr 0)"

#disulf prompt
read -p "$(tput setaf 5)Does the receptor have a 3.25-45.50 disulfide bond (y/n)?: $(tput sgr 0)" ANSWER

# disulf.cst File Template
if [ "$ANSWER" != "${ANSWER#[Yy]}" ] ;then
read -p "$(tput setaf 5)Enter Cys 3.25 residue number: $(tput sgr 0)" CYS1
read -p "$(tput setaf 5)Enter Cys 45.50 residue number: $(tput sgr 0)" CYS2	
echo -e "$(tput setaf 3)Generating disulf.cst...$(tput sgr 0)"
cat <<EOF > disulf.cst
AtomPair SG $CYS1 SG $CYS2 HARMONIC 0 5.1
EOF

echo -e "$(tput setaf 2)disulf.cst generated.\n$(tput sgr 0)"
fi

#kic parameters
read -p "$(tput setaf 5)Enter .pdb filename: $(tput sgr 0)" PDB
read -p "$(tput setaf 5)Enter 9 frag filename: $(tput sgr 0)" FRAG9
read -p "$(tput setaf 5)Enter 3 frag filename: $(tput sgr 0)" FRAG3
read -p "$(tput setaf 5)Enter ligand filename: $(tput sgr 0)" LIGFILE
read -p "$(tput setaf 5)Enter ligand abbreviation (3 letters): $(tput sgr 0)" LIG

#.params generation
read -p "$(tput setaf 5)Do you have a set of ligand conformers to use during parameter file generation (y/n)?: $(tput sgr 0)" ANSWER
if [ "$ANSWER" != "${ANSWER#[Yy]}" ] ;then
	read -p "$(tput setaf 5)Enter conformers .sdf filename: $(tput sgr 0)" CONFORMERS
	/public/apps/rosetta/2017.29.59598/main/source/scripts/python/public/molfile_to_params.py -n $LIG -p $LIG --conformers-in-one-file $CONFORMERS
else
	/public/apps/rosetta/2017.29.59598/main/source/scripts/python/public/molfile_to_params.py -n $LIG -p $LIG $LIGFILE
echo -e "\n\n\n$(tput setaf 2)Ligand parameters generated.\n$(tput sgr 0)"
fi

# kic_with_frags.flags Template
echo -e "$(tput setaf 3)Generating kic_with_frags.flags...$(tput sgr 0)"
cat <<EOF > kic_with_frags.flags
#io flags:
-in:file:fullatom
-in:file:s $PDB
-in:file:extra_res_fa $LIG.params
-cst_fa_file disulf.cst
-cst_fa_weight 1000
-loops:loop_file hm.loops
-loops:frag_sizes 9 3 1
-loops:frag_files $FRAG9 $FRAG3 none 

-loops:remodel perturb_kic_with_fragments
-loops:refine refine_kic_with_fragments

-out:nstruct 50
-out:pdb
-out:suffix _

#-run:test_cycles
#-loops:fast

#packing flags
-ex1
-ex2 

-mute core.io.database
-mute protocols.looprelax.FragmentPerturber
-mute core.fragments.ConstantLengthFragSet

#RosettaEnergyFunction2015
-beta_nov16 true
EOF
echo -e "$(tput setaf 2)kic_with_frags.flags generated.\n$(tput sgr 0)"

#KICfragsub.sh Template
echo -e "$(tput setaf 3)Generating KICfragsub.sh...$(tput sgr 0)"
cat <<EOF > KICfragsub.sh
#! /bin/csh
#SBATCH --ntasks=4
#SBATCH --partition=computeq
#SBATCH --job-name=loopmodel
#SBATCH --time=14400

module load gcc/8.2.0

/public/apps/rosetta/2017.29.59598/main/source/bin/loopmodel.static.linuxgccrelease @kic_with_frags.flags >loops.log
EOF

#update KICfragsub.sh job name
sed -i "s/#SBATCH --job-name=loopmodel/#SBATCH --job-name=${NAME}_loopmodel/g" KICfragsub.sh

echo -e "$(tput setaf 2)KICfragsub.sh generated.\n$(tput sgr 0)"

mkdir A 
mkdir B
mkdir C
mkdir D
mkdir E

cp * A > /dev/null 2>&1
cp * B > /dev/null 2>&1
cp * C > /dev/null 2>&1
cp * D > /dev/null 2>&1
cp * E > /dev/null 2>&1

sed -i "s/-out:suffix _/-out:suffix _A/g" A/kic_with_frags.flags
sed -i "s/-out:suffix _/-out:suffix _B/g" B/kic_with_frags.flags
sed -i "s/-out:suffix _/-out:suffix _C/g" C/kic_with_frags.flags
sed -i "s/-out:suffix _/-out:suffix _D/g" D/kic_with_frags.flags
sed -i "s/-out:suffix _/-out:suffix _E/g" E/kic_with_frags.flags

#jobname suffixes
for D in *; do
	if [ -d "${D}" ]; then
		cd $D
		newname=_loopmodel_$D
		sed -i "s/_loopmodel/$newname/g" KICfragsub.sh
		cd ..
	fi
done 

echo -e "$(tput setaf 2)All job files created.$(tput sgr 0)"
