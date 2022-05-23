#!/bin/bash

#####################################################################
# This is a script to streamline WRF-Chem run.
# To use this script, enter ./1click.sh in terminal
# Before running the script, set the date, day to run, and domains
# to run in Settings
#
# Version 1.0.0 - March 7, 2022 :
#     - Streamline run with pre-downloaded fnl data, not yet added
#       functions to download fnl data
#     - No Biogenic emissions yet
#
# Created By Hanif Ismail
# For internal use only
#####################################################################

### Some Settings

year=2022
month=04
day=15
days_to_run=3
domains=1

download_data="no" #set to yes to download data, anything else to NOT download data
process_WPS="no"
process_prep="no"
process_WRF="yes"
process_postprocess="yes"

###Set-up directory

export logname=$(date +%Y-%m-%d)
echo "LOG DATA" >> $logname.log
echo "Started $(date)" >> $logname.log
start_run=$(date +%s)
ln -sf $WPS_run_dir/*.exe .
ln -sf $WPS_run_dir/ungrib/Variable_Tables/Vtable.GFS Vtable
ln -sf $WPS_run_dir/link_grib* .
ln -sf $WPS_run_dir/metgrid/METGRID.TBL .
ln -sf $WPS_run_dir/geogrid/GEOGRID.TBL .

ln -sf $prep_chem_dir/prep_chem_sources_RADM_WRF_FIM_.exe prep_chem_sources.exe
ln -sf $WRF_PROJ_HOME/Global_emissions_v3 datain

ln -sf $WRF_run_dir/* .
ln -sf $WRF_chem_dir/*.exe .

### Build Namelists
rm namelist.input
rm namelist.wps
rm prep_chem_sources.inp
cat <<EOF >>prep_chem_sources.inp
\$RP_INPUT
!#################################################################
!  CCATT-BRAMS/MCGA-CPTEC/WRF-Chem/FIM-Chem emission models CPTEC/INPE
!  version 1.5: Mar 2015
!  contact: gmai@cptec.inpe.br   - http://meioambiente.cptec.inpe.br
!#################################################################

 
!---------------- grid_type of the grid output
   grid_type= 'mercator',      
   rams_anal_prefix = '../ANL/OPQUE',
!---------------- date of emission  
    ihour=00,
    iday=$day,
    imon=$month,
    iyear=$year,

 !---------------- select the sources datasets to be used
   use_retro=1,  ! 1 = yes, 0 = not
   retro_data_dir='./datain/Emission_data/RETRO/anthro',

   use_edgar =3,  ! 0 - not, 
                  ! 1 - Version 3, 
		  ! 2 - Version 4 for some species
		  ! 3 - Version HTAP

   edgar_data_dir='./datain/Emission_data/EDGAR-HTAP',

   use_gocart=1,
   gocart_data_dir='./datain/Emission_data/GOCART/emissions',

   use_streets =0,
   streets_data_dir='./datain/Emission_data/STREETS',

   use_seac4rs =0,
   seac4rs_data_dir='./datain/Emission_data/SEAC4RS',
   
   use_fwbawb =0,
   fwbawb_data_dir ='./datain/Emission_data/Emissions_Yevich_Logan',

   use_bioge =1, ! 1 - geia, 2 - megan 
   ! ###### 
   ! # BIOGENIC = 1
   bioge_data_dir ='./datain/Emission_data/biogenic_emissions',
   ! # MEGAN = 2
   ! ######   
   !bioge_data_dir='./datain/Emission_data/MEGAN/2000',   
   ! ######

   use_gfedv2=0,
   gfedv2_data_dir='./datain/Emission_data/GFEDv2-8days',
   
   use_bbem=1,
   use_bbem_plumerise=0,
 
!--------------------------------------------------------------------------------------------------

!---------------- if  the merging of gfedv2 with bbem is desired (=1, yes, 0 = no)
   merge_GFEDv2_bbem =0,

!---------------- Fire product for BBBEM/BBBEM-plumerise emission models
   bbem_wfabba_data_dir   ='./datain/Emission_data/fires_data/GOES/f',
   bbem_modis_data_dir    ='./datain/Emission_data/fires_data/MODIS/Fires',
   bbem_inpe_data_dir     ='./datain/Emission_data/fires_data/DSA/Focos',
   bbem_extra_data_dir    ='NONE',

!---------------- veg type data set (dir + prefix)
   veg_type_data_dir      ='./datain/surface_data/GL_IGBP_MODIS_INPE/MODIS',


!---------------- vcf type data set (dir + prefix)
  use_vcf = 0,
  vcf_type_data_dir      ='./datain/surface_data/VCF/data_out/2005/VCF',
!---------------- olson data set (dir + prefix)  
  olson_data_dir      ='./datain/Emission_data/OLSON2/OLSON',       
 
       

!---------------- carbon density data set (dir + prefix)
   
   carbon_density_data_dir='./datain/surface_data/GL_OGE_INPE/OGE',
   
   fuel_data_dir      ='./datain/Emission_data/Carbon_density_Saatchi/amazon_biomass_final.gra',
 

!---------------- gocart background
   use_gocart_bg=1,
   gocart_bg_data_dir='./datain/Emission_data/GOCART',

!---------------- volcanoes emissions
   use_volcanoes =0,
   volcano_index =1143, !REDOUBT

   use_these_values='NONE',
! define a text file for using external values for INJ_HEIGHT, DURATION,
! MASS ASH (units are meters - seconds - kilograms) and the format for 
   begin_eruption='201303280000',  !begin time UTC of eruption YYYYMMDDhhmm   

!---------------- degassing volcanoes emissions
   use_degass_volcanoes =0,
   degass_volc_data_dir ='./datain/Emission_data/VOLC_SO2', 

!---------------- user specific  emissions directory
!---------------- Update for South America megacities
   user_data_dir='NONE',


!--------------------------------------------------------------------------------------------------
   pond=1,   ! mad/mfa  0 -> molar mass weighted 
             !          1 -> Reactivity weighted   

!---------------- for grid type 'll' or 'gg' only
   grid_resolucao_lon=1.0,
   grid_resolucao_lat=1.0,

   nlat=320,          ! if gg (only global grid)
   lon_beg   = -180., ! (-180.:+180.) long-begin of the output file
   lat_beg   =  -90., ! ( -90.:+90. ) lat -begin of the output file
   delta_lon =  360, ! total long extension of the domain (360 for global)
   delta_lat =  180, ! total lat  extension of the domain (180 for global)

!---------------- For regional grids (polar or lambert)

   NGRIDS   = 1,            ! Number of grids to run

   NNXP     = 72,50,86,46,        ! Number of x gridpoints
   NNYP     = 72,50,74,46,        ! Number of y gridpoints
   NXTNEST  = 0,1,1,1,          ! Grid number which is the next coarser grid
   DELTAX   = 27000.,
   DELTAY   = 27000.,         ! X and Y grid spacing

   ! Nest ratios between this grid and the next coarser grid.
   NSTRATX  = 1,2,3,4,           ! x-direction
   NSTRATY  = 1,2,3,4,           ! y-direction

   NINEST = 1,10,0,0,        ! Grid point on the next coarser
   NJNEST = 1,10,0,0,        !  nest where the lower southwest
                             !  corner of this nest will start.
                             !  If NINEST or NJNEST = 0, use CENTLAT/LON
   POLELAT  =  -1.013, !-89.99,          ! If polar, latitude/longitude of pole point
   POLELON  =   102.905,         ! If lambert, lat/lon of grid origin (x=y=0.)

   STDLAT1  = -1.013,           ! If polar for BRAMS, use 90.0 in STDLAT2
   STDLAT2  = 0.,         ! If lambert, standard latitudes of projection
			    !(truelat2/truelat1 from namelist.wps, STDLAT1 < STDLAT2)
                            ! If mercator STDLAT1 = 1st true latitude 
   CENTLAT  = -1.013,!-89.99,  -23., 27.5,  27.5,
   CENTLON  = 102.905,  -46.,-80.5, -80.5,



!---------------- model output domain for each grid (only set up for rams)
   lati =  -90.,  -90.,   -90., 
   latf =  +90.,  +90.,   +90.,  
   loni = -180., -180.,  -180., 
   lonf =  180.,  180.,   180., 

!---------------- project rams grid (polar sterogr) to lat/lon: 'YES' or 'NOT'
   proj_to_ll='YES', 
   
!---------------- output file prefix (may include directory other than the current)
   chem_out_prefix = 'emissions', 
   chem_out_format = 'vfm',
!---------------- convert to WRF/CHEM (yes,not)
  special_output_to_wrf = 'YES',
   
\$END 

EOF

# Here we need to do some calculation for our dates
start_date=$(date +%Y-%m-%d -d "$year$month$day")
start_date_wps="${start_date}_00:00:00"
end_date=$(date +%Y-%m-%d -d "$year$month$day +$days_to_run days")
end_date_wps="${end_date}_00:00:00"

cat <<EOF >>namelist.wps
&share
 wrf_core = 'ARW',
 max_dom = $domains,
 start_date = '$start_date_wps', '$start_date_wps', '$start_date_wps', 
 end_date   = '$end_date_wps', '$end_date_wps', '$end_date_wps', 
 interval_seconds = 10800,
 io_form_geogrid = 2,
 opt_output_from_geogrid_path = './',
 debug_level = 0,
/

&geogrid
 parent_id         = 1,      1,     1,
 parent_grid_ratio = 1,      3,     3,
 i_parent_start    = 1,      23,    46,
 j_parent_start    = 1,      28,    6,
 e_we              = 72,     49,    49,
 e_sn              = 72,     49,    49,
 geog_data_res     = '30s', '30s', '30s',
 dx = 27000,
 dy = 27000,
 map_proj =  'mercator',
 ref_lat   = -1.013,
 ref_lon   = 102.905,
 truelat1  = -1.013,
 truelat2  = 0,
 stand_lon = 102.905,
 geog_data_path = '$WRF_PROJ_HOME/WPS_GEOG',
 opt_geogrid_tbl_path = './',
 ref_x = 36.0,
 ref_y = 36.0,
/

&ungrib
 out_format = 'WPS',
 prefix = 'FILE',
/

&metgrid
 fg_name = 'FILE',
 io_form_metgrid = 2,
 opt_output_from_metgrid_path = './',
 opt_metgrid_tbl_path = './',
/

&mod_levs
 press_pa = 201300 , 200100 , 100000 ,
             95000 ,  90000 ,
             85000 ,  80000 ,
             75000 ,  70000 ,
             65000 ,  60000 ,
             55000 ,  50000 ,
             45000 ,  40000 ,
             35000 ,  30000 ,
             25000 ,  20000 ,
             15000 ,  10000 ,
              5000 ,   1000
 /
EOF

# Some more calculations
end_year=$(date +%Y -d $end_date)
end_month=$(date +%m -d $end_date)
end_day=$(date +%d -d $end_date)

### The first namelist.input is for real.exe, hence no chemical option

cat <<EOF >>namelist.input
 &time_control
 run_days                            = $days_to_run,
 run_hours                           = 0,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = $year, $year, $year,
 start_month                         = $month,   $month,   $month,
 start_day                           = $day,   $day,   $day,
 start_hour                          = 00,   00,   00,
 end_year                            = $end_year, $end_year, $end_year,
 end_month                           = $end_month,   $end_month,   $end_month,
 end_day                             = $end_day,   $end_day,   $end_day,
 end_hour                            = 00,   00,   00,
 interval_seconds                    = 10800
 input_from_file                     = .true.,.true.,.true.,
 history_interval                    = 60,   60,   60,
 frames_per_outfile                  = 9999, 9999, 9999,
 restart                             = .false.,
 restart_interval                    = 7200,
 io_form_history                     = 2,
 io_form_restart                     = 2,
 io_form_input                       = 2,
 io_form_boundary                    = 2,
 io_form_auxinput4                   = 0,
 force_use_old_data		             = T,
 debug_level			                = 1000,
 /

 &domains
 time_step                           = 120,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = $domains,
 e_we                                = 72,    49,   49,
 e_sn                                = 72,    49,   49,
 e_vert                              = 40,    40,   40,
 dx                                  = 27000,9000,9000
 dy                                  = 27000,9000,9000
 p_top_requested                     = 3000,
 num_metgrid_levels                  = 34,
 num_metgrid_soil_levels             = 4,
 grid_id                             = 1,     2,     3,
 parent_id                           = 1,     1,     1,
 i_parent_start                      = 1,     23,       46,
 j_parent_start                      = 1,     28,        6,
 parent_grid_ratio                   = 1,     3,        3,
 parent_time_step_ratio              = 1,        3,        3,
 feedback                            = 0,
 smooth_option                       = 0,
 /

 &physics
 mp_physics                          = 2,     2,     2,
 progn                               = 0,     0,     0,
 naer                                = 1e9
 ra_lw_physics                       = 1,     1,     1,
 ra_sw_physics                       = 2,     2,     2,
 radt                                = 30,    30,    30,
 sf_sfclay_physics                   = 1,     1,     1,
 sf_surface_physics                  = 2,     2,     2,
 bl_pbl_physics                      = 0,     0,     0,
 bldt                                = 0,     0,     0,
 cu_physics                          = 5,     5,     5,
 cudt                                = 1,     1,     1,
 isfflx                              = 1,
 ifsnow                              = 1,
 icloud                              = 1,
 surface_input_source                = 3,
 num_land_cat                        = 21,
 sf_urban_physics                    = 0,     0,     0,
 maxiens                             = 1,
 maxens                              = 3,
 maxens2                             = 3,
 maxens3                             = 16,
 ensdim                              = 144,
 cu_rad_feedback                     = .true.,
 cu_diag			      = 1,
 /

 &fdda
 /

 &dynamics
 hybrid_opt                          = 2, 
 w_damping                           = 1,
 diff_opt                            = 1,      1,      1,
 km_opt                              = 4,      4,      4,
 diff_6th_opt                        = 0,      0,      0,
 diff_6th_factor                     = 0.12,   0.12,   0.12,
 base_temp                           = 290.
 damp_opt                            = 3,
 zdamp                               = 5000.,  5000.,  5000.,
 dampcoef                            = 0.2,    0.2,    0.2
 khdif                               = 0,      0,      0,
 kvdif                               = 0,      0,      0,
 non_hydrostatic                     = .true., .true., .true.,
 moist_adv_opt                       = 1,      1,      1,     
 scalar_adv_opt                      = 1,      1,      1,     
 chem_adv_opt                        = 1,      1,      1,     
 /

 &bdy_control
 spec_bdy_width                      = 5,
 specified                           = .true.,
 /

 &grib2
 /

 &chem
 kemit                               = 1,
 chem_opt                            = 0,      0,    0,
 io_style_emissions                  = 2,
 chemdt			                      = 2,
 emiss_inpt_opt                      = 1,      1,    1,
 emiss_opt                           = 5,      5,    5,
 chem_in_opt                         = 0,      0,    0,
 phot_opt                            = 1,      1,    1,
 gas_drydep_opt                      = 0,      0,    0,
 aer_drydep_opt                      = 0,      0,    0,
 bio_emiss_opt                       = 1,      1,    0,
 dust_opt                            = 0,
 dmsemis_opt                         = 0,
 seas_opt                            = 0,
 gas_bc_opt                          = 1,      1,    1,
 gas_ic_opt                          = 1,      1,    1,
 aer_bc_opt                          = 1,      1,    1,
 aer_ic_opt                          = 1,      1,    1,
 gaschem_onoff                       = 1,      1,    1,
 aerchem_onoff                       = 1,      1,    1,
 wetscav_onoff                       = 0,      0,    0,
 cldchem_onoff                       = 0,      0,    0,
 vertmix_onoff                       = 1,      1,    1,
 chem_conv_tr                        = 1,      1,    1,
 biomass_burn_opt                    = 0,      0,    0,
 plumerisefire_frq                   = 30,    30,   30,
 aer_ra_feedback                     = 0,      0,    0,
 have_bcs_chem                       = .true., .false., .false.,
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
EOF

### We'll be downloading GFS Data without script bcs we don't need the script anymore, 
### If you want to use the script, please refer to the previous run documentation
### While downloading using wget took ~30 min to finish aria2 can do the same in sub 5 min
# For now I'll just put this here, link for real-time data
# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$year$month${day}/00/atmos/gfs.t00z.pgrb2.0p25.f000

if [ $download_data == "yes" ]
then
echo "Started GFS data download $(date)" >> $logname.log
start_dl=$(date +%s)

# Don't change this
opt1="--no-check-certificate -c -O Authentication.log --save-cookies auth.rda_ucar_edu"
opt2="-c --load-cookies auth.rda_ucar_edu https://rda.ucar.edu/data/ds084.1/$year/$year$month$day"
opt3="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$year$month${day}/00/atmos/gfs.t00z.pgrb2.0p25.f"

mkdir data
# Wget is good for baking cookies
# cd data ; wget $opt1 --post-data="email=$email&passwd=$pswd&action=login" https://rda.ucar.edu/cgi-bin/login >& /dev/null; cd ..

max_hour=$((days_to_run*24))


for i in $(seq -f "%03g" 0 3 $max_hour)
   do 
   filename=gfs.0p25.$year$month${day}00.f$i.grib2
#   aria2c -x 16 -s 16 -d data --log-level=info $opt2/$filename 
   aria2c -x 16 -s 16 -d data --log-level=info -c $opt3$i
done
fi

echo "Finished GFS data download $(date)" >> $logname.log

finish_dl=$(date +%s)
totaltime_dl=$((finish_dl-start_dl))

echo "Downloading the data took $totaltime_dl seconds" >> $logname.log

### Run the programs
if [ $process_prep == "yes" ]
then
echo "Started prep_chem_sources $(date)" >> $logname.log
./prep_chem_sources.exe >& rsl.1.prep
ln -sf ./*g1-ab.bin emissopt3_d01
ln -sf ./*g1-bb.bin emissfire_d01
ln -sf ./emissions-T-$year-$month-$day-000000-g1-gocartBG.bin wrf_gocart_backg
echo "Finished prep_chem_sources $(date)" >> $logname.log
echo "Press enter (prep)"
read
fi

if [ $process_WPS == "yes" ]
then
echo "Started WPS $(date)" >> $logname.log
./link_grib.csh data/gfs*
./ungrib.exe
./geogrid.exe
./metgrid.exe
echo "Finished WPS $(date)" >> $logname.log
echo "Press enter (WPS)"
read
fi

if [ $process_WRF == "yes" ]
then
rm wrfinput*
rm wrfbdy*
echo "Started real and convert emiss $(date)" >> $logname.log
./real.exe
cp rsl.error.0000 rsl.2.real
echo "Press enter (real)"
read

### Delete the first namelist so we can prepare the second namelist
rm namelist.input

### The second namelist is for convert_emiss.exe and wrf.exe
cat <<EOF >>namelist.input
 &time_control
 run_days                            = $days_to_run,
 run_hours                           = 0,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = $year, $year, $year,
 start_month                         = $month,   $month,   $month,
 start_day                           = $day,   $day,   $day,
 start_hour                          = 00,   00,   00,
 end_year                            = $end_year, $end_year, 202$end_year2,
 end_month                           = $end_month,   $end_month,   $end_month,
 end_day                             = $end_day,   $end_day,   $end_day,
 end_hour                            = 00,   00,   00,
 interval_seconds                    = 10800
 input_from_file                     = .true.,.true.,.true.,
 history_interval                    = 60,   60,   60,
 frames_per_outfile                  = 9999, 9999, 9999,
 restart                             = .false.,
 restart_interval                    = 7200,
 io_form_history                     = 2,
 io_form_restart                     = 2,
 io_form_input                       = 2,
 io_form_boundary                    = 2,

 io_form_auxinput5                   = 2,
 io_form_auxinput6                   = 2,
 io_form_auxinput7                   = 0,
 io_form_auxinput8                   = 2,
 io_form_auxinput13                  = 0,
 frames_per_auxinput6		          = 1,
 frames_per_auxinput7		          = 1,
 frames_per_auxinput8		          = 1,
 frames_per_auxinput13		          = 1,
 auxinput5_interval_m                = 14400, 1440, 1440,
 auxinput7_interval_m                = 14400, 1440, 1440,
 auxinput8_interval_m                = 14400, 1440, 1440,
 auxinput13_interval_m               = 1440, 1440, 1440,
 auxinput7_inname                    = 'wrffirechemi_d<domain>',
 auxinput8_inname                    = 'wrfchemi_gocart_bg_d<domain>',

 force_use_old_data		             = T,
 debug_level			                = 100,
 /

 &domains
 time_step                           = 120,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = $domains,
 e_we                                = 72,    49,   49,
 e_sn                                = 72,    49,   49,
 e_vert                              = 40,    40,   40,
 dx                                  = 27000,9000,9000
 dy                                  = 27000,9000,9000
 p_top_requested                     = 3000,
 num_metgrid_levels                  = 34,
 num_metgrid_soil_levels             = 4,
 grid_id                             = 1,     2,     3,
 parent_id                           = 1,     1,     1,
 i_parent_start                      = 1,     23,       46,
 j_parent_start                      = 1,     28,        6,
 parent_grid_ratio                   = 1,     3,        3,
 parent_time_step_ratio              = 1,        3,        3,
 feedback                            = 0,
 smooth_option                       = 0,
 /

 &physics
 mp_physics                          = 2,     2,     2,
 progn                               = 0,     0,     0,
 naer                                = 1e9
 ra_lw_physics                       = 1,     1,     1,
 ra_sw_physics                       = 2,     2,     2,
 radt                                = 30,    30,    30,
 sf_sfclay_physics                   = 1,     1,     1,
 sf_surface_physics                  = 2,     2,     2,
 bl_pbl_physics                      = 1,     1,     1,
 bldt                                = 0,     0,     0,
 cu_physics                          = 5,     5,     5,
 cudt                                = 0,     0,     0,
 isfflx                              = 1,
 ifsnow                              = 1,
 icloud                              = 1,
 surface_input_source                = 3,
 num_land_cat                        = 21,
 sf_urban_physics                    = 0,     0,     0,
 maxiens                             = 1,
 maxens                              = 3,
 maxens2                             = 3,
 maxens3                             = 16,
 ensdim                              = 144,
 cu_rad_feedback                     = .true.,
 cu_diag			                      = 1,
 /

 &fdda
 /

 &dynamics
 hybrid_opt                          = 2, 
 w_damping                           = 1,
 diff_opt                            = 1,      1,      1,
 km_opt                              = 4,      4,      4,
 diff_6th_opt                        = 0,      0,      0,
 diff_6th_factor                     = 0.12,   0.12,   0.12,
 base_temp                           = 290.
 damp_opt                            = 3,
 zdamp                               = 5000.,  5000.,  5000.,
 dampcoef                            = 0.2,    0.2,    0.2
 khdif                               = 0,      0,      0,
 kvdif                               = 0,      0,      0,
 non_hydrostatic                     = .true., .true., .true.,
 moist_adv_opt                       = 1,      1,      1,     
 scalar_adv_opt                      = 1,      1,      1,     
 chem_adv_opt                        = 1,      1,      1,     
 /

 &bdy_control
 spec_bdy_width                      = 5,
 specified                           = .true.,
 /

 &grib2
 /

 &chem
 kemit                               = 1,
 chem_opt                            = 301,  301,  301,
 io_style_emissions                  = 2,
 chemdt			                      = 2,
 emiss_inpt_opt                      = 1,      1,    1,
 emiss_opt                           = 5,      5,    5,
 chem_in_opt                         = 0,      0,    0,
 phot_opt                            = 1,      1,    1,
 gas_drydep_opt                      = 0,      0,    0,
 aer_drydep_opt                      = 0,      0,    0,
 bio_emiss_opt                       = 1,      1,    0,
 dust_opt                            = 0,
 dmsemis_opt                         = 0,
 seas_opt                            = 0,
 gas_bc_opt                          = 1,      1,    1,
 gas_ic_opt                          = 1,      1,    1,
 aer_bc_opt                          = 1,      1,    1,
 aer_ic_opt                          = 1,      1,    1,
 gaschem_onoff                       = 1,      1,    1,
 aerchem_onoff                       = 1,      1,    1,
 wetscav_onoff                       = 0,      0,    0,
 cldchem_onoff                       = 0,      0,    0,
 vertmix_onoff                       = 1,      1,    1,
 chem_conv_tr                        = 1,      1,    1,
 biomass_burn_opt                    = 0,      0,    0,
 plumerisefire_frq                   = 120,    30,   30,
 aer_ra_feedback                     = 0,      0,    0,
 have_bcs_chem                       = .true., .false., .false.,
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
EOF

./convert_emiss.exe
cp rsl.out.0000 rsl.3.conv
ln -sf wrfchemi_d01 wrfchemi_d01_$year-$month-$day\_00:00:00
echo "Press enter (conv)"
read
#./real.exe
#./real.exe
echo "Finished real and convert emiss $(date)" >> $logname.log


echo "Started WRF.exe $(date)" >> $logname.log
mpirun -np 6 ./wrf.exe
echo "Finished WRF.exe $(date)" >> $logname.log

echo "Finished all task $(date)" >> $logname.log
finish_run=$(date +%s)
totaltime_run=$((finish_run-start_run))
fi

if [ $process_postprocess == "yes" ]
then
pwd
ln -sf wrfout_d01_$year-$month-$day* wrfout_d01
ncl ./plot_pm25.ncl
convert pm2p5*.*.png anime_pm25.gif

ncl ./plot_pm10.ncl
convert pm10*.*.png anime_pm10.gif

fi

echo "CPU Time is $totaltime_run seconds" >> $logname.log
