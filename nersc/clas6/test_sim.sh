#!/bin/bash
export CLAS_PARMS=/data/parms
export ROOTSYS=/usr/local/root
export MYSQLINC=/usr/include/mysql
export MYSQLLIB=/usr/lib64/mysql
export CLAS6=/usr/local/clas-software/build
export PATH=$CLAS6/bin:$PATH
export CERN=/usr/local/cernlib/x86_64_rhel6
export CERN_LEVEL=2005
export CERN_ROOT=$CERN/$CERN_LEVEL
export CVSCOSRC=$CERN/$CERN_LEVEL/src
export PATH=$CERN/$CERN_LEVEL/src:$PATH
export CERN_LIB=$CERN_ROOT/lib
export CERNLIB=$CERN_ROOT/lib
export CERN_BIN=$CERN_ROOT/bin
export CLAS_TOOL=/usr/local/clas-software/analysis/ClasTool
export PATH=$PATH:$CLAS_TOOL/bin/Linux
export LD_LIBRARY_PATH=$ROOTSYS/lib:$CLAS_TOOL/slib/Linux:$CLAS6/lib

# source $ROOTSYS/bin/thisroot.sh

export CLAS_CALDB_DBNAME="calib"
export CLAS_CALDB_PASS=""
export CLAS_CALDB_RUNINDEX="RunIndex"
export RECSIS_RUNTIME="${PWD}/recsis"
mkdir -p ${RECSIS_RUNTIME}

export CLAS_PARMS=/global/homes/t/tylern/simScripts/wdl/clas6/parms


export CLAS_CALDB_HOST=clasdb.jlab.org
export CLAS_CALDB_USER=clasreader

echoerr() { printf "%s\n" "$*" >&1; printf "%s\n" "$*" >&2; }

clas6runner () { shifter --env CLAS_PARMS=/global/homes/t/tylern/simScripts/wdl/clas6/parms --image=tylern4/clas6:latest $@; }


echoerr "====== cpu info ======"
lscpu
echoerr "====== cpu info ======"

#set -e
STARTTIME=$(date +%s)

echoerr "============ start aao_rad ============"
clas6runner aao_rad < aao_rad.inp
echoerr "============ end aao_rad ============"

echoerr "============ start gsim_bat ============"
clas6runner gsim_bat -nomcdata -ffread gsim.inp -mcin aao_rad.evt -bosout gsim.bos
echoerr "============ end gsim_bat ============"

echoerr "============ start gpp ============"
#shifter --image=tylern4/clas6:latest gpp -ouncooked.bos -a2.35 -b2.35 -c2.35 -f0.97 -P0x1b -R23500 gsim.bos
echoerr "============ end gpp ============"

echoerr "============ start user_ana ============"
#shifter --image=tylern4/clas6:latest user_ana -t user_ana.tcl | grep -v HFITGA | grep -v HFITH | grep -v HFNT
echoerr "============ end user_ana ============"

#shifter --image=tylern4/clas6:latest h10maker -rpm cooked.bos all.root

ENDTIME=$(date +%s)

echo "Time for $HOSTNAME: $(($ENDTIME-$STARTTIME))"
