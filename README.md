# CoreOS Offline Installer

This script creates an offline setup for [CoreOS](https://coreos.com/ "CoreOS Website"). 

To install CoreOS, you can boot the offical Live ISO and start a setup. The problem here is, that this setup downloads the latest CoreOS image from the internet, which may be a problem in some environments. This script creates a patched Live ISO with an offline installer and if configured some additional files to role out some application data.

The script will download the latest Core Live ISO and setup image. It will pack the image, an offline-installer, a default cloud-config.yml (or if you want, your own file), a default ignition configuration (or if you want, your own file) and data for your application (all files you placed in the *files_to_add* directory). With this data, a new Live ISO will be created. You can use this live ISO to start an offline setup of CoreOS.

## Requirements

For using the script, you will need an internet connection to create the offline setup. Also, the following tools/commands were needed:
- wget
- xorriso


## Usage
 
Checkout or download the repository, check the requirements mentioned above and place the files you want to add for your application under *files_to_add*. After that, use the following command to create your ISO file:

```
create-iso.sh [-c <path to your cloud-config.yml>] [-i <path to your ignition config>]
```
By default, a default cloud-config.yml and ignition configuration will be used. If you want to add your own config, use the *-c* option for cloud-config and the *-i* option for the ignition config. You can find the created ISO file in the *output* directory.

Boot from this ISO image and get root rights:
```
sudo su
```

After that, mount the directory with the added files using the following command:
```
mount /dev/sr0 /media
```

You can start your CoreOS offline setup with the following commands:
```
cd /media/setup/coreos_install
./coreos-offline-install -d <setup device> -c cloud-config.yml -a /media/setup/app_install
```
Or if you want to use the ignition config:
```
./coreos-offline-install -d <setup device> -i coreos-install.json -a /media/setup/app_install
```

If you want to change the generated cloud-config.yml or ignition config, copy the file to /tmp, where you can edit them.

CoreOS will be installed on the given device. If you used the default cloud-config.yml/ignition config (and not your own), you can login with admin/admin. The data for your application (placed in *files_to_add*) are available under */app* .

## Support

For support questions, enhancement requests or bugs, please use the issues in the [Github project](https://github.com/michael-batz/coreos-offline-installer)
