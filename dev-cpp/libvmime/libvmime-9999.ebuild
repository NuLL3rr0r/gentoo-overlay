# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="VMime mail library"
HOMEPAGE="https://github.com/kisli/vmime"
EGIT_REPO_URI="https://github.com/kisli/vmime.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+imap +pop3 +smtp maildir sendmail
	+gnutls +ssl +sasl
	icu doc static"

CDEPEND="sasl? ( net-libs/libgsasl )
	icu? ( dev-libs/icu )
	!icu? ( virtual/libiconv )
	sendmail? ( mail-mta/sendmail )
	"
DEPEND="${CDEPEND}
	doc? ( app-doc/doxygen )
	"
RDEPEND="${CDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DVMIME_BUILD_SAMPLES=OFF
		-DVMIME_SHARED_PTR_USE_CXX=ON
		-DLIB_SUFFIX=""
		-DVMIME_BUILD_STATIC_LIBRARY=$(usex static)
		-DVMIME_HAVE_MESSAGING_PROTO_POP3=$(usex pop3)
		-DVMIME_HAVE_MESSAGING_PROTO_SMTP=$(usex smtp)
		-DVMIME_HAVE_MESSAGING_PROTO_IMAP=$(usex imap)
		-DVMIME_HAVE_MESSAGING_PROTO_MAILDIR=$(usex maildir)
		-DVMIME_HAVE_MESSAGING_PROTO_SENDMAIL=$(usex sendmail)
		-DVMIME_HAVE_SASL_SUPPORT=$(usex sasl)
		-DVMIME_BUILD_DOCUMENTATION=$(usex doc)
	)

	if ! use ssl && use gnutls; then
		mycmakeargs+=( -DVMIME_HAVE_TLS_SUPPORT=1 -DVMIME_TLS_SUPPORT_LIB=gnutls )
	else
		mycmakeargs+=( -DVMIME_HAVE_TLS_SUPPORT=$(usex ssl) -DVMIME_TLS_SUPPORT_LIB=$(usex gnutls gnutls openssl) )
	fi

	cmake_src_configure
}
