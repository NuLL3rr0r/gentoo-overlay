# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="NVIDIA Prime Render Offload configuration and utilities"
HOMEPAGE="https://redcorelinux.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND=""

S="${FILESDIR}"

src_install() {
	dobin prime-run
	insinto /usr/share/X11/xorg.conf.d
	newins nvidia-prime.conf 60-nvidia-prime.conf
}
