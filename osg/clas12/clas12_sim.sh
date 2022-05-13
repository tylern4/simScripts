#!/bin/bash


source /etc/profile.d/environment.sh
export RCDB_CONNECTION=sqlite:////cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/noarch/data/rcdb/rcdb_4.4.1.sqlite

module unload coatjava
module purge
module load coatjava/6.5.6.1

echo $0 $1

lscpu
# saving date for bookmarking purposes:
STARTTIME=$(date +%s)
cp threePi_*.dat threePi.dat

ls -latr
#generate-seeds.py generate
#export seed=$(generate-seeds.py read --row 1)
#twopeg < clas12.inp

cp /jlab/clas12Tags/$CLAS12TAG/config/rga_fall2018.gcard rga_fall2018.gcard
gemc -USE_GUI=0 -OUTPUT='evio, gemc.evio' -INPUT_GEN_FILE='lund, threePi.dat'  rga_fall2018.gcard -SCALE_FIELD='TorusSymmetric, -1.00' -SCALE_FIELD='clas12-newSolenoid, -1.00'

evio2hipo -r 11 -t -1.00 -s -1.00 -i gemc.evio -o gemc.hipo

cp /jlab/clas12Tags/$CLAS12TAG/config/rga_fall2018.yaml rga_fall2018.yaml
recon-util -y rga_fall2018.yaml -i gemc.hipo -o recon.hipo


rm threePi.dat
rm gemc.evio
rm gemc.hipo

hipo-utils -filter -b 'RUN::*,RAW::epics,RAW::scaler,HEL::flip,HEL::online,REC::*,RECFT::*,MC::*' -merge -o dst.hipo recon.hipo

ENDTIME=$(date +%s)
echo "Hostname: $HOSTNAME"
echo "Total runtime: $(($ENDTIME-$STARTTIME))"

