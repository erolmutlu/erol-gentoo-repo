# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

ESVN_REPO_URI="http://dolphin-emu.googlecode.com/svn/trunk/"

inherit eutils games subversion

DESCRIPTION="Gamecube and Wii emulator"
HOMEPAGE="http://dolphin-emu.com"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="docs lzo openal sfml"

RDEPEND="x11-libs/wxGTK:2.8
	media-gfx/nvidia-cg-toolkit
	media-libs/portaudio
	games-util/wiiuse
	virtual/opengl
	virtual/glu
	lzo? ( dev-libs/lzo )
	openal? ( =media-libs/openal-1* )
	sfml? ( media-libs/libsfml )"
DEPEND="${RDEPEND} 
        dev-util/scons
	dev-util/pkgconfig"

S=${WORKDIR}

SCONSOPTS=""

src_configure() {
	SCONSOPTS=$(echo "${MAKEOPTS}" | sed -ne "/-j/ { s/.*\(-j[[:space:]]*[0-9]\+\).*/\1/; p }")
	use lzo && SCONSOPTS="${SCONSOPTS} shared_lzo=yes"
        use openal && SCONSOPTS="${SCONSOPTS} openal=yes"
        use sfml && SCONSOPTS="${SCONSOPTS} shared_sfml=yes"
}

src_compile() {
	scons \
		install=global \
		prefix=${GAMES_PREFIX} \
		destdir=${D} \
		${SCONSOPTS} || die "scons failed"
}

src_install() {
	scons ${SCONSOPTS} install || die "scons install failed"
	if use docs; then
		insinto ${GAMES_DATADIR}/${PN}
		doins -r docs/*
	fi	
	doicon ${FILESDIR}/Dolphin.png
	make_desktop_entry dolphin-emu "Dolphin Emulator" Dolphin
	prepgamesdirs
}
