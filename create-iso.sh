#! /bin/bash

# configuration
CONFIG_DIR_TMP="./tmp"
CONFIG_DIR_OUTPUT="./output"
CONFIG_DIR_APPINSTALL="./files_to_add"
CONFIG_DIR_SRC="./src"
CONFIG_COREOS_ISO=https://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso
CONFIG_COREOS_INSTALL=https://stable.release.core-os.net/amd64-usr/current/coreos_production_image.bin.bz2

# clear tmp and output directory
rm -Rf $CONFIG_DIR_TMP/*
rm -Rf $CONFIG_DIR_OUTPUT/*

# create directory structure
mkdir -p $CONFIG_DIR_TMP/setup/coreos_install
mkdir -p $CONFIG_DIR_TMP/setup/app_install

# get CoreOS Live ISO and install image
wget -O $CONFIG_DIR_TMP/coreos_image.iso $CONFIG_COREOS_ISO
wget -O $CONFIG_DIR_TMP/setup/coreos_install/coreos_image.bin.bz2 $CONFIG_COREOS_INSTALL

# copy coreos installer to tmp
cp $CONFIG_DIR_SRC/coreos-offline-install $CONFIG_DIR_TMP/setup/coreos_install/

# copy cloud-config to tmp
cp $CONFIG_DIR_SRC/cloud-config.yml $CONFIG_DIR_TMP/setup/coreos_install/

# copy app_install files to tmp
cp -R $CONFIG_DIR_APPINSTALL/* $CONFIG_DIR_TMP/setup/app_install

# create new live ISO
xorriso \
    -indev $CONFIG_DIR_TMP/coreos_image.iso \
    -outdev $CONFIG_DIR_OUTPUT/coreos_created.iso \
    -map $CONFIG_DIR_TMP/setup /setup \
    -boot_image isolinux patch \
    -commit
