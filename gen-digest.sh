#!/usr/bin/env bash

EBUILDS_BASE_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

for E in $(find "${EBUILDS_BASE_DIRECTORY}" -iname "*.ebuild");
do
    ebuild ${E} digest
done
