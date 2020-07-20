#!/bin/bash

echoerr() { printf "%s\n" "$*" >&1; printf "%s\n" "$*" >&2; }


run-singularity-clas6() {
	mkdir -p $PWD/recsis &&
    singularity exec \
        -B $PWD/recsis:/recsis \
        --pwd $PWD \
        clas6.img "$@"
}


gsim_bat() {
    echoerr "============ gsim_bat ============"
    run-singularity-clas6 gsim_bat "$@"
    echoerr "============ gsim_bat ============"
}

gpp() {
    echoerr "============ gpp ============"
    run-singularity-clas6 gpp "$@"
    echoerr "============ gpp ============"
}


user_ana() {
    echoerr "============ user_ana ============"
    run-singularity-clas6 user_ana "$@"
    echoerr "============ user_ana ============"
}



# Make a few environment varialbes for directories
export JOB_DIR=${PWD}
export WORK_DIR=/public/tylern/clas6/sim
export SCRATCH=/srv
export DATE=`date +%m-%d-%Y`


# starttime to time job
res1=$(date +%s.%N)

export CLAS_CALDB_DBNAME="calib_user"
export CLAS_CALDB_RUNINDEX="RunIndex"
#export CLAS_CALDB_RUNINDEX="RunIndexe1fDC"


########=========== Run Generator ===========########
#************************* Modify this for the generator you want ****************************
run-singularity-clas6 aao_rad < aao_rad.inp
#************************* Modify this for the generator you want ****************************

########=========== Run gsim ===========########
gsim_bat -nomcdata -ffread gsim.inp -mcin aao_rad.evt -bosout gsim.bos

########=========== Run gpp ===========########
#************************* Modify this for gpp configuration ****************************
gpp -ouncooked.bos -a1.357 -b1.357 -c1.357 -f1.05 -P0x1b -R23500 gsim.bos
#************************* Modify this for gpp configurtaion ****************************

########=========== Run user_ana ===========########
user_ana -t user_ana.tcl

#************************* Modify this for your output file preferences ****************************
########=========== Run h10maker ===========########
run-singularity-clas6 h10maker -rpm cooked.bos all.root
########=========== Copy all the files to Work for output ===========########
cp -r ${SCRATCH}/all.root ${WORK_DIR}/e1d/npip/e1d_sim_${DATE}_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.root
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
