#!/bin/bash

export CLAS_CALDB_DBNAME="calib_user"
export CLAS_CALDB_PASS=""
export CLAS_CALDB_RUNINDEX="calib_user.RunIndexe1fDC"
export RECSIS_RUNTIME=${HOME}/.recsis

echoerr() { printf "%s\n" "$*" >&1; printf "%s\n" "$*" >&2; }

#set -e
STARTTIME=$(date +%s)
echoerr "============ aao_rad ============"
aao_rad < aao_rad.inp
echoerr "============ aao_rad ============"

echoerr "============ gsim_bat ============"
#gsim_bat -nomcdata -ffread gsim.inp -mcin aao_rad.evt -bosout gsim.bos
gsim_bat -ffread gsim.inp -mcin aao_rad.evt -bosout gsim.bos
cp gsim.bos gsim_no_gpp.bos
echoerr "============ gsim_bat ============"

echoerr "============ gpp ============"
gpp -ouncooked.bos -a1.357 -b1.357 -c1.357 -f1.05 -P0x1b -R37513 gsim.bos
#gpp -ouncooked.bos -R23500 gsim.bos
echoerr "============ gpp ============"

echoerr "============ user_ana ============"
#user_ana -t user_ana.tcl
user_ana -t user_ana.tcl | grep -v HFITGA | grep -v HFITH | grep -v HFNT
echoerr "============ user_ana ============"

h10maker -rpm cooked.bos all.root


ENDTIME=$(date +%s)

echo "Time for $HOSTNAME: $(($ENDTIME-$STARTTIME))"
