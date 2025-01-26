# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR="ninja"

inherit cmake user

DESCRIPTION="Wt, C++ Web Toolkit"
HOMEPAGE="https://www.webtoolkit.eu/wt"
SRC_URI="https://github.com/emweb/wt/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+c++11 +cmake-module doc examples ext fcgi fcgi-lighthttpd fcgi-nginx firebird +haru libwttest mysql no-std-locale no-std-wstring +opengl +pango postgres qt5 +resources sqlite3 +ssl tests unwind wtdbo +wthttp"
REQUIRED_USE="
	examples? ( sqlite3 wthttp )
	fcgi? ( ^^ ( fcgi-lighthttpd fcgi-nginx ) )
	fcgi-lighthttpd? ( fcgi )
	fcgi-nginx? ( fcgi )
	mysql? ( wtdbo )
	postgres? ( wtdbo )
	sqlite3? ( wtdbo )
	wtdbo? ( sqlite3 )
	"

RDEPEND="
	dev-libs/boost
	media-gfx/graphicsmagick
	media-libs/libpng
	fcgi? ( dev-libs/fcgi )
	firebird? ( dev-db/firebird )
	haru? ( media-libs/libharu )
	mysql? ( virtual/mysql )
	opengl? ( media-libs/glew )
	pango? (
		dev-libs/glib
		media-libs/fontconfig
		x11-libs/pango
	)
	postgres? ( dev-db/postgresql )
	qt5? ( dev-qt/qtcore:5 )
	sqlite3? ( >=dev-db/sqlite-3.0.0 )
	ssl? ( dev-libs/openssl:0= )
	unwind? ( sys-libs/libunwind )
	"
DEPEND="
	doc? (
		app-text/asciidoc
		app-doc/doxygen
	)
	>=dev-build/cmake-3.13.0
	${RDEPEND}
	"

pkg_setup() {
	if use fcgi; then
		WTFCGI_RUNDIR="/var/run/wt"
		WWW_GROUP="www"
		WWW_USER="www"

		if use fcgi-lighthttpd; then
			WWW_GROUP="lighthttpd"
			WWW_USER="lighthttpd"
		elif use fcgi-nginx; then
			WWW_GROUP="nginx"
			WWW_USER="nginx"
		fi

		ebegin "Setting up wtfcgi run directory"
		diropts -m0755
		keepdir "${WTFCGI_RUNDIR}"
		fowners -R ${WWW_USER}:${WWW_GROUP} "${WTFCGI_RUNDIR}"
		eend $?
	fi
}

src_prepare() {
	cmake_src_prepare
	eapply "${FILESDIR}/WtInstall.cmake.patch"
}

src_configure() {
	mycmakeargs=(
		-DBUILD_EXAMPLES:BOOL=$(usex examples)
		-DBUILD_TESTS:BOOL=$(usex tests)
		-DCONFIGDIR:STRING="/etc/wt"
		-DCONNECTOR_FCGI:BOOL=$(usex fcgi)
		-DCONNECTOR_HTTP:BOOL=$(usex wthttp)
		-DCONNECTOR_ISAPI:BOOL=OFF
		-DENABLE_EXT:BOOL=$(usex ext)
		-DENABLE_FIREBIRD:BOOL=$(usex firebird)
		-DENABLE_HARU:BOOL=$(usex haru)
		-DENABLE_LIBWTDBO=$(usex wtdbo)
		-DENABLE_LIBWTTEST:BOOL=$(usex libwttest)
		-DENABLE_MSSQLSERVER:BOOL=OFF
		-DENABLE_MYSQL:BOOL=$(usex mysql)
		-DENABLE_OPENGL:BOOL=$(usex opengl)
		-DENABLE_PANGO:BOOL=$(usex pango)
		-DENABLE_POSTGRES:BOOL=$(usex postgres)
		-DENABLE_QT4:BOOL=OFF
		-DENABLE_QT5:BOOL=$(usex qt5)
		-DENABLE_SQLITE:BOOL=$(usex sqlite3)
		-DENABLE_SSL:BOOL=$(usex ssl)
		-DENABLE_UNWIND:BOOL=$(usex unwind)
		-DEXAMPLES_DESTINATION:STRING="share/examples/wt"
		-DGM_PREFIX:STRING=/usr
		-DINSTALL_DOCUMENTATION:BOOL=$(usex doc)
		-DINSTALL_EXAMPLES:BOOL=$(usex examples)
		-DINSTALL_RESOURCES:BOOL=$(usex resources)
		-DPNG_PREFIX:STRING="/usr"
		-DSSL_PREFIX:STRING="/usr"
		-DWEBGROUP:STRING=""
		-DWEBUSER:STRING=""
		-DWT_NO_STD_LOCALE:BOOL=$(usex no-std-locale)
		-DWT_NO_STD_WSTRING:BOOL=$(usex no-std-wstring)
		-DWT_WARN_HEADER_MISSING_H:BOOL=ON
		-DWT_WRASTERIMAGE_IMPLEMENTATION:STRING="GraphicsMagick"
		-DZLIB_PREFIX:STRING="/usr"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	cmake_src_install

	# Do not violate multilib strict
	mv "${ED}/usr/lib" "${ED}/usr/$(get_libdir)" || die "mv failed"
}
