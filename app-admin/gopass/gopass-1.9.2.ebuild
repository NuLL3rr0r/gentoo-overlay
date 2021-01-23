# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="e2d1549f452a0df1fc52e42e7d0f654334d7144e"
EGO_PN="github.com/gopasspw/${PN}"
EGO_VENDOR=(
	# Note: Keep EGO_VENDOR in sync with `GO111MODULE=on go list -m all`
	"github.com/BurntSushi/toml v0.3.1"
	"github.com/DATA-DOG/go-sqlmock v1.3.3"
	"github.com/ProtonMail/go-appdir v1.1.0"
	"github.com/alecthomas/binary fb1b1d9c299c"
	"github.com/atotto/clipboard v0.1.2"
	"github.com/blang/semver 1a9109f8c4a1"
	"github.com/cenkalti/backoff v2.2.1"
	"github.com/cpuguy83/go-md2man/v2 v2.0.0 github.com/cpuguy83/go-md2man"
	"github.com/creack/pty v1.1.9"
	"github.com/davecgh/go-spew v1.1.1"
	"github.com/dominikschulz/github-releases v0.0.2"
	"github.com/doronbehar/gocui v0.4.2"
	"github.com/doronbehar/termbox-go 8c9470559e05"
	"github.com/fatih/color v1.9.0"
	"github.com/gdamore/encoding v1.0.0"
	"github.com/gdamore/tcell v1.3.0"
	"github.com/godbus/dbus 8a1682060722"
	"github.com/gokyle/twofactor v1.0.1"
	"github.com/golang/protobuf v1.4.0"
	"github.com/google/go-cmp v0.4.0"
	"github.com/google/go-github v17.0.0"
	"github.com/google/go-querystring v1.0.0"
	"github.com/hashicorp/errwrap v1.0.0"
	"github.com/hashicorp/go-multierror v1.1.0"
	"github.com/hashicorp/golang-lru v0.5.4"
	"github.com/jsimonetti/pwscheme 76804708ecad"
	"github.com/kballard/go-shellquote 95032a82bc51"
	"github.com/kr/pty v1.1.1"
	"github.com/kr/text v0.2.0"
	"github.com/lucasb-eyer/go-colorful v1.0.3"
	"github.com/martinhoefling/goxkcdpwgen 7dc3d102eca3"
	"github.com/mattn/go-colorable v0.1.6"
	"github.com/mattn/go-isatty v0.0.12"
	"github.com/mattn/go-runewidth v0.0.9"
	"github.com/mitchellh/go-homedir v1.1.0"
	"github.com/mitchellh/go-ps v1.0.0"
	"github.com/muesli/crunchy v0.4.0"
	"github.com/muesli/goprogressbar e540249d2ac1"
	"github.com/niemeyer/pretty a10e7caefd8e"
	"github.com/pkg/errors v0.9.1"
	"github.com/pmezard/go-difflib v1.0.0"
	"github.com/russross/blackfriday/v2 v2.0.1 github.com/russross/blackfriday"
	"github.com/schollz/closestmatch 1fbe626be92e"
	"github.com/shurcooL/sanitized_anchor_name v1.0.0"
	"github.com/skip2/go-qrcode 9434209cb086"
	"github.com/stretchr/objx v0.1.0"
	"github.com/stretchr/testify v1.5.1"
	"github.com/urfave/cli/v2 v2.2.0 github.com/urfave/cli"
	"github.com/xrash/smetrics a3153f7040e9"
	"golang.org/x/crypto 4bdfaf469ed5 github.com/golang/crypto"
	"golang.org/x/net e086a090c8fd github.com/golang/net"
	"golang.org/x/sys 1957bb5e6d1f github.com/golang/sys"
	"golang.org/x/text v0.3.2 github.com/golang/text"
	"golang.org/x/tools 90fa682c2a6e github.com/golang/tools"
	"golang.org/x/xerrors 9bdfabe68543 github.com/golang/xerrors"
	"google.golang.org/protobuf v1.21.0 github.com/protocolbuffers/protobuf-go"
	"gopkg.in/check.v1 8fa46927fb4f github.com/go-check/check"
	"gopkg.in/yaml.v2 v2.2.8 github.com/go-yaml/yaml"
	"rsc.io/qr v0.2.0 github.com/rsc/qr"
)

inherit bash-completion-r1 golang-vcs-snapshot-r1

DESCRIPTION="The slightly more awesome standard unix password manager for teams"
HOMEPAGE="https://www.gopass.pw"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
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
		-v -work -x -mod vendor
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
