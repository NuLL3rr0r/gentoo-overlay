# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="dd169b82e713c09f31fa6919342543163b5894f3"
EGO_PN="github.com/gopasspw/${PN}"

inherit bash-completion-r1 golang-vcs-snapshot-r1

DESCRIPTION="The slightly more awesome standard unix password manager for teams"
HOMEPAGE="https://www.gopass.pw"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug +pie"

RDEPEND="
	app-crypt/gpgme:1
	dev-vcs/git[threads,gpg,curl]
"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=${PV}"
		-X "main.commit=${GIT_COMMIT:0:8}"
		-X "main.date=$(date -u '+%FT%T%z')"
	)
	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin gopass
	use debug && dostrip -x /usr/bin/gopass
	einstalldocs

	./gopass completion bash > gopass.bash || die
	newbashcomp gopass.bash gopass

	dodir /usr/share/fish/functions
	./gopass completion fish > "${ED}"/usr/share/fish/functions/gopass.fish || die

	dodir /usr/share/zsh/site-functions
	./gopass completion zsh > "${ED}"/usr/share/zsh/site-functions/_gopass || die
}
