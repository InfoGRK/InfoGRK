#!/bin/bash
ftp_server=182.16.248.177
ftp_user=wrfuser
ftp_pass=wrfpass
## Directory Listing
export HOME=`cd;pwd`
mkdir $HOME/WRF
cd $HOME/WRF
mkdir Downloads
mkdir Library

## Downloading Libraries
cd Downloads
wget -c --auth-no-challenge=on --keep-session-cookies --no-check-certificate --user=$ftp_user --password=$ftp_pass --content-disposition ftp://$ftp_server/tarballs/*
#aria2c -x 8 -s 8 --ftp-user=$ftp_user --ftp-passwd=$ftp_pass ftp://$ftp_server/tarballs/geog_high_res_mandatory.tar.gz
#aria2c -x 8 -s 8 --ftp-user=$ftp_user --ftp-passwd=$ftp_pass ftp://$ftp_server/tarballs/geog_high_res_mandatory.tar.gz
