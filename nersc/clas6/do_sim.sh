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

source $ROOTSYS/bin/thisroot.sh

export CLAS_CALDB_DBNAME="calib"
export CLAS_CALDB_PASS=""
export CLAS_CALDB_RUNINDEX="RunIndex"
export RECSIS_RUNTIME="/recsis"

#export CLAS_CALDB_HOST=172.21.139.25
export CLAS_CALDB_HOST=172.21.139.204
#export CLAS_CALDB_HOST=71.68.137.124
export CLAS_CALDB_USER=root
echoerr() { printf "%s\n" "$*" >&1; printf "%s\n" "$*" >&2; }

#set -e
STARTTIME=$(date +%s)
echoerr "============ aao_rad ============"
aao_rad < aao_rad.inp
echoerr "============ aao_rad ============"

echoerr "============ gsim_bat ============"
#gsim_bat -nomcdata -ffread gsim.inp -mcin aao_rad.evt -bosout gsim.bos
gsim_bat -ffread gsim.inp -mcin aao_rad.evt -bosout gsim.bos
#cp gsim.bos gsim_no_gpp.bos
echoerr "============ gsim_bat ============"

echoerr "============ gpp ============"
gpp -ouncooked.bos -a2.35 -b2.35 -c2.35 -f0.97 -P0x1b -R23500 gsim.bos
#gpp -ouncooked.bos -R23500 gsim.bos
echoerr "============ gpp ============"

echoerr "============ user_ana ============"
#user_ana -t user_ana.tcl
#user_ana -t user_ana.tcl | grep -v HFITGA | grep -v HFITH | grep -v HFNT
echoerr "============ user_ana ============"

touch all.root
#h10maker -rpm cooked.bos all.root


ENDTIME=$(date +%s)

echo "Time for $HOSTNAME: $(($ENDTIME-$STARTTIME))"
