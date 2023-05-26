# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="programmable network edge"
HOMEPAGE="https://ngrok.com"
SRC_URI="https://bin.equinox.io/c/bNyj1mQVY4c/${PN}-v$(ver_cut 1)-stable-linux-amd64.tgz -> ${P}.tgz"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S=$WORKDIR

QA_PREBUILT="usr/bin/ngrok"

src_compile() {
	true
}

src_install() {
	dobin ngrok
}
