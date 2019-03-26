# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils

DESCRIPTION="A LADSPA based multiband equalizer for PulseAudio"
HOMEPAGE="https://github.com/kernelOfTruth/pulseaudio-equalizer"
SRC_URI="https://github.com/kernelOfTruth/pulseaudio-equalizer/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/${P}"

RESTRICT="mirror"

src_install() {
	dobin bin/pulseaudio-equalizer
	dobin bin/pulseaudio-equalizer-gtk
	cp -R "${S}/share" "${D}/usr/" || die "install failed!"
}
