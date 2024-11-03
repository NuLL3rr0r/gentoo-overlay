# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic systemd desktop

DESCRIPTION="Gridcoin Proof-of-Stake based crypto-currency that rewards BOINC computation"
HOMEPAGE="https://gridcoin.us/"
SRC_URI="https://github.com/${PN}-community/${PN^}-Research/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN^}-Research-${PV}"

LICENSE="MIT"
SLOT="0"

KEYWORDS="~amd64 ~x86"

IUSE_GUI="dbus qt5"
IUSE_DAEMON="daemon"
IUSE_OPTIONAL="+bench +boinc +ccache debug +harden +libraries pic +qrcode static test +upnp +utils systemd"
IUSE="${IUSE_GUI} ${IUSE_DAEMON} ${IUSE_OPTIONAL}"

RESTRICT="!test? ( test )"

# Note: The client *CAN* *NOT* connect to the daemon like the BOINC client does.
#       Therefore either run the daemon or the GUI client. Furthermore starting the GUI client while
#       the daemon is running will kill the latter.
#  See: https://www.reddit.com/r/gridcoin/comments/9x0zsy/comment/e9r85vf/
#       "The GUI instance will not RPC to another wallet process."
REQUIRED_USE="
	?? ( daemon qt5 )
	dbus? ( qt5 )
	qrcode? ( qt5 )
"

RDEPEND="
	>=dev-libs/libevent-2.1.12
	daemon? (
		acct-group/gridcoin
		acct-user/gridcoin[boinc=]
	)
	dev-libs/boost
	dev-libs/openssl-compat:1.1.1
	dev-libs/libzip
	sys-libs/db:5.3[cxx]
	dbus? ( dev-qt/qtdbus:5 )
	qt5? ( dev-qt/qtcore:5 dev-qt/qtgui:5 dev-qt/qtnetwork:5 dev-qt/qtwidgets:5 dev-qt/qtconcurrent:5 dev-qt/qtcharts:5 )
	qrcode? ( media-gfx/qrencode )
	upnp? ( net-libs/miniupnpc )
	boinc? ( sci-misc/boinc )
	utils? ( >=net-p2p/bitcoin-core-27[cli] )
"
DEPEND="
	${RDEPEND}
	qt5? ( dev-qt/linguist-tools:5 )
"

PATCHES=(
	"${FILESDIR}"/${P}-fix_upnp_call.patch
)

pkg_setup() {
	BDB_VER="$(best_version sys-libs/db:5.3)"
	export BDB_CFLAGS="-I/usr/include/db${BDB_VER:12:3}"
	export BDB_LIBS="-ldb_cxx-${BDB_VER:12:3}"
}

src_prepare() {
	if use debug && [[ ! $(portageq envvar FEATURES) =~ .*(splitdebug|nostrip).* ]]; then
		ewarn "You have enabled debug flags and macros during compilation."
		ewarn "For these to be useful, you should also have Portage retain debug symbols."
		ewarn "See https://wiki.gentoo.org/wiki/Debugging on configuring your environment"
		ewarn "and set your desired FEATURES before (re-)building this package."
	fi
	default
	./autogen.sh
}

src_configure() {
	use harden && append-flags -Wa,--noexecstack
	econf \
		$(use_enable bench)            \
		$(use_enable ccache )          \
		$(use_enable debug)            \
		$(use_enable harden hardening) \
		$(use_enable static)           \
		$(use_enable test tests)       \
		$(use_with daemon)             \
		$(use_with dbus qtdbus)        \
		$(use_with libraries libs)     \
		$(use_with pic)                \
		$(use_with qrcode qrencode)    \
		$(use_with qt5 gui qt5)        \
		$(use_with upnp miniupnpc)     \
		$(use_with utils)
}

src_install() {
	if use daemon ; then
		newbin src/gridcoinresearchd gridcoinresearchd
		newman doc/gridcoinresearchd.1 gridcoinresearchd.1
		newinitd "${FILESDIR}"/gridcoin.init gridcoin
		if use systemd ; then
			systemd_dounit "${FILESDIR}"/gridcoin.service
		fi
		diropts -o${PN} -g${PN}
		keepdir /var/lib/${PN}/.GridcoinResearch/
		newconfd "${FILESDIR}"/gridcoinresearch.conf gridcoinresearch
		fowners gridcoin:gridcoin /etc/conf.d/gridcoinresearch
		fperms 0660 /etc/conf.d/gridcoinresearch
		dosym ../../../../etc/conf.d/gridcoinresearch /var/lib/${PN}/.GridcoinResearch/gridcoinresearch.conf
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

}

pkg_postinst() {
	elog
	elog "You are using a source compiled version of gridcoin."
	use daemon && elog "The daemon can be found at /usr/bin/gridcoinresearchd"
	use qt5 && elog "The graphical wallet can be found at /usr/bin/gridcoinresearch"
	elog
	elog "You need to configure this node with a few basic details to do anything"
	elog "useful with gridcoin. The wallet configuration file is located at:"
	use daemon && elog "    /etc/conf.d/gridcoinresearch"
	use qt5 && elog "    \$HOME/.GridcoinResearch"
	elog "The wiki for this configuration file is located at:"
	elog "    http://wiki.gridcoin.us/Gridcoinresearch_config_file"
	elog
}
