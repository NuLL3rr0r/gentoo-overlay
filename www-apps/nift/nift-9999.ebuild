# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 user

DESCRIPTION="A cross-platform open source website generator"
HOMEPAGE="https://www.nift.cc/"
EGIT_REPO_URI="https://github.com/nifty-site-manager/nsm.git"
EGIT_BRANCH="master"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE="gedit-highlighting"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

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
