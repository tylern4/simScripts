## To be sourced on the farm
source /etc/profile.d/modules.sh

# Clean out all old modules
module purge
# Load singularity
module load singularity

echoerr() { printf "%s\n" "$*" >&1; printf "%s\n" "$*" >&2; }

cp-to-job() {
    mkdir -p /scratch/slurm/${SLURM_JOBID}/${SLURM_ARRAY_TASK_ID}
    cp -r "$@" /scratch/slurm/${SLURM_JOBID}/${SLURM_ARRAY_TASK_ID}/
}

run-singularity-clas6() {
    singularity exec \
        -B /u/group:/group \
        -B /lustre:/lustre \
        -B /w/work:/work \
        -B /lustre/expphy/volatile:/volatile \
        -B /u/home:/home \
        -B $HOME/.recsis:/recsis \
        --pwd ${PWD} \
	/cvmfs/singularity.opensciencegrid.org/tylern4/clas6:latest "$@"
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
