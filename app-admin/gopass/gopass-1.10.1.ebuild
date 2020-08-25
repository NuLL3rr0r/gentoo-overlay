# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="e2d1549f452a0df1fc52e42e7d0f654334d7144e"
EGO_PN="github.com/gopasspw/${PN}"
EGO_VENDOR=(
	# Note: Keep EGO_VENDOR in sync with `GO111MODULE=on go list -m all`
	"cloud.google.com/go v0.26.0 github.com/googleapis/google-cloud-go"
	"filippo.io/age v1.0.0-beta4 github.com/FiloSottile/age"
	"github.com/BurntSushi/toml v0.3.1"
	"github.com/alecthomas/binary fb1b1d9c299c"
	"github.com/atotto/clipboard v0.1.2"
	"github.com/blang/semver 1a9109f8c4a1"
	"github.com/caspr-io/yamlpath 502e8d113a9b"
	"github.com/cenkalti/backoff v2.2.1"
	"github.com/census-instrumentation/opencensus-proto v0.2.1"
	"github.com/chzyer/logex v1.1.10"
	"github.com/chzyer/readline 2972be24d48e"
	"github.com/chzyer/test a1ea475d72b1"
	"github.com/client9/misspell v0.3.4"
	"github.com/cpuguy83/go-md2man/v2 v2.0.0 github.com/cpuguy83/go-md2man"
	"github.com/creack/pty v1.1.9"
	"github.com/davecgh/go-spew v1.1.1"
	"github.com/dominikschulz/github-releases v0.0.3"
	"github.com/dustin/go-humanize v1.0.0"
	"github.com/envoyproxy/go-control-plane 5f8ba28d4473"
	"github.com/envoyproxy/protoc-gen-validate v0.1.0"
	"github.com/fatih/color v1.9.0"
	"github.com/godbus/dbus 8a1682060722"
	"github.com/gokyle/twofactor v1.0.1"
	"github.com/golang/glog 23def4e6c14b"
	"github.com/golang/mock v1.1.1"
	"github.com/golang/protobuf v1.4.2"
	"github.com/google/go-cmp v0.5.1"
	"github.com/google/go-github v17.0.0"
	"github.com/google/go-querystring v1.0.0"
	"github.com/google/gofuzz v1.0.0"
	"github.com/gopherjs/gopherjs 0766667cb4d1"
	"github.com/hashicorp/errwrap v1.0.0"
	"github.com/hashicorp/go-multierror v1.1.0"
	"github.com/hashicorp/golang-lru v0.5.4"
	"github.com/jsimonetti/pwscheme 76804708ecad"
	"github.com/json-iterator/go v1.1.10"
	"github.com/jtolds/gls v4.20.0"
	"github.com/kballard/go-shellquote 95032a82bc51"
	"github.com/klauspost/cpuid v1.3.1"
	"github.com/konsorten/go-windows-terminal-sequences v1.0.1"
	"github.com/kr/pretty v0.1.0"
	"github.com/kr/pty v1.1.1"
	"github.com/kr/text v0.2.0"
	"github.com/martinhoefling/goxkcdpwgen 7dc3d102eca3"
	"github.com/mattn/go-colorable v0.1.7"
	"github.com/mattn/go-isatty v0.0.12"
	"github.com/minio/md5-simd v1.1.0"
	"github.com/minio/minio-go/v6 v6.0.57 github.com/minio/minio-go"
	"github.com/minio/sha256-simd v0.1.1"
	"github.com/mitchellh/go-homedir v1.1.0"
	"github.com/mitchellh/go-ps v1.0.0"
	"github.com/modern-go/concurrent bacd9c7ef1dd"
	"github.com/modern-go/reflect2 v1.0.1"
	"github.com/muesli/crunchy v0.4.0"
	"github.com/nbutton23/zxcvbn-go ae427f1e4c1d"
	"github.com/niemeyer/pretty a10e7caefd8e"
	"github.com/pkg/errors v0.9.1"
	"github.com/pmezard/go-difflib v1.0.0"
	"github.com/prometheus/client_model 14fe0d1b01d4"
	"github.com/russross/blackfriday/v2 v2.0.1 github.com/russross/blackfriday"
	"github.com/schollz/closestmatch 1fbe626be92e"
	"github.com/sergi/go-diff v1.1.0"
	"github.com/shurcooL/sanitized_anchor_name v1.0.0"
	"github.com/sirupsen/logrus v1.5.0"
	"github.com/skip2/go-qrcode da1b6568686e"
	"github.com/smartystreets/assertions v1.0.0"
	"github.com/smartystreets/goconvey v1.6.4"
	"github.com/spf13/pflag v1.0.3"
	"github.com/stretchr/objx v0.1.0"
	"github.com/stretchr/testify v1.6.1"
	"github.com/urfave/cli/v2 v2.2.0 github.com/urfave/cli"
	"github.com/xrash/smetrics 89a2a8a1fb0b"
	"golang.org/x/crypto 123391ffb6de github.com/golang/crypto"
	"golang.org/x/exp 509febef88a4 github.com/golang/exp"
	"golang.org/x/lint d0100b6bd8b3 github.com/golang/lint"
	"golang.org/x/net ab3426394381 github.com/golang/net"
	"golang.org/x/oauth2 d2e6202438be github.com/golang/oauth2"
	"golang.org/x/sync 112230192c58 github.com/golang/sync"
	"golang.org/x/sys 1030fc2bf1d9 github.com/golang/sys"
	"golang.org/x/text v0.3.3 github.com/golang/text"
	"golang.org/x/tools a101b041ded4 github.com/golang/tools"
	"golang.org/x/xerrors 5ec99f83aff1 github.com/golang/xerrors"
	"google.golang.org/appengine v1.4.0 github.com/golang/appengine"
	"google.golang.org/genproto cb27e3aa2013 github.com/googleapis/go-genproto"
	"google.golang.org/grpc v1.27.0 github.com/grpc/grpc-go"
	"google.golang.org/protobuf v1.25.0 github.com/protocolbuffers/protobuf-go"
	"gopkg.in/check.v1 8fa46927fb4f github.com/go-check/check"
	"gopkg.in/ini.v1 v1.57.0 github.com/go-ini/ini"
	"gopkg.in/yaml.v2 v2.3.0 github.com/go-yaml/yaml"
	"gopkg.in/yaml.v3 eeeca48fe776 github.com/go-yaml/yaml"
	"gotest.tools v2.2.0 github.com/gotestyourself/gotest.tools"
	"gotest.tools/v3 v3.0.2 github.com/gotestyourself/gotest.tools"
	"honnef.co/go/tools ea95bdfd59fc github.com/dominikh/go-tools"
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
