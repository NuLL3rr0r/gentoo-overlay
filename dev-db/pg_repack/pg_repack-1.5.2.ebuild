# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

POSTGRES_COMPAT=( 13 14 15 16 17 )
POSTGRES_USEDEP="server"

inherit postgres-multi

DESCRIPTION="Reorganize tables in PostgreSQL databases with minimal locks"
HOMEPAGE="https://github.com/reorg/pg_repack"
SRC_URI="https://github.com/reorg/pg_repack/archive/ver_${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-ver_${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="${POSTGRES_DEP}"
RDEPEND="${DEPEND}"

# Needs a running PostgreSQL server
RESTRICT="test"
