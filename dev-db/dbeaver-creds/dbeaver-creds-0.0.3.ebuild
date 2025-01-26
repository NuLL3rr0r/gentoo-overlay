# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Recover your DBeaver saved credentials."
HOMEPAGE="https://github.com/Tatsh/dbeaver-creds"
SRC_URI="https://github.com/Tatsh/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc64 ~x86"

RDEPEND="dev-libs/openssl"

src_install() {
	dobin "${PN}"
	doman "${PN}.1"
}
