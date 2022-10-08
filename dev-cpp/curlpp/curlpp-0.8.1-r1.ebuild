# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="C++ wrapper for libcURL"
HOMEPAGE="http://www.curlpp.org/"
SRC_URI="https://github.com/jpbarrette/curlpp/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="doc examples static-libs"

RDEPEND=">=net-misc/curl-7.58.0"
DEPEND=">=dev-util/cmake-3.9.6
	${RDEPEND}"

src_prepare() {
	cmake_src_prepare
	sed -i 's/@LDFLAGS@ //' extras/curlpp.pc.in
	if ! use static-libs; then
		eapply "${FILESDIR}/no_static_lib.patch"
	fi
}

src_install() {
	cmake_src_install
	dodoc Readme.md doc/AUTHORS doc/TODO
	if use doc; then
		dodoc doc/guide.pdf
	fi
	if use examples; then
		dodoc -r examples/
	fi
}
