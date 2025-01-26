# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop git-r3 linux-info systemd user

DESCRIPTION="A trimmed version of the pommed hotkey handler for macbooks"
EGIT_REPO_URI="https://github.com/NuLL3rr0r/pommed-light.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

DEPEND="
	media-libs/alsa-lib
	media-libs/audiofile
	dev-libs/confuse
	dev-libs/dbus-glib
	sys-apps/dbus
	sys-libs/zlib
	amd64? ( sys-apps/pciutils )
	x86? ( sys-apps/pciutils )"
RDEPEND="${DEPEND}
	media-sound/alsa-utils
	sys-apps/util-linux"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}.patch
	"${FILESDIR}"/${P}-fno-common.patch
)

pkg_setup() {
	if ! use ppc; then
		linux-info_pkg_setup

		CONFIG_CHECK="~DMIID"
		check_extra_config
	fi
}

src_compile() {
	cd "${S}"/pommed || die
	emake CC="$(tc-getCC)" OFLIB=1
}

src_install() {
	insinto /etc
	if use x86 || use amd64; then
		newins pommed.conf.mactel pommed.conf
	elif use ppc; then
		newins pommed.conf.pmac pommed.conf
	fi

	insinto /usr/share/pommed
	doins pommed/data/*.wav

	dobin pommed/pommed

	newinitd "${FILESDIR}"/pommed.rc pommed
	systemd_dounit "${FILESDIR}"/pommed.service

	dodoc AUTHORS ChangeLog README.md TODO
}
