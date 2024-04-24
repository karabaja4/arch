apt install linux-headers-amd64
apt install gcc make perl

(guest additions)

/sbin/usermod -a -G vboxsf igor
/sbin/usermod -a -G sudo igor

sudo apt install git bc bison flex libssl-dev make libc6-dev libncurses5-dev
sudo apt install crossbuild-essential-armhf

git clone --depth=1 https://github.com/raspberrypi/linux

# patch
patch -p1 < wakeup.patch

# configs
cd linux
KERNEL=kernel
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcmrpi_defconfig

# build
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
