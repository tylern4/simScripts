#!/bin/bash

#INPUT Sequences file

# Name the job
#SBATCH -J e1d_sim_singularity

# Ask for 1 core (n) on 1 node (N)
#SBATCH -n 1
#SBATCH -N 1

# Make sure account is clas for clas6 sim
#SBATCH --account=clas12
## SBATCH --project=e1d

# Add time constraint to 2 days
#SBATCH --time=05:00:00

# Add 2GB memory constraint
## SBATCH --mem=2048M

# Place logfiles in a directory
# This directory should be in the same folder as the sim.sh script
#SBATCH --output=logfiles/e1d_sim_%A_%a.out
#SBATCH --error=logfiles/e1d_sim_%A_%a.err

# To run multiple jobs I use an array
## SBATCH --array=1-50%5
#SBATCH --array=0-1

echo "Hostname: $HOSTNAME"

# Make a few environment varialbes for directories
export JOB_DIR=${PWD}
export OUT_DIR=/volatile/clas/clase1/tylern/simulations
export SCRATCH=/scratch/slurm/${SLURM_JOBID}/${SLURM_ARRAY_TASK_ID}
export DATE=`date +%m-%d-%Y`

########=========== Load Singularity to Farm Node ===========########
source clas6_function_singularity.sh

########=========== Setup Scartch Folders ===========########
mkdir -p ${SCRATCH}
cd ${SCRATCH}

#######============ Copy in configuration files =====#######
#************************* Modify this to get your input files in ****************************
cp-to-job ${JOB_DIR}/aao_rad.inp
cp-to-job ${JOB_DIR}/gsim.inp
cp-to-job ${JOB_DIR}/user_ana.tcl
#************************* Modify this to get your input files in ****************************
#env
# starttime to time job
res1=$(date +%s.%N)

export CLAS_CALDB_RUNINDEX="RunIndex"
#export CLAS_CALDB_RUNINDEX="calib_user.RunIndexe1dvcs"
mkdir -p $HOME/.recsis
echo 1 > $HOME/.recsis/recseq.ini
export RECSIS_RUNTIME=$HOME/.recsis

########=========== Run Generator ===========########
#************************* Modify this for the generator you want ****************************
run-singularity-clas6 aao_rad < aao_rad.inp
#************************* Modify this for the generator you want ****************************

########=========== Run gsim ===========########
#gsim_bat -nomcdata -ffread gsim.inp -mcin aao_rad.evt -bosout gsim.bos

gsim_bat -nomcdata -ffread gsim.inp -mcin aao_rad.evt -bosout gsim.bos

########=========== Run gpp ===========########
#************************* Modify this for gpp configuration ****************************
gpp -ouncooked.bos -a1.357 -b1.357 -c1.357 -f1.05 -P0x1b -R23500 gsim.bos
#************************* Modify this for gpp configurtaion ****************************

########=========== Run user_ana ===========########
user_ana -t user_ana.tcl | grep -v HFNT

#************************* Modify this for your output file preferences ****************************
########=========== Run h10maker ===========########
run-singularity-clas6 h10maker -rpm cooked.bos all.root
########=========== Copy all the files to Work for output ===========########
mkdir -p ${OUT_DIR}/e1d/npip
cp -r ${SCRATCH}/all.root ${OUT_DIR}/e1d/npip/e1d_sim_jlab_${DATE}_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.root
#************************* Modify this for your output file preferences ****************************

rm -rf ${SCRATCH}/*
# endtime to time job
res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
echo "Hostname: $HOSTNAME"
printf "Total runtime: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
