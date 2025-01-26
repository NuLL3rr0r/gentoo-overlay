# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9,10,11,12} )

inherit meson python-single-r1

DESCRIPTION="A 15-band equalizer for PulseAudio"
HOMEPAGE="https://github.com/pulseaudio-equalizer-ladspa/equalizer"
SRC_URI="https://github.com/pulseaudio-equalizer-ladspa/equalizer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/pygobject:3
	x11-libs/gtk+:3
	media-sound/pulseaudio
	media-plugins/swh-plugins
	app-alternatives/bc
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-alternatives/ninja
	>=dev-build/meson-0.46
"

S="${WORKDIR}/equalizer-${PV}"

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
	python_optimize
}
