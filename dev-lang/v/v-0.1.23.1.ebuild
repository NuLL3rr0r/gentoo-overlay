# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Simple, fast, safe, compiled language for developing maintainable software"
HOMEPAGE="https://vlang.io"

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/vlang/v.git"
	inherit git-r3
else
	SRC_URI="https://github.com/vlang/v/releases/download/${PV}/v_linux.zip -> ${P}.zip"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"

S="${WORKDIR}"

DOCS="CHANGELOG.md CONDUCT.md CONTRIBUTING.md LICENSE README.md"

src_compile() {
	emake
}

src_install() {
	dobin v
}
