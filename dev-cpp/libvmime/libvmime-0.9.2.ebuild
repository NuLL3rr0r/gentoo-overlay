# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit cmake

DESCRIPTION="Library for working with MIME messages and Internet messaging services like IMAP, POP or SMTP"
HOMEPAGE="http://www.vmime.org"
SRC_URI="https://github.com/kisli/vmime/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/vmime-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+c++11 debug doc examples +gnutls icu +imap +maildir +pop sasl sendmail +smtp ssl"

RDEPEND="virtual/libiconv
	gnutls? ( >=net-libs/gnutls-1.2.0 )
	sasl? ( virtual/gsasl )
	sendmail? ( virtual/mta )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

CMAKE_WARN_UNUSED_CLI="yes"

src_prepare() {
	sed -i \
		-e 's|SET(VMIME_INSTALL_LIBDIR ${CMAKE_INSTALL_LIBDIR}${LIB_SUFFIX})|SET(VMIME_INSTALL_LIBDIR ${CMAKE_INSTALL_LIBDIR})|' \
        -e 's|SET(VMIME_INSTALL_LIBDIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}${LIB_SUFFIX})|SET(VMIME_INSTALL_LIBDIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})|' \
        -e 's|SET(VMIME_INSTALL_LIBDIR ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX})|SET(VMIME_INSTALL_LIBDIR ${CMAKE_INSTALL_PREFIX}/lib)|' \
		CMakeLists.txt || die "sed failed"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs="
		$(cmake_use c++11 VMIME_SHARED_PTR_USE_CXX)
		$(cmake_use sasl VMIME_HAVE_SASL_SUPPORT)
		$(cmake_use pop VMIME_HAVE_MESSAGING_PROTO_POP3)
		$(cmake_use smtp VMIME_HAVE_MESSAGING_PROTO_SMTP)
		$(cmake_use imap VMIME_HAVE_MESSAGING_PROTO_IMAP)
		$(cmake_use maildir VMIME_HAVE_MESSAGING_PROTO_MAILDIR )
		$(cmake_use sendmail VMIME_HAVE_MESSAGING_PROTO_SENDMAIL)
	"

	if use icu; then
		mycmakeargs+=" -DVMIME_CHARSETCONV_LIB_IS_ICU=ON -DVMIME_CHARSETCONV_LIB_IS_ICONV=OFF"
	else
		mycmakeargs+=" -DVMIME_CHARSETCONV_LIB_IS_ICU=OFF -DVMIME_CHARSETCONV_LIB_IS_ICONV=ON"
	fi

	if use ssl && use gnutls ; then
		mycmakeargs+=" -DVMIME_TLS_SUPPORT_LIB_IS_GNUTLS=ON -DVMIME_TLS_SUPPORT_LIB_IS_OPENSSL=OFF"
	elif use ssl && ! use gnutls ; then
		mycmakeargs+=" -DVMIME_TLS_SUPPORT_LIB_IS_GNUTLS=OFF -DVMIME_TLS_SUPPORT_LIB_IS_OPENSSL=ON"
	else
		mycmakeargs+=" -DVMIME_TLS_SUPPORT_LIB_IS_GNUTLS=OFF -DVMIME_TLS_SUPPORT_LIB_IS_OPENSSL=OFF"
	fi

	if use debug; then
		CMAKE_BUILD_TYPE="Debug"
	else
		CMAKE_BUILD_TYPE="Release"
	fi
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	if use doc ; then
		doxygen vmime.doxygen || die "doxygen failed"
	fi
}

src_install() {
	cmake_src_install
	dodoc AUTHORS
	if use doc ; then
		dohtml doc/html/*
	fi

	insinto /usr/share/doc/${PF}
	if use examples ; then
		doins -r examples
	fi
}
