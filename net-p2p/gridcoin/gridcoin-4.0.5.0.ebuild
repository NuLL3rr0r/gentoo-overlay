# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic user git-r3 systemd desktop

DESCRIPTION="Gridcoin Proof-of-Stake based crypto-currency that rewards BOINC computation"
HOMEPAGE="https://gridcoin.us/"
EGIT_REPO_URI="https://github.com/gridcoin/Gridcoin-Research.git"
EGIT_COMMIT="${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE_GUI="qt5 dbus"
IUSE_DAEMON="daemon"
IUSE_OPTIONAL="+boinc qrcode upnp pic libraries utils +harden bench ccache static debug test"
IUSE="${IUSE_GUI} ${IUSE_DAEMON} ${IUSE_OPTIONAL}"

REQUIRED_USE="|| ( daemon qt5 ) dbus? ( qt5 ) qrcode? ( qt5 )"

RDEPEND=">=dev-libs/boost-1.55.0
	>=dev-libs/openssl-1.0.1g:=
	>=dev-libs/libzip-1.3.0
	dev-libs/libevent
	sys-libs/db:5.3[cxx]
	dbus? ( dev-qt/qtdbus:5 )
	qt5? ( dev-qt/qtcore:5 dev-qt/qtgui:5 dev-qt/qtnetwork:5 dev-qt/qtwidgets:5 dev-qt/qtconcurrent:5 dev-qt/qtcharts:5 )
	qrcode? ( media-gfx/qrencode )
	upnp? ( >=net-libs/miniupnpc-1.9.20140401 )
	boinc? ( sci-misc/boinc )
	utils? ( net-p2p/bitcoin-cli dev-util/bitcoin-tx )"
DEPEND="${RDEPEND}
	qt5? ( dev-qt/linguist-tools:5 )"

S="${WORKDIR}/gridcoin-${PV}"

pkg_setup() {
	BDB_VER="$(best_version sys-libs/db:5.3)"
	export BDB_CFLAGS="-I/usr/include/db${BDB_VER:12:3}"
	export BDB_LIBS="-ldb_cxx-${BDB_VER:12:3}"

	enewgroup ${PN}
	local groups="${PN}"
	use boinc && groups+=",boinc"
	enewuser ${PN} -1 -1 /var/lib/${PN} "${groups}"
}

src_unpack() {
	git-r3_src_unpack
	mkdir -p "$(dirname "${S}")" || die
	ln -s "${WORKDIR}/${P}" "${S}" || die
}

src_prepare() {
	if use debug && [[ ! $(portageq envvar FEATURES) =~ .*(splitdebug|nostrip).* ]]; then
		ewarn "You have enabled debug flags and macros during compilation."
		ewarn "For these to be useful, you should also have Portage retain debug symbols."
		ewarn "See https://wiki.gentoo.org/wiki/Debugging on configuring your environment"
		ewarn "and set your desired FEATURES before (re-)building this package."
	fi
	eapply_user
	./autogen.sh
}

src_configure() {
	use harden && append-flags -Wa,--noexecstack
	econf \
		$(use_with daemon) \
		$(use_with dbus qtdbus) \
		$(use_with qt5 gui qt5) \
		$(use_with qrcode qrencode) \
		$(use_with upnp miniupnpc) \
		$(use_with pic) \
		$(use_with libraries libs) \
		$(use_with utils) \
		$(use_enable harden hardening) \
		$(use_enable bench) \
		$(use_enable ccache ) \
		$(use_enable static) \
		$(use_enable debug) \
		$(use_enable test tests)
}

src_install() {
	if use daemon ; then
		newbin src/gridcoinresearchd gridcoinresearchd
		newman doc/gridcoinresearchd.1 gridcoinresearchd.1
		newinitd "${FILESDIR}"/gridcoin.init gridcoin
		systemd_dounit "${FILESDIR}"/gridcoin.service
	fi
	if use qt5 ; then
		newbin src/qt/gridcoinresearch gridcoinresearch
		newman doc/gridcoinresearch.1 gridcoinresearch.1
		domenu contrib/gridcoinresearch.desktop
		for size in 16 22 24 32 48 64 128 256 ; do
			doicon -s "${size}" "share/icons/hicolor/${size}x${size}/apps/gridcoinresearch.png"
		done
		doicon -s scalable "share/icons/hicolor/scalable/apps/gridcoinresearch.svg"
	fi
	dodoc README.md CHANGELOG.md doc/build-unix.md

	diropts -o${PN} -g${PN}
	keepdir /var/lib/${PN}/.GridcoinResearch/testnet/
	newconfd "${FILESDIR}"/gridcoinresearch.conf gridcoinresearch
	fowners gridcoin:gridcoin /etc/conf.d/gridcoinresearch
	fperms 0660 /etc/conf.d/gridcoinresearch
	dosym ../../../../../etc/conf.d/gridcoinresearch /var/lib/${PN}/.GridcoinResearch/gridcoinresearch.conf
}

pkg_postinst() {
	elog
	elog "You are using a source compiled version of gridcoin."
	elog "The daemon can be found at /usr/bin/gridcoinresearchd"
	use qt5 && elog "The graphical wallet can be found at /usr/bin/gridcoinresearch"
	elog
	elog "You need to configure this node with a few basic details to do anything"
	elog "useful with gridcoin. The wallet configuration file is located at:"
	elog "    /etc/conf.d/gridcoinresearch"
	elog "The wiki for this configuration file is located at:"
	elog "    http://wiki.gridcoin.us/Gridcoinresearch_config_file"
	elog
	if use boinc ; then
		elog "To run your wallet as a researcher you should add gridcoin user to boinc group."
		elog "Run as root:"
		elog "gpasswd -a gridcoin boinc"
		elog
	fi
}
