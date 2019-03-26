# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 cmake-utils

DESCRIPTION="Neovim client library and GUI, in Qt5"
HOMEPAGE="https://github.com/equalsraf/neovim-qt"
EGIT_REPO_URI="https://github.com/equalsraf/neovim-qt.git"
SRC_URI=""

LICENSE="ISC"
SLOT="0"
KEYWORDS=""
IUSE="gcov +msgpack"

DEPEND="
	msgpack? ( dev-libs/msgpack )
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qttest:5
	dev-qt/qtwidgets:5"
RDEPEND="${DEPEND}
	app-editors/neovim"

src_configure() {
	local mycmakeargs=(
		-DUSE_GCOV=$(usex gcov ON OFF)
		-DUSE_SYSTEM_MSGPACK=$(usex msgpack ON OFF)
	)

	cmake-utils_src_configure
}
