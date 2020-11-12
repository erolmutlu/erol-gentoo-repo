# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Spotify adblocker for linux"
HOMEPAGE="https://github.com/abba23/spotify-adblock-linux"

inherit git-r3
EGIT_REPO_URI="https://github.com/abba23/spotify-adblock-linux"

RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="
	net-misc/curl"

DEPEND="${RDEPEND}"

src_install() {
	dolib spotify-adblock.so
	dodoc README.md
}

pkg_postinst() {
	ewarn "To use this, you should open spotify with:"
	ewarn "LD_PRELOAD=/usr/lib64/spotify-adblock.so spotify"
	ewarn ""
	ewarn "Be aware that you can get banned from spotify for evading ads"
}
