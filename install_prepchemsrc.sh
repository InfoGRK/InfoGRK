#!/bin/csh

cd $prep_chem_dir

cd build
make OPT=gfortran.wrf CHEM=RADM_WRF_FIM
