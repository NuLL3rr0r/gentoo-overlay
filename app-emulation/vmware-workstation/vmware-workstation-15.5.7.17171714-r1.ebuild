# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
inherit eutils readme.gentoo-r1 gnome2-utils pam python-any-r1 systemd xdg-utils

MY_PN="VMware-Workstation-Full"
MY_PV=$(ver_cut 1-3)
PV_MODULES="${MY_PV}"
PV_BUILD=$(ver_cut 4)
MY_P="${MY_PN}-${MY_PV}-${PV_BUILD}"
VMWARE_FUSION_VER="11.5.7/17130923" # https://softwareupdate.vmware.com/cds/vmw-desktop/fusion/
SYSTEMD_UNITS_TAG="gentoo-02"
UNLOCKER_VERSION="3.0.3"

DESCRIPTION="Emulate a complete PC without the performance overhead of most emulators"
HOMEPAGE="http://www.vmware.com/products/workstation/"
SRC_URI="
	https://download3.vmware.com/software/wkst/file/${MY_P}.x86_64.bundle
	macos-guests? (
		https://github.com/paolo-projects/unlocker/archive/${UNLOCKER_VERSION}.tar.gz -> unlocker-${UNLOCKER_VERSION}.tar.gz
		vmware-tools-darwinPre15? ( https://softwareupdate.vmware.com/cds/vmw-desktop/fusion/${VMWARE_FUSION_VER}/core/com.vmware.fusion.zip.tar -> com.vmware.fusion-${PV}.zip.tar )
		vmware-tools-darwin? ( https://softwareupdate.vmware.com/cds/vmw-desktop/fusion/${VMWARE_FUSION_VER}/core/com.vmware.fusion.zip.tar -> com.vmware.fusion-${PV}.zip.tar )
	)
	systemd? ( https://github.com/akhuettel/systemd-vmware/archive/${SYSTEMD_UNITS_TAG}.tar.gz -> vmware-systemd-${SYSTEMD_UNITS_TAG}.tgz )
	"

LICENSE="GPL-2 GPL-3 MIT-with-advertising vmware"
SLOT="0"
KEYWORDS="~amd64"
# the kernel modules are optional because they're not needed to connect to VMs
# running on remote systems - https://bugs.gentoo.org/604426
IUSE="cups doc macos-guests +modules ovftool systemd vix"
DARWIN_GUESTS="darwin darwinPre15"
IUSE_VMWARE_GUESTS="${DARWIN_GUESTS} linux linuxPreGlibc25 netware solaris windows winPre2k winPreVista"
for guest in ${IUSE_VMWARE_GUESTS}; do
	IUSE+=" vmware-tools-${guest}"
done
REQUIRED_USE="
	vmware-tools-darwin? ( macos-guests )
	vmware-tools-darwinPre15? ( macos-guests )
"
RESTRICT="mirror preserve-libs strip"

# vmware should not use virtual/libc as this is a
# precompiled binary package thats linked to glibc.
RDEPEND="
	app-arch/bzip2
	app-arch/unzip
	app-shells/bash
	dev-db/sqlite:3
	dev-libs/dbus-glib
	dev-libs/gmp:0
	dev-libs/icu
	dev-libs/json-c
	dev-libs/nettle:0
	gnome-base/dconf
	gnome-base/gconf
	gnome-base/libgnome-keyring
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/libart_lgpl
	media-libs/libvorbis
	media-libs/mesa
	media-plugins/alsa-plugins[speex]
	net-dns/libidn
	net-libs/gnutls
	cups? ( net-print/cups )
	sys-apps/tcp-wrappers
	sys-apps/util-linux
	x11-libs/libXxf86vm
	x11-libs/libdrm
	x11-libs/libxshmfence
	x11-libs/startup-notification
	x11-libs/xcb-util
	x11-themes/hicolor-icon-theme
	!app-emulation/vmware-player
	!app-emulation/vmware-tools
"
DEPEND="
	${PYTHON_DEPS}
	>=dev-util/patchelf-0.9
	modules? ( ~app-emulation/vmware-modules-${PV_MODULES} )
	ovftool? ( app-admin/chrpath )
"

S=${WORKDIR}/extracted
VM_INSTALL_DIR="/opt/vmware"
VM_DATA_STORE_DIR="/var/lib/vmware/Shared VMs"
VM_HOSTD_USER="root"

QA_PREBUILT="/opt/*"

QA_WX_LOAD="opt/vmware/lib/vmware/tools-upgraders/vmware-tools-upgrader-32 opt/vmware/lib/vmware/bin/vmware-vmx-stats opt/vmware/lib/vmware/bin/vmware-vmx-debug opt/vmware/lib/vmware/bin/vmware-vmx"
# adding "opt/vmware/lib/vmware/lib/libvmware-gksu.so/libvmware-gksu.so" to QA_WX_LOAD doesn't work

src_unpack() {
	if has usersandbox ${FEATURES}; then
		ewarn "You are emerging ${P} with 'usersandbox' enabled." \
			"If unpacking fails, try emerging with 'FEATURES=-usersandbox'!"
	fi

	for a in ${A}; do
		if [ ${a##*.} == 'bundle' ]; then
			cp "${DISTDIR}/${a}" "${WORKDIR}"
		else
			unpack ${a}
		fi
	done

	export LC_ALL=C # https://communities.vmware.com/thread/618570?start=15&tstart=0
	local bundle="${MY_P}.x86_64.bundle"
	chmod 755 "${bundle}"
	# this needs a /tmp mounted without "noexec" because it extracts and executes scripts in there
	./${bundle} --console --required --eulas-agreed --extract=extracted || die "unable to extract bundle"

	if ! use vix; then
		rm -r extracted/vmware-vix-core extracted/vmware-vix-lib-Workstation* || die "unable to remove dir"
	fi

	if use vmware-tools-darwinPre15 || use vmware-tools-darwin; then
		unzip -q com.vmware.fusion.zip || die
		for guest in ${DARWIN_GUESTS}; do
			if use vmware-tools-${guest}; then
				mkdir extracted/vmware-tools-${guest}
				mv "payload/VMware Fusion.app/Contents/Library/isoimages/${guest}.iso" extracted/vmware-tools-${guest}/ || die
			fi
		done
		rm -rf __MACOSX payload manifest.plist preflight postflight com.vmware.fusion.zip
	fi
}

src_prepare() {
	default

	rm -f */bin/vmware-modconfig
	rm -rf */lib/modules/binary
	# Bug 459566
	mkdir vmware-network-editor/lib/lib
	mv vmware-network-editor/lib/libvmware-netcfg.so vmware-network-editor/lib/lib/

	rm -f vmware-workstation-server/bin/{openssl,configure-hostd.sh}

	if use ovftool; then
		chrpath -d vmware-ovftool/libcurl.so.4
	fi

	if use macos-guests; then
		sed -i -e "s#vmx_path = '/usr#vmx_path = '${ED}${VM_INSTALL_DIR//\//\\/}#" \
			-e "s#os\.path\.isfile('/usr#os.path.isfile('${ED}${VM_INSTALL_DIR//\//\\/}#" \
			-e "s#vmwarebase = '/usr#vmwarebase = '${ED}${VM_INSTALL_DIR//\//\\/}#" \
			"${WORKDIR}"/unlocker-*/unlocker.py
	fi

	DOC_CONTENTS="
/etc/env.d is updated during ${PN} installation. Please run:\n
'env-update && source /etc/profile'\n
Before you can use ${PN}, you must configure a default network setup.
You can do this by running 'emerge --config ${PN}'.\n
To be able to run ${PN} your user must be in the vmware group."
}

src_install() {
	local major_minor=$(ver_cut 1-2 "${PV}")
	local vmware_installer_version=$(cat "${S}/vmware-installer/manifest.xml" | grep -oPm1 "(?<=<version>)[^<]+")

	# revdep-rebuild entry
	insinto /etc/revdep-rebuild
	echo "SEARCH_DIRS_MASK=\"${VM_INSTALL_DIR}\"" >> ${T}/10${PN}
	doins "${T}"/10${PN}

	# install the binaries
	into "${VM_INSTALL_DIR}"
	dobin */bin/*
	dosbin */sbin/*
	rm "${ED}${VM_INSTALL_DIR}"/bin/configure-initscript.sh
	mv "${ED}${VM_INSTALL_DIR}"/sbin/vmware-authdlauncher "${ED}${VM_INSTALL_DIR}"/sbin/vmware-authdlauncher.bin
	cat > "${ED}${VM_INSTALL_DIR}"/sbin/vmware-authdlauncher <<-EOF
		#!/usr/bin/env bash
		export LD_LIBRARY_PATH="/opt/vmware/lib/vmware/lib/libssl.so.1.0.2:/opt/vmware/lib/vmware/lib/libcrypto.so.1.0.2"
		"${VM_INSTALL_DIR}"/sbin/vmware-authdlauncher.bin "\$@"
	EOF
	chmod 755 "${ED}${VM_INSTALL_DIR}"/sbin/vmware-authdlauncher

	# install the libraries
	insinto "${VM_INSTALL_DIR}"/lib/vmware
	doins -r */lib/* vmware-vmx/roms
	rm -rf "${ED}${VM_INSTALL_DIR}"/lib/vmware/*.so

	# install the installer
	insinto "${VM_INSTALL_DIR}"/lib/vmware-installer/${vmware_installer_version}
	doins -r vmware-installer/{cdsHelper,vmis,vmis-launcher,vmware-cds-helper,vmware-installer,vmware-installer.py}
	fperms 0755 "${VM_INSTALL_DIR}"/lib/vmware-installer/${vmware_installer_version}/{vmis-launcher,cdsHelper,vmware-installer}
	dosym "${VM_INSTALL_DIR}"/lib/vmware-installer/${vmware_installer_version}/vmware-installer "${VM_INSTALL_DIR}"/bin/vmware-installer
	insinto /etc/vmware-installer
	doins vmware-installer/bootstrap
	sed -i \
		-e "s/@@VERSION@@/${vmware_installer_version}/" \
		-e "s,@@VMWARE_INSTALLER@@,${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}," \
		"${ED}/etc/vmware-installer/bootstrap"

	# install the ancillaries
	insinto /usr
	doins -r */share

	if use cups; then
		exeinto $(cups-config --serverbin)/filter
		doexe */extras/thnucups

		insinto /etc/cups
		doins -r */etc/cups/*
	fi

	# Hardcoded EULA path. We need to disable the default compression.
	insinto /usr/share/doc/vmware-workstation
	doins vmware-workstation/doc/EULA
	docompress -x /usr/share/doc/vmware-workstation
	# always needed
	insinto /usr/lib/vmware-ovftool
	doins vmware-ovftool/vmware.eula

	if use doc; then
		dodoc -r */doc/*
	fi

	exeinto "${VM_INSTALL_DIR}"/lib/vmware/setup
	doexe */vmware-config

	# pam
	pamd_mimic_system vmware-authd auth account

	# fuse
	insinto /etc/modprobe.d
	newins vmware-vmx/etc/modprobe.d/modprobe-vmware-fuse.conf vmware-fuse.conf

	# install vmware workstation server
	cd "${S}"/vmware-workstation-server

	# install the libraries
	insinto "${VM_INSTALL_DIR}"/lib/vmware/lib
	doins -r lib/*

	into "${VM_INSTALL_DIR}"
	for tool in vmware-hostd wssc-adminTool ; do
		cat > "${T}/${tool}" <<-EOF
			#!/usr/bin/env bash
			set -e

			. /etc/vmware/bootstrap

			exec "${VM_INSTALL_DIR}/lib/vmware/bin/${tool}" \\
				"\$@"
		EOF
		dobin "${T}/${tool}"
	done

	insinto "${VM_INSTALL_DIR}"/lib/vmware
	doins -r hostd

	# create the configuration
	insinto /etc/vmware
	doins -r config/etc/vmware/*
	doins -r etc/vmware/*

	# create directory for shared virtual machines.
	keepdir "${VM_DATA_STORE_DIR}"
	keepdir /var/log/vmware

	cd - >/dev/null

	# install vmware-vix
	if use vix; then
		# install the binary
		into "${VM_INSTALL_DIR}"
		dobin "$S"/vmware-vix-*/bin/*

		# install the libraries
		insinto "${VM_INSTALL_DIR}"/lib/vmware-vix
		doins -r "$S"/vmware-vix-*/lib/*

		dosym vmware-vix/libvixAllProducts.so "${VM_INSTALL_DIR}"/lib/libbvixAllProducts.so

		# install headers
		insinto /usr/include/vmware-vix
		doins "$S"/vmware-vix-*/include/*

		if use doc; then
			dodoc -r "$S"/vmware-vix-*/doc/*
		fi
	fi

	# install ovftool
	if use ovftool; then
		cd "${S}"/vmware-ovftool

		insinto "${VM_INSTALL_DIR}"/lib/vmware-ovftool
		doins -r *

		chmod 0755 "${ED}${VM_INSTALL_DIR}"/lib/vmware-ovftool/{ovftool,ovftool.bin}
		sed -i 's/readlink/readlink -f/' "${ED}${VM_INSTALL_DIR}"/lib/vmware-ovftool/ovftool
		dosym ../lib/vmware-ovftool/ovftool "${VM_INSTALL_DIR}"/bin/ovftool

		cd - >/dev/null
	fi

	# create symlinks for the various tools
	local tool;
	for tool in thnuclnt vmware vmplayer{,-daemon} licenseTool vmamqpd \
			vmware-{app-control,enter-serial,gksu,fuseUI,hostd,modconfig{,-console},netcfg,setup-helper,tray,unity-helper,vim-cmd,vmblock-fuse,vprobe,wssc-adminTool,zenity}; do
		dosym appLoader "${VM_INSTALL_DIR}"/lib/vmware/bin/"${tool}"
	done
	dosym "${VM_INSTALL_DIR}"/lib/vmware/bin/vmplayer "${VM_INSTALL_DIR}"/bin/vmplayer
	dosym "${VM_INSTALL_DIR}"/lib/vmware/bin/vmware "${VM_INSTALL_DIR}"/bin/vmware
	dosym "${VM_INSTALL_DIR}"/lib/vmware/bin/vmware-fuseUI "${VM_INSTALL_DIR}"/bin/vmware-fuseUI
	dosym "${VM_INSTALL_DIR}"/lib/vmware/bin/vmware-netcfg "${VM_INSTALL_DIR}"/bin/vmware-netcfg
	dosym "${VM_INSTALL_DIR}"/lib/vmware/icu /etc/vmware/icu

	# fix permissions
	fperms 0755 "${VM_INSTALL_DIR}"/lib/vmware/bin/{appLoader,fusermount,mkisofs,vmware-remotemks}
	fperms 0755 "${VM_INSTALL_DIR}"/lib/vmware/setup/vmware-config
	fperms 4711 "${VM_INSTALL_DIR}"/lib/vmware/bin/vmware-vmx{,-debug,-stats}
	fperms 0755 "${VM_INSTALL_DIR}"/lib/vmware/lib/libvmware-gksu.so/gksu-run-helper
	fperms 4711 "${VM_INSTALL_DIR}"/sbin/vmware-authd
	fperms 0755 "${VM_INSTALL_DIR}"/bin/{vmware-hostd,wssc-adminTool}
	fperms 1777 "${VM_DATA_STORE_DIR}"
	if use vix; then
		fperms 0755 "${VM_INSTALL_DIR}"/lib/vmware-vix/setup/vmware-config
	fi

	# create the environment
	local envd="${T}/90vmware"
	cat > "${envd}" <<-EOF
		PATH='${VM_INSTALL_DIR}/bin:${VM_INSTALL_DIR}/sbin'
		ROOTPATH='${VM_INSTALL_DIR}/bin'
		CONFIG_PROTECT_MASK='/etc/vmware-installer'
		VMWARE_USE_SHIPPED_LIBS=1
	EOF

	doenvd "${envd}"

	# create the configuration
	dodir /etc/vmware

	cat > "${ED}"/etc/vmware/bootstrap <<-EOF
		BINDIR='${VM_INSTALL_DIR}/bin'
		LIBDIR='${VM_INSTALL_DIR}/lib'
	EOF

	cat > "${ED}"/etc/vmware/config <<-EOF
		.encoding = "UTF-8"
		bindir = "${VM_INSTALL_DIR}/bin"
		libdir = "${VM_INSTALL_DIR}/lib/vmware"
		initscriptdir = "/etc/init.d"
		authd.fullpath = "${VM_INSTALL_DIR}/sbin/vmware-authd"
		gksu.rootMethod = "su"
		VMCI_CONFED = "no"
		VMBLOCK_CONFED = "no"
		VSOCK_CONFED = "no"
		NETWORKING = "yes"
		player.product.version = "${MY_PV}"
		product.buildNumber = "${PV_BUILD}"
		product.version = "${MY_PV}"
		product.name = "VMware Workstation"
		workstation.product.version = "${MY_PV}"
		vmware.fullpath = "${VM_INSTALL_DIR}/bin/vmware"
		installerDefaults.componentDownloadEnabled = "no"
		installerDefaults.autoSoftwareUpdateEnabled.epoch = "4641104763"
		installerDefaults.dataCollectionEnabled.epoch = "7910652514"
		installerDefaults.dataCollectionEnabled = "no"
		installerDefaults.transferVersion = "1"
		installerDefaults.autoSoftwareUpdateEnabled = "no"
		acceptEULA = "yes"
		acceptOVFEULA = "yes"
	EOF

	if use vix; then
		cat >> "${ED}"/etc/vmware/config <<-EOF
			vix.libdir = "${VM_INSTALL_DIR}/lib/vmware-vix"
			vix.config.version = "1"
		EOF
	fi

	cat >> "${ED}"/etc/vmware/config <<-EOF
		authd.client.port = "902"
		authd.proxy.nfc = "vmware-hostd:ha-nfc"
		authd.soapserver = "TRUE"
	EOF

	if use modules; then
		# install the init.d script
		local initscript="${T}/vmware.rc"
		sed -e "s:@@BINDIR@@:${VM_INSTALL_DIR}/bin:g" \
			"${FILESDIR}/vmware-${major_minor}.rc" > "${initscript}" || die
		newinitd "${initscript}" vmware
	fi

	# install the init.d script
	local initscript="${T}/vmware-workstation-server.rc"
	sed -e "s:@@ETCDIR@@:/etc/vmware:g" \
		-e "s:@@PREFIX@@:${VM_INSTALL_DIR}:g" \
		-e "s:@@BINDIR@@:${VM_INSTALL_DIR}/bin:g" \
		-e "s:@@LIBDIR@@:${VM_INSTALL_DIR}/lib/vmware:g" \
		"${FILESDIR}/vmware-server-${major_minor}.rc" > ${initscript} || die
	newinitd "${initscript}" vmware-workstation-server

	# fill in variable placeholders
	sed -e "s:@@LIBCONF_DIR@@:${VM_INSTALL_DIR}/lib/vmware/libconf:g" \
		-i "${ED}${VM_INSTALL_DIR}"/lib/vmware/libconf/etc/gtk-3.0/gdk-pixbuf.loaders || die
	sed -e "s:@@BINARY@@:${EPREFIX}${VM_INSTALL_DIR}/bin/vmplayer:g" \
		-e "/^Encoding/d" \
		-i "${ED}/usr/share/applications/vmware-player.desktop" || die
	sed -e "s:@@BINARY@@:${EPREFIX}${VM_INSTALL_DIR}/bin/vmware:g" \
		-e "/^Encoding/d" \
		-i "${ED}/usr/share/applications/vmware-workstation.desktop" || die
	sed -e "s:@@BINARY@@:${EPREFIX}${VM_INSTALL_DIR}/bin/vmware-netcfg:g" \
		-e "/^Encoding/d" \
		-i "${ED}/usr/share/applications/vmware-netcfg.desktop" || die

	# Configuration for vmware-workstation-server
	local hostdUser="${VM_HOSTD_USER:-root}"
	sed -e "/ACEDataUser/s:root:${hostdUser}:g" \
		-i "${ED}/etc/vmware/hostd/authorization.xml" || die

	# Shared VMs Path: [standard].
	sed -e "s:##{DS_NAME}##:standard:g" \
		-e "s:##{DS_PATH}##:${VM_DATA_STORE_DIR}:g" \
		-i "${ED}/etc/vmware/hostd/datastores.xml" || die

	sed -e "s:##{HTTP_PORT}##:-1:g" \
		-e "s:##{HTTPS_PORT}##:443:g" \
		-e "s:##{PIPE_PREFIX}##:/var/run/vmware/:g" \
		-i "${ED}/etc/vmware/hostd/proxy.xml" || die

	# See vmware-workstation-server.py for more details.
	sed -e "s:##{BUILD_CFGDIR}##:/etc/vmware/hostd/:g" \
		-e "s:##{CFGALTDIR}##:/etc/vmware/hostd/:g" \
		-e "s:##{CFGDIR}##:/etc/vmware/:g" \
		-e "s:##{ENABLE_AUTH}##:true:g" \
		-e "s:##{HOSTDMODE}##:ws:g" \
		-e "s:##{HOSTD_CFGDIR}##:/etc/vmware/hostd/:g" \
		-e "s:##{HOSTD_MOCKUP}##:false:g" \
		-e "s:##{LIBDIR}##:${VM_INSTALL_DIR}/lib/vmware:g" \
		-e "s:##{LIBDIR_INSTALLED}##:${VM_INSTALL_DIR}/lib/vmware/:g" \
		-e "s:##{LOGDIR}##:/var/log/vmware/:g" \
		-e "s:##{LOGLEVEL}##:verbose:g" \
		-e "s:##{MOCKUP}##:mockup-host-config.xml:g" \
		-e "s:##{PLUGINDIR}##:./:g" \
		-e "s:##{SHLIB_PREFIX}##:lib:g" \
		-e "s:##{SHLIB_SUFFIX}##:.so:g" \
		-e "s:##{USE_BLKLISTSVC}##:false:g" \
		-e "s:##{USE_CBRCSVC}##:false:g" \
		-e "s:##{USE_CIMSVC}##:false:g" \
		-e "s:##{USE_DIRECTORYSVC}##:false:g" \
		-e "s:##{USE_DIRECTORYSVC_MOCKUP}##:false:g" \
		-e "s:##{USE_DYNAMIC_PLUGIN_LOADING}##:false:g" \
		-e "s:##{USE_DYNAMO}##:false:g" \
		-e "s:##{USE_DYNSVC}##:false:g" \
		-e "s:##{USE_GUESTSVC}##:false:g" \
		-e "s:##{USE_HBRSVC}##:false:g" \
		-e "s:##{USE_HBRSVC_MOCKUP}##:false:g" \
		-e "s:##{USE_HOSTSPECSVC}##:false:g" \
		-e "s:##{USE_HOSTSVC_MOCKUP}##:false:g" \
		-e "s:##{USE_HTTPNFCSVC}##:false:g" \
		-e "s:##{USE_HTTPNFCSVC_MOCKUP}##:false:g" \
		-e "s:##{USE_LICENSESVC_MOCKUP}##:false:g" \
		-e "s:##{USE_NFCSVC}##:true:g" \
		-e "s:##{USE_NFCSVC_MOCKUP}##:false:g" \
		-e "s:##{USE_OVFMGRSVC}##:true:g" \
		-e "s:##{USE_PARTITIONSVC}##:false:g" \
		-e "s:##{USE_SECURESOAP}##:false:g" \
		-e "s:##{USE_SNMPSVC}##:false:g" \
		-e "s:##{USE_SOLO_MOCKUP}##:false:g" \
		-e "s:##{USE_STATSSVC}##:false:g" \
		-e "s:##{USE_STATSSVC_MOCKUP}##:false:g" \
		-e "s:##{USE_VCSVC_MOCKUP}##:false:g" \
		-e "s:##{USE_VSLMSVC}##:false:g" \
		-e "s:##{USE_VSLMSVC_MOCKUP}##:false:g" \
		-e "s:##{USE_VDISKSVC}##:false:g" \
		-e "s:##{USE_VDISKSVC_MOCKUP}##:false:g" \
		-e "s:##{USE_VMSVC_MOCKUP}##:false:g" \
		-e "s:##{VM_INVENTORY}##:vmInventory.xml:g" \
		-e "s:##{VM_RESOURCES}##:vmResources.xml:g" \
		-e "s:##{WEBSERVER_PORT_ENTRY}##::g" \
		-e "s:##{WORKINGDIR}##:./:g" \
		-i "${ED}/etc/vmware/hostd/config.xml" || die

	sed -e "s:##{ENV_LOCATION}##:/etc/vmware/hostd/env/:g" \
		-i "${ED}/etc/vmware/hostd/environments.xml" || die

	# @@VICLIENT_URL@@=XXX
	sed -e "s:@@AUTHD_PORT@@:902:g" \
		-i "${ED}${VM_INSTALL_DIR}/lib/vmware/hostd/docroot/client/clients.xml" || die

	# install systemd unit files
	if use systemd; then
		systemd_dounit "${WORKDIR}/systemd-vmware-${SYSTEMD_UNITS_TAG}/"*.{service,target}
	fi

	# enable macOS guests support
	if use macos-guests; then
		python3 "${WORKDIR}"/unlocker-*/unlocker.py >/dev/null || die "unlocker.py failed"
	fi

	# VMware tools
	for guest in ${IUSE_VMWARE_GUESTS}; do
		if use vmware-tools-${guest}; then
			local dbfile="${ED}/etc/vmware-installer/database"
			if ! [ -e "${dbfile}" ]; then
				> "${dbfile}"
				sqlite3 "${dbfile}" "CREATE TABLE settings(key VARCHAR PRIMARY KEY, value VARCHAR NOT NULL, component_name VARCHAR NOT NULL);"
				sqlite3 "${dbfile}" "INSERT INTO settings(key,value,component_name) VALUES('db.schemaVersion','2','vmware-installer');"
				sqlite3 "${dbfile}" "CREATE TABLE components(id INTEGER PRIMARY KEY, name VARCHAR NOT NULL, version VARCHAR NOT NULL, buildNumber INTEGER NOT NULL, component_core_id INTEGER NOT NULL, longName VARCHAR NOT NULL, description VARCHAR, type INTEGER NOT NULL);"
			fi
			local manifest="vmware-tools-${guest}/manifest.xml"
			if [ -e "${manifest}" ]; then
				local version="$(grep -oPm1 '(?<=<version>)[^<]+' ${manifest})"
				sqlite3 "${dbfile}" "INSERT INTO components(name,version,buildNumber,component_core_id,longName,description,type) VALUES(\"vmware-tools-$guest\",\"$version\",\"${PV_BUILD}\",1,\"$guest\",\"$guest\",1);"
			else
				sqlite3 "${dbfile}" "INSERT INTO components(name,version,buildNumber,component_core_id,longName,description,type) VALUES(\"vmware-tools-$guest\",\"${VMWARE_FUSION_VER%/*}\",\"${VMWARE_FUSION_VER#*/}\",1,\"$guest\",\"$guest\",1);"
			fi
			insinto "${VM_INSTALL_DIR}/lib/vmware/isoimages"
			doins vmware-tools-${guest}/${guest}.iso
		fi
	done

	readme.gentoo_create_doc
}

pkg_config() {
	"${VM_INSTALL_DIR}"/bin/vmware-networks --postinstall ${PN},old,new
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
	elog "${DOC_CONTENTS}"
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}
