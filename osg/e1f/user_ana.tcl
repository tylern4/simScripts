source parms/recsis_proc.tcl;

# define packages
turnoff ALL;
global_section off;
turnon seb trk cc tof egn lac user pid;
#
inputfile uncooked.bos;
setc chist_filename cooked_chist.hbook;
setc log_file_name logfile;

#
#
setc outbanknames(1) "TRGSHEADHEVTEVNTECPBSCPBDCPBCCPBLCPBPARTMCEVTRGSTBIDMCTKMCVX";
#setc outbanknames(1) "HEADHEVTEVNTECPBSCPBDCPBCCPBLCPBPARTMCEVTRGSTBIDMCTKMCVX";
setc prlink_file_name "prlink_e1f.bos";
setc bfield_file_name "bgrid_T67to33.fpk";
outputfile cooked.bos PROC 2047;

#
set torus_current       2250;
set mini_torus_current  6000;
set TargetPos(3)       -25.0;
#
set ntswitch 1;

set dc_xvst_choice     0;


set dc_xvst_choice 0;
set ltrk_do    -1;
set legn_do    -1;
set lcc_do     -1;
set ltof_do    -1;
set lst_do      0;
set ltime_do   0;
set lec1_do    -1;
#1
set ltagger_do 0;
set lseb_do    -1;
#2,3
set lusr0_do   -1;
set lusr1_do   -1;
set lrf_do      0;
set lall_nt_do      -1;
#4,5,6,7
set lechb_nt_do 0;
set ltrk_nt_do 0;
set lec_nt_do 0 ;
set llac_nt_do 0;
set lccr_nt_do  0;
set lscr_nt_do  0;
set ltbtk_nt_do 0;
set lseb_nt_do      -1;
set lpart_nt_do     -1;
set nt_id_cut 0;
set def_geom -1;
set def_adc -1;
set def_tdc -1;
set def_atten  0;
set whole_surf 16.;
set inner_surf 1.;
set outer_surf 28.;
set m2_ecel_cut 1000.;
set m3_ecel_cut 10000.;
set trkec__match 50;

fpack "timestop -9999999999"
set lscat $false;
set ldisplay_all $false;

go 10000000;
#/status;
exit_pend;
