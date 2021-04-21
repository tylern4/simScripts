#!/bin/bash


source /etc/profile.d/environment.sh
export RCDB_CONNECTION=sqlite:////cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/noarch/data/rcdb/rcdb_4.4.1.sqlite

source /cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/setup.sh
module load root/6.22.06
module load mcgen/1.6

module unload coatjava
module load coatjava/6.5.6.1

echo $0 $1

lscpu
# saving date for bookmarking purposes:
STARTTIME=$(date +%s)
#generate-seeds.py generate
#export seed=$(generate-seeds.py read --row 1)
#twopeg < clas12.inp
export NUM_EVENTS=100
cp /jlab/clas12Tags/$CLAS12TAG/config/rga_fall2018.gcard rga_fall2018.gcard
twopeg --docker --trig $NUM_EVENTS --ebeam 10.6041 --wmin 1.0 --wmax 8.5 --q2min 0.1 --q2max 12.0 --trad 1.183 --tlen 5.0 --toff 0.0 --twlen 30.0 --flagrad 2
gemc -USE_GUI=0 -OUTPUT='evio, gemc.evio' -INPUT_GEN_FILE='lund, twopeg.dat'  rga_fall2018.gcard -SCALE_FIELD='TorusSymmetric, -1.00' -SCALE_FIELD='clas12-newSolenoid, -1.00'

evio2hipo -r 11 -t -1.00 -s -1.00 -i gemc.evio -o gemc.hipo

# Run background merging
bgMerginFilename.sh rga_fall2018 tor-1.00_sol-1.00 45nA_10604MeV get
export bgFile=$(ls 0*.hipo) # or you can do bgFile=`ls 0*.hipo`
bg-merger -b $bgFile -i gemc.hipo -o gemc.merged.hipo -d 'DC,FTOF,ECAL,HTCC,LTCC,BST,BMT,CND,CTOF,FTCAL,FTHODO'
# Run Reconstruction
cp /jlab/clas12Tags/$CLAS12TAG/config/rga_fall2018.yaml rga_fall2018.yaml
recon-util -y rga_fall2018.yaml -i gemc.merged.hipo -o recon.hipo


rm twopeg.dat
rm gemc.evio
rm gemc.hipo
rm gemc.merged.hipo
rm 0*.hipo

hipo-utils -filter -b 'RUN::*,RAW::epics,RAW::scaler,HEL::flip,HEL::online,REC::*,RECFT::*,MC::*' -merge -o dst.hipo recon.hipo

ENDTIME=$(date +%s)
echo "Hostname: $HOSTNAME"
echo "Total runtime: $(($ENDTIME-$STARTTIME))"
