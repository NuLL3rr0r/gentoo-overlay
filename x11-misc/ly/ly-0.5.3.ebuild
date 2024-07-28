# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Ly - a TUI display manager"
HOMEPAGE="https://github.com/nullgemm/ly"
EGIT_REPO_URI="${HOMEPAGE}.git"
EGIT_COMMIT="v${PV}"
EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

LICENSE="WTFPL"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="sys-libs/pam
	x11-libs/libxcb
	x11-base/xorg-server
	x11-apps/xauth"
RDEPEND="${DEPEND}"
BDEPEND=""

PATCHES=(
	"${FILESDIR}/gentoo-v${PV}.patch"
)

src_unpack() {
	git-r3_src_unpack
	for _i in argoat configator dragonfail termbox_next; do
		EGIT_REPO_URI="${HOMEPAGE%ly}${_i}.git"
		EGIT_COMMIT=""
		EGIT_CHECKOUT_DIR="${WORKDIR}/${P}/sub/${_i}"
		git-r3_src_unpack
	done
}

src_compile() {
	emake
}
