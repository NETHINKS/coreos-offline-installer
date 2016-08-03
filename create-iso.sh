#! /bin/bash

# configuration
SCRIPT_DIR=`dirname ${BASH_SOURCE}`
CONFIG_DIR_TMP="$SCRIPT_DIR/tmp"
CONFIG_DIR_OUTPUT="$SCRIPT_DIR/output"
CONFIG_DIR_APPINSTALL="$SCRIPT_DIR/files_to_add"
CONFIG_DIR_SRC="$SCRIPT_DIR/src"
CONFIG_COREOS_ISO=https://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso
CONFIG_COREOS_INSTALL=https://stable.release.core-os.net/amd64-usr/current/coreos_production_image.bin.bz2

CLOUDCONFIG=""
IGNITION=""
USAGE="Create ISO for CoreOS Offline Setup

$0 [Options]

Options:
-c <Path to cloud-config.yml>   use the given cloud-config.yml file
-i <Path to ignition config>    use the given ignition config file
"

# get command line args
while getopts "c:i:h" OPTION
do
    case $OPTION in
        c) CLOUDCONFIG="$OPTARG" ;;
        i) IGNITION="$OPTARG" ;;
        h) echo "$USAGE"; exit;;
        *) exit 1;;
    esac
done

# check requirements
xorriso -version >/dev/null 2>&1 || { echo >&2 "[ERROR] command xorriso is required, but not found."; exit 1; }

# clear tmp and output directory
echo "Clear tmp and output directory..."
rm -Rf $CONFIG_DIR_TMP/*
rm -Rf $CONFIG_DIR_OUTPUT/*
echo -e "\n\n"

# create directory structure
echo "create directory structure for tmp files..."
mkdir -p $CONFIG_DIR_TMP/setup/coreos_install
mkdir -p $CONFIG_DIR_TMP/setup/app_install
echo -e "\n\n"

# get CoreOS Live ISO and install image
echo "download CoreOS Live ISO..."
wget -O $CONFIG_DIR_TMP/coreos_image.iso $CONFIG_COREOS_ISO
echo -e "\n\n"
echo "download CoreOS Production image..."
wget -O $CONFIG_DIR_TMP/setup/coreos_install/coreos_image.bin.bz2 $CONFIG_COREOS_INSTALL
echo -e "\n\n"

# copy coreos installer to tmp
echo "copy offline installer and cloud-config.yml..."
cp $CONFIG_DIR_SRC/* $CONFIG_DIR_TMP/setup/coreos_install/

# copy cloud-config to tmp
if [[ -n "${CLOUDCONFIG}" ]];
then
    cp $CLOUDCONFIG $CONFIG_DIR_TMP/setup/coreos_install/cloud-config.yml
else
    cp $CONFIG_DIR_SRC/cloud-config.yml $CONFIG_DIR_TMP/setup/coreos_install/
fi
echo -e "\n\n"

# copy ignition config to tmp
if [[ -n "${IGNITION}" ]];
then
    cp $IGNITION $CONFIG_DIR_TMP/setup/coreos_install/coreos-install.json
else
    cp $CONFIG_DIR_SRC/coreos-install.json $CONFIG_DIR_TMP/setup/coreos_install/
fi
echo -e "\n\n"

# copy app_install files to tmp
echo "copy application data..."
cp -R $CONFIG_DIR_APPINSTALL/* $CONFIG_DIR_TMP/setup/app_install
echo -e "\n\n"

# create new live ISO
echo "create new live ISO..."
xorriso \
    -indev $CONFIG_DIR_TMP/coreos_image.iso \
    -outdev $CONFIG_DIR_OUTPUT/coreos_created.iso \
    -map $CONFIG_DIR_TMP/setup /setup \
    -boot_image isolinux patch \
    -commit
echo -e "\n\n"
