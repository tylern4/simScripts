#!/bin/sh

#INPUT Sequences file

#SBATCH -J clas12_sim_sing
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --output=logfiles/twoPion_%A_%a.out
#SBATCH --error=logfiles/twoPion_%A_%a.err
#SBATCH -p defq,BigMem,defq-48core
##SBATCH --array=1-100

#change tmp
export TMPDIR="/local/${USER}"
#export CLARA_HOME=/work/gothelab/clas12/software/clara
export CLARA_HOME=/work/gothelab/clas12/software/clara-6.5.3
export CLAS12DIR=$CLARA_HOME/plugins/clas12
export PATH=$PATH:$CLARA_HOME/bin:$CLAS12DIR/bin
export DATA_DIR=/work/gothelab/clas12/simulations/data_test
export HIPO_TOOLS=/work/gothelab/clas12/software
export PATH=$PATH:$HIPO_TOOLS/bin
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$HIPO_TOOLS/share/pkgconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HIPO_TOOLS/lib
export PYTHONPATH=$PYTHONPATH:$HIPO_TOOLS/lib
export CLAS12CONFIG=$PWD/4.4.0

#load singularity
module load singularity/2.6.0
module load java/1.8.0_162

##***********************************************##
# Setup event generator
export NUM_EVENTS=100
export BEAM_E=10.6041
export W_MIN=1.0
export W_MAX=3.5
export Q2_MIN=0.1
export Q2_MAX=10.0
# Change thse to change torus and solonid for run
export TOR=-1.0
export SOL=-1.0
## Availible Run Periods
#clas12-default
#rga_spring2018 
#rga_fall2018 
#rga_spring2019
#rgb_spring2019
#rgk_fall2018
export RUN_PERIOD=rga_fall2018
# Change type to append to simulation name
# Doesn't change configuration but nice to change
# Depending on the testing you want to compelte
export TYPE="twoPi_gemc4.4"
##***********************************************##

# Use this for simulations runs but idk why??
export RUN=11
# Make a unique name with type date etc.
export DATE=`date +%m-%d-%Y_%H.%M`
export NAME=${TYPE}_${NUM_EVENTS}_${BEAM_E}_${DATE}_${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}

res1=$(date +%s.%N)

# Generate events
singularity shell -B $DATA_DIR:$DATA_DIR  \
                  -B $PWD:/work/code \
                  /work/gothelab/clas12/software/twoPi_sim.img -c \
		  "source /usr/local/bin/thisroot.sh && 2pi_event_generator ${NUM_EVENTS} -E_beam ${BEAM_E} -W_min ${W_MIN} -W_max ${W_MAX} -Q2_min ${Q2_MIN} -Q2_max ${Q2_MAX} -output ${DATA_DIR}/lund/${NAME}.lund"

# Run Gemc
singularity shell -B $DATA_DIR:$DATA_DIR \
		  -B $PWD:/jlab/work/code \
		  --pwd /jlab/work/code \
		  -B /work/gothelab/clas12/cvmfs:/cvmfs \
		  /work/gothelab/clas12/software/gemc_4.4.0.img -c \
	    	  "bash /jlab/work/code/gemc_4.4.0.sh ${TOR} ${SOL} ${RUN} ${RUN_PERIOD} ${DATA_DIR} ${NAME}"

#export CLAS12TAG=4.4.0
#export CCDB_CONNECTION="sqlite://///work/gothelab/clas12/cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/noarch/data/ccdb/ccdb_${CLAS12TAG}.sqlite"
#export RCDB_CONNECTION="sqlite://///work/gothelab/clas12/cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/noarch/data/rcdb/rcdb_${CLAS12TAG}.sqlite"

# Convert evio 2 hipo		  
evio2hipo -r $RUN -t $TOR -s $SOL -o ${DATA_DIR}/gemc/gemc_${NAME}.hipo ${DATA_DIR}/gemc/gemc_${NAME}.evio

# Cook hipo file
recon-util -y ${CLAS12CONFIG}/${RUN_PERIOD}.yaml -i ${DATA_DIR}/gemc/gemc_${NAME}.hipo -o ${DATA_DIR}/hipo/sim_${NAME}.hipo 

# Convert to root
dst2root -mc ${DATA_DIR}/hipo/sim_${NAME}.hipo ${DATA_DIR}/root/sim_6.5.3_${NAME}.root

rm -rf ${DATA_DIR}/gemc/gemc_${NAME}.hipo
rm -rf ${DATA_DIR}/lund/${NAME}.lund
rm -rf ${DATA_DIR}/gemc/gemc_${NAME}.evio


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
