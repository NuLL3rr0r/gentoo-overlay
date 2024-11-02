# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# You will need games-util/steam-client-meta from the steam-overlay for this to work

EAPI=8

CRATES="
	smallvec-1.13.1
	overload-0.1.1
	matchers-0.1.0
	accesskit_unix-0.6.2
	futures-sink-0.3.30
	regex-automata-0.1.10
	pico-args-0.5.0
	aho-corasick-1.1.2
	anyhow-1.0.79
	serde-1.0.195
	windows-0.52.0
	async-recursion-1.0.5
	symphonia-core-0.5.3
	malloc_buf-0.0.6
	ewebsock-0.4.0
	tinyvec-1.6.0
	linux-raw-sys-0.3.8
	event-listener-3.1.0
	ndk-0.7.0
	getrandom-0.2.12
	addr2line-0.21.0
	cpal-0.15.2
	document-features-0.2.8
	minimal-lexical-0.2.1
	humantime-2.1.0
	target-lexicon-0.12.13
	as-raw-xcb-connection-1.0.1
	cfg_aliases-0.1.1
	zbus_names-2.6.0
	ipnet-2.9.0
	zstd-safe-5.0.2+zstd.1.5.2
	symphonia-0.5.3
	com_macros-0.6.0
	fastrand-1.9.0
	jni-sys-0.3.0
	bit-set-0.5.3
	tungstenite-0.21.0
	block-sys-0.1.0-beta.1
	epaint-0.25.0
	async-channel-2.1.1
	which-4.4.2
	objc_id-0.1.1
	futures-lite-1.13.0
	glam-0.25.0
	unicode-segmentation-1.10.1
	nom-7.1.3
	cesu8-1.1.0
	icrate-0.0.4
	hyper-tls-0.5.0
	zbus_macros-3.14.1
	async-broadcast-0.5.1
	nohash-hasher-0.2.0
	nu-ansi-term-0.46.0
	windows_i686_msvc-0.52.0
	android-properties-0.2.2
	hex-0.4.3
	sha2-0.10.8
	errno-0.2.8
	nix-0.26.4
	base64ct-1.6.0
	headers-0.3.9
	wayland-cursor-0.31.0
	wgpu-0.19.0
	profiling-procmacros-1.0.13
	tracing-core-0.1.32
	nix-0.24.3
	regex-1.10.2
	pin-project-internal-1.1.3
	owned_ttf_parser-0.20.0
	objc2-encode-3.0.0
	gdk-pixbuf-sys-0.18.0
	cfg-expr-0.15.6
	toml_edit-0.19.15
	strict-num-0.1.1
	gio-sys-0.18.1
	ogg-0.8.0
	wgpu-types-0.19.0
	zstd-sys-2.0.9+zstd.1.5.5
	windows_aarch64_gnullvm-0.52.0
	futures-0.3.30
	num-traits-0.2.17
	serde_repr-0.1.18
	ryu-1.0.16
	anstyle-wincon-3.0.2
	base64-0.21.7
	unicode-ident-1.0.12
	xkeysym-0.2.0
	num_enum-0.7.2
	objc-sys-0.2.0-beta.2
	windows_aarch64_msvc-0.48.5
	httpdate-1.0.3
	cocoa-0.25.0
	wayland-protocols-wlr-0.2.0
	core-foundation-sys-0.8.6
	libm-0.2.8
	linux-raw-sys-0.4.13
	num_enum-0.5.11
	pango-sys-0.18.0
	serde_derive-1.0.195
	strsim-0.10.0
	inout-0.1.3
	num_enum_derive-0.5.11
	tracy-client-0.16.5
	calloop-wayland-source-0.2.0
	darling_core-0.20.3
	loom-0.7.1
	ecolor-0.25.0
	termcolor-1.4.1
	ndk-context-0.1.1
	renderdoc-sys-1.0.0
	arrayref-0.3.7
	socket2-0.5.5
	atspi-connection-0.3.0
	futures-core-0.3.30
	bytes-1.5.0
	objc2-0.3.0-beta.3.patch-leaks.3
	fern-0.6.2
	windows-0.48.0
	memoffset-0.9.0
	mio-0.8.10
	gethostname-0.4.3
	pin-project-lite-0.2.13
	tracy-client-sys-0.22.1
	openssl-macros-0.1.1
	generator-0.7.5
	utf8parse-0.2.1
	open-5.0.1
	num-integer-0.1.45
	winres-0.1.12
	gpu-descriptor-0.2.4
	sctk-adwaita-0.8.1
	wasm-bindgen-macro-0.2.90
	async-signal-0.2.5
	symphonia-metadata-0.5.3
	glib-sys-0.18.1
	alsa-0.7.1
	waker-fn-1.1.1
	vcpkg-0.2.15
	gethostname-0.3.0
	neli-proc-macros-0.1.3
	anstyle-parse-0.2.3
	pin-utils-0.1.0
	hexf-parse-0.2.1
	x11-dl-2.21.0
	thread_local-1.1.7
	untrusted-0.9.0
	cipher-0.4.4
	presser-0.3.1
	windows_x86_64_gnullvm-0.48.5
	libc-0.2.152
	gloo-utils-0.2.0
	winapi-i686-pc-windows-gnu-0.4.0
	alsa-sys-0.3.1
	tokio-tungstenite-0.20.1
	ttf-parser-0.20.0
	toml-0.8.8
	windows-sys-0.45.0
	libredox-0.0.1
	io-lifetimes-1.0.11
	atspi-0.19.0
	winit-0.29.10
	naga-0.19.0
	futures-executor-0.3.30
	cfg-if-1.0.0
	socket2-0.4.10
	foreign-types-0.5.0
	bitflags-2.4.2
	windows_x86_64_msvc-0.42.2
	objc2-encode-2.0.0-pre.2
	colorchoice-1.0.0
	peeking_take_while-0.1.2
	windows_x86_64_gnu-0.52.0
	windows_aarch64_gnullvm-0.48.5
	windows_aarch64_gnullvm-0.42.2
	lazy_static-1.4.0
	async-lock-3.3.0
	coreaudio-sys-0.2.15
	nalgebra-macros-0.1.0
	oboe-0.5.0
	png-0.17.11
	dispatch-0.2.0
	tracing-subscriber-0.3.18
	crc32fast-1.3.2
	encoding_rs_io-0.1.7
	foreign-types-shared-0.1.1
	home-0.5.9
	accesskit_macos-0.10.1
	objc-0.2.7
	glow-0.13.1
	rustls-pemfile-1.0.4
	str-buf-1.0.6
	android-tzdata-0.1.1
	enumflags2-0.7.8
	ordered-stream-0.2.0
	tracing-log-0.2.0
	android_logger-0.13.3
	egui-0.25.0
	password-hash-0.4.2
	async-io-2.3.0
	errno-dragonfly-0.1.2
	js-sys-0.3.67
	zvariant-3.15.0
	image-0.24.8
	xkbcommon-dl-0.4.1
	objc2-0.4.1
	anstream-0.6.11
	tiny-skia-path-0.11.3
	smithay-client-toolkit-0.18.0
	accesskit_windows-0.15.1
	gpu-descriptor-types-0.1.2
	orbclient-0.3.47
	uds_windows-1.1.0
	env_filter-0.1.0
	x11rb-0.13.0
	statrs-0.16.0
	async-io-1.13.0
	libloading-0.8.1
	windows_x86_64_gnu-0.48.5
	async-process-1.8.1
	fnv-1.0.7
	piper-0.2.1
	derivative-2.2.0
	serde_spanned-0.6.5
	runas-1.0.0
	color_quant-1.1.0
	system-configuration-sys-0.5.0
	bit-vec-0.6.3
	windows-sys-0.52.0
	reqwest-0.11.23
	jack-sys-0.5.1
	dasp_sample-0.11.0
	dirs-sys-0.4.1
	bumpalo-3.14.0
	ring-0.17.7
	windows-core-0.52.0
	tungstenite-0.20.1
	mime-0.3.17
	web-sys-0.3.67
	windows-interface-0.48.0
	digest-0.10.7
	glutin_glx_sys-0.5.0
	concurrent-queue-2.4.0
	slotmap-1.0.7
	scoped-tls-1.0.1
	want-0.3.1
	wayland-scanner-0.31.0
	system-configuration-0.5.1
	cgl-0.3.2
	range-alloc-0.1.3
	dirs-5.0.1
	egui-winit-0.25.0
	walkdir-2.4.0
	android-activity-0.5.1
	rustversion-1.0.14
	windows_aarch64_msvc-0.42.2
	lock_api-0.4.11
	fastrand-2.0.1
	windows_i686_msvc-0.48.5
	parking_lot_core-0.9.9
	futures-lite-2.2.0
	memchr-2.7.1
	valuable-0.1.0
	atk-sys-0.18.0
	wayland-csd-frame-0.3.0
	http-0.2.11
	iana-time-zone-haiku-0.1.2
	block-sys-0.2.1
	winapi-x86_64-pc-windows-gnu-0.4.0
	rustix-0.37.27
	windows-implement-0.48.0
	windows-targets-0.48.5
	windows-targets-0.52.0
	futures-macro-0.3.30
	ndk-sys-0.4.1+23.1.7779620
	block2-0.2.0-alpha.6
	android_log-sys-0.3.1
	windows_i686_gnu-0.42.2
	winreg-0.50.0
	foreign-types-shared-0.3.1
	accesskit_consumer-0.16.1
	env_logger-0.11.0
	tokio-native-tls-0.3.1
	polling-3.3.2
	is-terminal-0.4.10
	autocfg-1.1.0
	ab_glyph-0.2.23
	cc-1.0.83
	miniz_oxide-0.7.1
	paste-1.0.14
	bzip2-sys-0.1.11+1.0.8
	simd-adler32-0.3.7
	num-rational-0.4.1
	windows_x86_64_gnullvm-0.52.0
	num_cpus-1.16.0
	encoding_rs-0.8.33
	toml-0.5.11
	atomic-waker-1.1.2
	litrs-0.4.1
	zerocopy-derive-0.7.32
	local-ip-address-0.5.6
	futures-util-0.3.30
	windows_i686_msvc-0.42.2
	wasm-bindgen-backend-0.2.90
	webbrowser-0.8.12
	event-listener-2.5.3
	hyper-0.14.28
	glyph_brush_layout-0.2.3
	unicode-xid-0.2.4
	tokio-macros-2.2.0
	jni-0.21.1
	ahash-0.8.7
	bitflags-1.3.2
	app_dirs2-2.5.5
	jni-0.20.0
	object-0.32.2
	emath-0.25.0
	hound-3.5.1
	claxon-0.4.3
	tower-service-0.3.2
	gimli-0.28.1
	ntapi-0.4.1
	either-1.9.0
	proc-macro2-1.0.76
	rand_core-0.6.4
	zvariant_derive-3.15.0
	xdg-2.5.2
	gpu-allocator-0.25.0
	tokio-1.35.1
	equivalent-1.0.1
	arrayvec-0.7.4
	indexmap-2.1.0
	toml_datetime-0.6.5
	glutin_egl_sys-0.6.0
	wasi-0.11.0+wasi-snapshot-preview1
	hassle-rs-0.11.0
	web-time-0.2.4
	same-file-1.0.6
	blocking-1.5.1
	winapi-0.3.9
	typenum-1.17.0
	cursor-icon-1.1.0
	rustc-demangle-0.1.23
	security-framework-2.9.2
	ash-0.37.3+1.3.251
	adler-1.0.2
	is-docker-0.2.0
	ident_case-1.0.1
	xi-unicode-0.3.0
	ab_glyph_rasterizer-0.1.8
	windows_i686_gnu-0.48.5
	backtrace-0.3.69
	env_logger-0.10.2
	fdeflate-0.3.4
	wayland-sys-0.31.1
	winapi-wsapoll-0.1.1
	tracing-0.1.40
	egui_glow-0.25.0
	x11rb-0.12.0
	errno-0.3.8
	darling-0.20.3
	thiserror-1.0.56
	windows_x86_64_msvc-0.48.5
	wasm-bindgen-futures-0.4.40
	scopeguard-1.2.0
	schannel-0.1.23
	parking_lot-0.12.1
	memmap2-0.9.3
	cocoa-foundation-0.1.2
	crypto-common-0.1.6
	xdg-home-1.0.0
	deranged-0.3.11
	tempfile-3.9.0
	jack-0.11.4
	semver-1.0.21
	cpufeatures-0.2.12
	matrixmultiply-0.3.8
	raw-window-handle-0.5.2
	iana-time-zone-0.1.59
	zstd-0.11.2+zstd.1.5.2
	zvariant_utils-1.0.1
	allocator-api2-0.2.16
	glob-0.3.1
	event-listener-strategy-0.4.0
	core-foundation-0.9.4
	windows-sys-0.48.0
	lewton-0.10.2
	instant-0.1.12
	quick-xml-0.30.0
	wgpu-core-0.19.0
	time-core-0.1.2
	foreign-types-macros-0.2.3
	futures-task-0.3.30
	parking-2.2.0
	x11rb-protocol-0.12.0
	wide-0.7.13
	regex-syntax-0.8.2
	is-wsl-0.4.0
	windows_i686_gnu-0.52.0
	gl_generator-0.14.0
	idna-0.5.0
	neli-0.6.4
	console_error_panic_hook-0.1.7
	winapi-util-0.1.6
	gdk-sys-0.18.0
	com-0.6.0
	num-derive-0.3.3
	rodio-0.17.3
	hmac-0.12.1
	event-listener-4.0.3
	rustc-hash-1.1.0
	profiling-1.0.13
	wasm-logger-0.2.0
	wasm-bindgen-macro-support-0.2.90
	h2-0.3.24
	anstyle-query-1.0.2
	cairo-sys-rs-0.18.2
	wasm-streams-0.3.0
	tiny-skia-0.11.3
	rawpointer-0.2.1
	combine-4.6.6
	tokio-rustls-0.24.1
	generic-array-0.14.7
	subtle-2.5.0
	glutin_wgl_sys-0.5.0
	syn-1.0.109
	khronos_api-3.1.0
	rustls-0.21.10
	openssl-sys-0.9.99
	try-lock-0.2.5
	bytemuck_derive-1.5.0
	serde_urlencoded-0.7.1
	ndk-sys-0.5.0+25.2.9519653
	sha1-0.10.6
	libloading-0.7.4
	system-deps-6.2.0
	zip-0.6.6
	khronos-egl-6.0.0
	windows_x86_64_msvc-0.52.0
	safe_arch-0.7.1
	approx-0.5.1
	webpki-roots-0.25.3
	quote-1.0.35
	rustls-webpki-0.101.7
	block2-0.3.0
	jobserver-0.1.27
	wasm-bindgen-shared-0.2.90
	core-graphics-0.23.1
	httparse-1.8.0
	symphonia-bundle-mp3-0.5.3
	memoffset-0.7.1
	wayland-protocols-plasma-0.2.0
	shlex-1.2.0
	x11rb-protocol-0.13.0
	block-0.1.6
	log-0.4.20
	accesskit-0.12.2
	chrono-0.4.31
	com_macros_support-0.6.0
	prettyplease-0.2.16
	windows-targets-0.42.2
	smithay-clipboard-0.7.0
	time-0.3.31
	data-encoding-2.5.0
	foreign-types-0.3.2
	windows_x86_64_gnullvm-0.42.2
	http-1.0.0
	url-2.5.0
	oboe-sys-0.5.0
	rfd-0.13.0
	rosc-0.10.1
	futures-io-0.3.30
	jni-0.19.0
	coreaudio-rs-0.11.3
	version_check-0.9.4
	windows_x86_64_gnu-0.42.2
	xshell-macros-0.2.5
	option-ext-0.2.0
	thiserror-impl-1.0.56
	ico-0.3.0
	codespan-reporting-0.11.1
	sysinfo-0.30.5
	xshell-0.2.5
	hashbrown-0.14.3
	redox_syscall-0.4.1
	toml_edit-0.21.0
	d3d12-0.19.0
	hyper-rustls-0.24.2
	spirv-0.3.0+sdk-1.3.268.0
	bytemuck-1.14.0
	heck-0.4.1
	proc-macro-crate-1.3.1
	bzip2-0.4.4
	pkg-config-0.3.29
	mach2-0.4.2
	clang-sys-1.7.0
	tokio-util-0.7.10
	clipboard-win-4.5.0
	percent-encoding-2.3.1
	async-lock-2.8.0
	ppv-lite86-0.2.17
	bincode-1.3.3
	objc-sys-0.3.2
	redox_users-0.4.4
	zerocopy-0.7.32
	windows-0.46.0
	aes-0.8.3
	polling-2.8.0
	security-framework-sys-2.9.1
	ndk-0.8.0
	openssl-0.10.63
	pbkdf2-0.11.0
	rand_distr-0.4.3
	version-compare-0.1.1
	dlib-0.5.2
	unicode-normalization-0.1.22
	winnow-0.5.34
	num_enum_derive-0.7.2
	pin-project-1.1.3
	metal-0.27.0
	async-trait-0.1.77
	core-graphics-types-0.1.3
	flate2-1.0.28
	android_system_properties-0.1.5
	gpu-alloc-0.6.0
	powerfmt-0.2.0
	exec-0.3.1
	wayland-client-0.31.1
	openssl-probe-0.1.5
	lazycell-1.3.0
	darling_macro-0.20.3
	rustix-0.38.30
	windows_aarch64_msvc-0.52.0
	zbus-3.14.1
	accesskit_winit-0.16.1
	regex-syntax-0.6.29
	unicode-width-0.1.11
	cexpr-0.6.0
	pathdiff-0.2.1
	wayland-protocols-0.31.0
	regex-automata-0.4.3
	glutin-winit-0.4.2
	gpu-alloc-types-0.3.0
	block-buffer-0.10.4
	wayland-backend-0.3.2
	atspi-common-0.3.0
	gloo-net-0.5.0
	objc_exception-0.1.2
	async-task-4.7.0
	http-body-0.4.6
	spin-0.9.8
	wasm-bindgen-0.2.90
	async-once-cell-0.5.3
	nalgebra-0.29.0
	bindgen-0.69.2
	gobject-sys-0.18.0
	proc-macro-crate-3.1.0
	ureq-2.9.1
	static_assertions-1.1.0
	futures-channel-0.3.30
	native-tls-0.2.11
	downcast-rs-1.2.0
	form_urlencoded-1.2.1
	eframe-0.25.0
	gtk-sys-0.18.0
	libredox-0.0.2
	calloop-0.12.4
	async-fs-1.6.0
	arboard-3.3.0
	rand_chacha-0.3.1
	itoa-1.0.10
	serde_json-1.0.111
	hermit-abi-0.3.4
	sharded-slab-0.1.7
	smol_str-0.2.1
	xcursor-0.3.5
	anstyle-1.0.4
	error-code-2.3.1
	num-complex-0.4.4
	simba-0.6.0
	signal-hook-registry-1.4.1
	tracing-attributes-0.1.27
	byteorder-1.5.0
	headers-core-0.2.0
	sct-0.7.1
	raw-window-handle-0.6.0
	unicode-bidi-0.3.15
	syn-2.0.48
	utf-8-0.7.6
	xml-rs-0.8.19
	async-executor-1.8.0
	widestring-1.0.2
	atspi-proxies-0.3.0
	redox_syscall-0.3.5
	rand-0.8.5
	once_cell-1.19.0
	objc-foundation-0.1.1
	constant_time_eq-0.1.5
	crossbeam-utils-0.8.19
	wgpu-hal-0.19.0
	glutin-0.31.2
	slab-0.4.9
	tinyvec_macros-0.1.1
	enumflags2_derive-0.7.8
"

inherit desktop cargo xdg

DESCRIPTION="ALVR is an open source remote VR display for the Oculus Go/Quest"
HOMEPAGE="https://github.com/alvr-org/ALVR"
SRC_URI="https://github.com/alvr-org/ALVR/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" $(cargo_crate_uris) "
#EGIT_REPO_URI="https://github.com/alvr-org/ALVR.git"
RESTRICT="network-sandbox" # Temp solution for bundled ffmpeg

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}/${P^^}"

RDEPEND="
	sys-libs/libunwind
"

DEPEND="${RDEPEND}"

BDEPEND="${RDEPEND}
	virtual/pkgconfig
	media-gfx/imagemagick
"

PATCHES=(
	"${FILESDIR}/xpath-dependencies-disaple-rpath.path"
)

S="${WORKDIR}/ALVR-${PV}"

src_unpack() {
	cargo_src_unpack

	# ALVR requires some dependencies not on crate.io (forks of other libraries)
	# so will just have to fetch them here.
	#
	# TODO: Figure out how to get these deps for offline mode.
	pushd "${S}"
	cargo -v --config "net.offline = false" fetch
	popd
}

src_configure() {
	local ECARGO_EXTRA_ARGS="
		-p alvr_vrcompositor_wrapper
		-p alvr_server
		-p alvr_dashboard
		-p alvr_vulkan_layer
	"
	cargo_gen_config
	cargo_src_configure
}

src_compile() {
	export ALVR_ROOT_DIR=/usr
	export ALVR_LIBRARIES_DIR="$ALVR_ROOT_DIR/$(get_libdir)/"

	export ALVR_OPENVR_DRIVER_ROOT_DIR="$ALVR_ROOT_DIR/lib/steamvr/alvr/"
	export ALVR_VRCOMPOSITOR_WRAPPER_DIR="$ALVR_ROOT_DIR/libexec/alvr/"

	PKG_CONFIG_PATH="${FILESDIR}" \
		cargo xtask prepare-deps --platform linux

	cargo_src_compile
}

src_install() {
	# vrcompositor wrapper
	exeinto /usr/libexec/alvr/
	newexe target/release/alvr_vrcompositor_wrapper vrcompositor-wrapper

	# OpenVR Driver
	exeinto /usr/lib/steamvr/alvr/bin/linux64/
	newexe target/release/libalvr_server.so driver_alvr_server.so

	insinto /usr/lib/steamvr/alvr/
	doins alvr/xtask/resources/driver.vrdrivermanifest

	# Vulkan layer
	dolib.so target/release/libalvr_vulkan_layer.so
	insinto /usr/share/vulkan/explicit_layer.d/
	doins alvr/vulkan_layer/layer/alvr_x86_64.json

	# Launcher
	dobin target/release/alvr_dashboard

	# Desktop
	domenu alvr/xtask/resources/alvr.desktop

	# Icons
	for size in {16,32,48,64,128,256}; do
		convert alvr/dashboard/resources/dashboard.ico \
			-thumbnail ${size} -alpha on -background none -flatten \
			${PN}-${size}.png || die
		newicon -s ${size} ${PN}-${size}.png ${PN}.png
	done

	# Firewall and SELinux
	insinto /etc/ufw/applications.d/
	doins alvr/xtask/firewall/ufw-alvr

	insinto /usr/lib/firewalld/services/
	doins alvr/xtask/firewall/alvr-firewalld.xml

	doexe alvr/xtask/firewall/alvr_fw_config.sh

	## Removed in 20.2.0
	# insinto /usr/share/alvr/selinux/
	# doins packaging/selinux/*
}
