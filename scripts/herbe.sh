#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

_herbe "${@}"

# config.h
# -----------------------------------------------------------------
# static const char *background_color = "#2c2c2c";
# static const char *border_color = "#69efad";
# static const char *font_color = "#ffffff";
# static const char *font_pattern = "Roboto:bold:size=10";
# static const unsigned line_spacing = 5;
# static const unsigned int padding = 15;

# static const unsigned int width = 450;
# static const unsigned int border_size = 2;
# static const unsigned int pos_x = 35;
# static const unsigned int pos_y = 60;

# enum corners { TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT };
# enum corners corner = TOP_RIGHT;

# static const unsigned int duration = 5; /* in seconds */

# PKGBUILD
# -----------------------------------------------------------------
# pkgname=herbe
# pkgver=1.0.0
# pkgrel=3
# pkgdesc='Daemon-less notifications without D-Bus'
# arch=('x86_64')
# url='https://github.com/dudik/herbe'
# license=('MIT')
# depends=('libx11' 'libxft')
# source=("${pkgname}-${pkgver}.tar.gz::https://github.com/dudik/${pkgname}/archive/${pkgver}.tar.gz"
#         "https://patch-diff.githubusercontent.com/raw/dudik/herbe/pull/19.diff")
# sha256sums=('78e454159050c86e030fb5a6cf997ac914345210cdf5a4ca4d7600c5296b7f76'
#             'SKIP')

# prepare() {
#     cd "$pkgname-$pkgver"
#     patch -p1 -i ../19.diff
# }

# build() {
# 	cd "$pkgname-$pkgver"
# 	make clean all
# }

# package() {
# 	cd "$pkgname-$pkgver"
# 	make PREFIX=/usr DESTDIR="$pkgdir/" install
# 	install -D -m 644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
# }
