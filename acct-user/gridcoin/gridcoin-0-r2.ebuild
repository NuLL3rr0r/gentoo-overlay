# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

ACCT_USER_ID=-1
ACCT_USER_GROUPS=( gridcoin )
ACCT_USER_HOME="/var/lib/${PN}"
ACCT_USER_HOME_PERMS=0750

DESCRIPTION="user for gridcoin daemon"
IUSE="boinc"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	boinc? ( acct-user/boinc )
"

acct-user_add_deps

pkg_setup() {
	use boinc && ACCT_USER_GROUPS+=( boinc )
}
