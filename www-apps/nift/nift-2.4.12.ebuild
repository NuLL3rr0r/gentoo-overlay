# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit user

DESCRIPTION="A cross-platform open source website generator"
HOMEPAGE="https://www.nift.cc"
SRC_URI="https://github.com/nifty-site-manager/nsm/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE="gedit-highlighting"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/nsm-${PV}"

PATCHES=(
	"${FILESDIR}/${P}.patch"
)

src_compile() {
	emake all
}

src_install() {
	dobin nift
	dobin nsm

	#if use gedit-highlighting; then
	#	insinto /usr/share/gtksourceview-3.0/language-specs
	#	doins html.lang
	#fi
}
