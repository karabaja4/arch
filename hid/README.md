# vbox stuff
apt install linux-headers-amd64
apt install gcc make perl
(guest additions)

# setup sudo
/sbin/usermod -a -G vboxsf igor
/sbin/usermod -a -G sudo igor

# install build stuff
sudo apt install git bc bison flex libssl-dev make libc6-dev libncurses5-dev
sudo apt install crossbuild-essential-armhf

# clone
git clone --depth=1 https://github.com/raspberrypi/linux

# patch
patch -p1 < wakeup.patch

# configs
cd linux
KERNEL=kernel
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcmrpi_defconfig

# build
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs

# copy kernel to sd
mkdir mnt
mkdir mnt/fat32
mkdir mnt/ext4
sudo mount /dev/sdb1 mnt/fat32
sudo mount /dev/sdb2 mnt/ext4

sudo env PATH=$PATH make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=mnt/ext4 modules_install

KERNEL=kernel
sudo cp mnt/fat32/$KERNEL.img mnt/fat32/$KERNEL-backup.img
sudo cp arch/arm/boot/zImage mnt/fat32/$KERNEL.img
sudo cp arch/arm/boot/dts/broadcom/*.dtb mnt/fat32/
sudo cp arch/arm/boot/dts/overlays/*.dtb* mnt/fat32/overlays/
sudo cp arch/arm/boot/dts/overlays/README mnt/fat32/overlays/
sudo umount mnt/fat32
sudo umount mnt/ext4

# camera server
libcamera-vid -t 0 --width 1280 --height 720 --framerate 30 --listen -o tcp://0.0.0.0:8494

# camera client
ffplay tcp://192.168.0.17:8494 -fflags nobuffer -flags low_delay -framedrop