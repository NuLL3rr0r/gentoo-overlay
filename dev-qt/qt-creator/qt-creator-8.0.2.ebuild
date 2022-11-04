# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
LLVM_MAX_SLOT=14
PLOCALES="cs da de fr hr ja pl ru sl uk zh-CN zh-TW"

inherit llvm cmake virtualx xdg

DESCRIPTION="Lightweight IDE for C++/QML development centering around Qt"
HOMEPAGE="https://doc.qt.io/qtcreator/"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://code.qt.io/${PN}/${PN}.git"
else
	MY_PV=${PV/_/-}
	MY_P=${PN}-opensource-src-${MY_PV}
	[[ ${MY_PV} == ${PV} ]] && MY_REL=official || MY_REL=development
	SRC_URI="https://download.qt.io/${MY_REL}_releases/${PN/-}/$(ver_cut 1-2)/${MY_PV}/${MY_P}.tar.xz"
	S=${WORKDIR}/${MY_P}
	KEYWORDS="~amd64 ~arm ~x86"
fi

LICENSE="GPL-3"
SLOT="0"

# minimum Qt version required
QT_PV="5.15:5"

BDEPEND="
	>=dev-qt/linguist-tools-${QT_PV}
	virtual/pkgconfig
	>=dev-qt/qdoc-${QT_PV}
"
CDEPEND="
	>=dev-qt/qtconcurrent-${QT_PV}
	>=dev-qt/qtcore-${QT_PV}
	>=dev-qt/qtdeclarative-${QT_PV}[widgets]
	>=dev-qt/qtgui-${QT_PV}
	>=dev-qt/qtnetwork-${QT_PV}[ssl]
	>=dev-qt/qtprintsupport-${QT_PV}
	>=dev-qt/qtquickcontrols-${QT_PV}
	>=dev-qt/qtscript-${QT_PV}
	>=dev-qt/qtsql-${QT_PV}[sqlite]
	>=dev-qt/qtsvg-${QT_PV}
	>=dev-qt/qtwidgets-${QT_PV}
	>=dev-qt/qtx11extras-${QT_PV}
	>=dev-qt/qtxml-${QT_PV}
	>=kde-frameworks/syntax-highlighting-5.87:5
	>=sys-devel/clang-$((LLVM_MAX_SLOT)):=
"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}
	sys-devel/gdb[python]
	dev-vcs/git
	>=dev-qt/qtquicktimeline-${QT_PV}
	sys-apps/the_silver_searcher
	dev-vcs/subversion
"
# qt translations must also be installed or qt-creator translations won't be loaded
for x in ${PLOCALES}; do
	IUSE+=" l10n_${x}"
	RDEPEND+=" l10n_${x}? ( >=dev-qt/qttranslations-${QT_PV} )"
done
unset x
