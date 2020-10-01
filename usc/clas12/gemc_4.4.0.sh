#!/bin/bash
export TOR=$1
export SOL=$2
export RUN_NUM=$3
export EXPERIMENT=$4
export DATA_DIR=$5
export NAME=$6

export INPUT=${DATA_DIR}/lund/${NAME}.lund 
export OUTPUT=${DATA_DIR}/gemc/gemc_${NAME}.evio


export JLAB_ROOT=/jlab
export JLAB_VERSION=2.4
export CLAS12TAG=4.4.0
export OSRELEASE=Linux_CentOS8.2.2004-gcc8.3.1
export JLAB_SOFTWARE=/jlab/$JLAB_VERSION/$OSRELEASE

# some OSG nodes have XERCESROOT, QTDIR defined. Since we use keepmine we
# need to re-define those here. Notice: this is dependent on the Dockerfile (CentOS version)
export XERCESC_VERSION=3.2.3
export XERCESCROOT=$JLAB_SOFTWARE/xercesc/$XERCESC_VERSION
export QT_VERSION=system
export QTSYSTEM=gcc_64
export QT_VERSION=system
export QTDIR=$JLAB_SOFTWARE/qt/$QT_VERSION/$QTSYSTEM
export QTLIB=$QTDIR/lib

# sidis, inclusive dis with rad correction, dvcs
export CLASDIS_PDF=/jlab/work/clas12-mcgen/clasdis/pdf
export CLASPYTHIA_DECLIST=/jlab/work/clas12-mcgen/claspyth/pdf
export CLASDVCS_PDF=/jlab/work/clas12-mcgen/dvcsgen
export DISRAD_PDF=/jlab/work/clas12-mcgen/inclusive-dis-rad
export DataKYandOnePion=/jlab/work/clas12-mcgen/genKYandOnePion/data

# CLAS12 envs
export CLAS12_LIB=$JLAB_SOFTWARE/clas12/lib
export CLAS12_INC=$JLAB_SOFTWARE/clas12/inc
export CLAS12_BIN=$JLAB_SOFTWARE/clas12/bin

# env does not contain gemc, adding it manually
source $JLAB_ROOT/$JLAB_VERSION/ce/jlab.sh keepmine
export GEMC=/jlab/clas12Tags/$CLAS12TAG/source
export GEMC_VERSION=$CLAS12TAG
export PATH=${PATH}:${CLAS12_BIN}:${GEMC}
export PYTHONPATH=${PYTHONPATH}:${GEMC}/api/python

export GEMC_DATA_DIR=/jlab/clas12Tags/$CLAS12TAG
export FIELD_DIR=/cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/noarch/data/magfield/ascii

export PATH=${PATH}:/cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/noarch/coatjava/6.5.9/bin
export JAVA_HOME=/cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/Linux_CentOS8.2.2004-gcc8.3.1/jdk/1.8.0_31

export PATH=/jlab/clas12Tags/${CLAS12TAG}/source/bin/Linux_CentOS8.2.2004-gcc8.3.1:${PATH}
export GEMC_DATA_DIR=/jlab/clas12Tags/${CLAS12TAG}
export CCDB_CONNECTION="sqlite:////cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/noarch/data/ccdb/ccdb_${CLAS12TAG}.sqlite"
export RCDB_CONNECTION="sqlite:////cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/noarch/data/rcdb/rcdb_${CLAS12TAG}.sqlite"

gemc /jlab/clas12Tags/${CLAS12TAG}/config/${EXPERIMENT}.gcard -USE_GUI=0 -OUTPUT="evio, ${OUTPUT}" -INPUT_GEN_FILE="LUND, ${INPUT}" -SCALE_FIELD="TorusSymmetric, ${TOR}" -SCALE_FIELD="clas12-newSolenoid, ${SOL}"


