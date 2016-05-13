# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2 cmake-utils

EGIT_REPO_URI="https://github.com/kodi-pvr/pvr.iptvsimple"
EGIT_BRANCH="Jarvis"

DESCRIPTION="IPTV Live TV and Radio PVR client addon for Kodi"
HOMEPAGE="https://github.com/kodi-pvr/pvr.iptvsimple"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="media-libs/kodi-platform"
RDEPEND="${DEPEND}"

src_configure() {
        local mycmakeargs=(
                -DCMAKE_INSTALL_LIBDIR="${EPREFIX}"/usr/lib/kodi
        )

        cmake-utils_src_configure
}
