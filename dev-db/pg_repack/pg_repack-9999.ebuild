# Copyright 1999-2024-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/reorg/${PN}.git"

POSTGRES_COMPAT=( 9.6 10 11 12 13 14 15 )
POSTGRES_USEDEP="server"

inherit git-r3 postgres-multi

DESCRIPTION="Reorganize tables in PostgreSQL databases with minimal locks"
HOMEPAGE="https://github.com/reorg/pg_repack"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="${POSTGRES_DEP}"
RDEPEND="${DEPEND}"

# Needs a running PostgreSQL server
RESTRICT="test"
