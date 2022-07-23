# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

inherit cmake-utils multilib

DESCRIPTION="Switch your X keyboard layouts from the command line"
HOMEPAGE="https://github.com/ierton/xkb-switch"
SRC_URI="https://github.com/ierton/xkb-switch/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="x11-libs/libxkbfile"
RDEPEND="${DEPEND}"

src_prepare() {
	# multilib-strict
	sed -i -e "s/DESTINATION lib/DESTINATION $(get_libdir)/" CMakeLists.txt
	default
}
