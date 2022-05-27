# Rocky Linux Current is now at 8.6
Updated Foreman's Repository to force 8.5 for now. Need to add new OS RockyLinux 8.6 to Foreman in the future and use 8.6 driver for Mellonox Fiber Card
https://linux.cc.iitk.ac.in/mirror/centos/elrepo/elrepo/el8/x86_64/RPMS/kmod-mlx4-4.0-7.el8_6.elrepo.x86_64.iso

## C6100 - 4-node chassis 
### mellonox fiber network not supported
Create USB drive with OEMDRV label. Drop https://linux.cc.iitk.ac.in/mirror/centos/elrepo/elrepo/el8/x86_64/RPMS/kmod-mlx4-4.0-6.el8_5.elrepo.x86_64.rpm onto Drive.
inst.dd option loads driver from kickstart installer 
#### test inst.dd=https://linux.cc.iitk.ac.in/mirror/centos/elrepo/elrepo/el8/x86_64/RPMS/kmod-mlx4-4.0-7.el8_6.elrepo.x86_64.iso now that Rocky 8.5 install is fixed
spa-osg-hn.spa.umn.edu OS installation inprogress

## R410
Right now, there are two pxelinux templates for RockyLinux. One for R410 and one for C6100. To install one must modify the OS to use a specific pxelinux template.
This could break the vmlinuz and initrd.img entries on foreman-tftp-01:/var/lib/tftpboot/boot

