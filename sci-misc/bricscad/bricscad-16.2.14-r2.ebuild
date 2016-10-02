# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils pax-utils systemd unpacker user

DESCRIPTION="BricsCAD® offers all the familiar .dwg 2D CAD features,
yet it adds time saving tools and 3D Direct Modeling.
With BricsCAD you get more for less."
HOMEPAGE="https://www.bricsys.com/"

BINPACK="BricsCAD-V16.2.14-2-en_US-amd64.deb"

SRC_URI="
	amd64? (
		https://github.com/erolmutlu/erol-gentoo-repo/raw/master/distfiles/${BINPACK}
	)
"

LICENSE="evaluation, comercial"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
	${DEPEND}
"

S="${WORKDIR}"

RESTRICT="mirror preserve-libs"
QA_PREBUILT="*"

pkg_setup() {
	einfo "You decided emerge bricscad, binary package into your system."
	einfo "At first, plz register, fill form, and fetch ${BINPACK}"
	einfo "from ${HOMEPAGE}"
	einfo "Then move ${BINPACK} to your ${DISTDIR}"
}

src_prepare() {
	default
}

src_install() {
	# package contents
	# insinto /etc/default
	# doins etc/default/plexmediaserver

	dodir /opt/bricsys/bricscad/v16
	cp -R opt/bricsys/bricscad/v16/* "${D}"/opt/bricsys/bricscad/v16/

	#if use pax_kernel; then
	#	pax-mark m "${D}"/opt/plexmediaserver/Plex\ Media\ Server
	#	pax-mark m "${D}"/opt/plexmediaserver/Plex\ Media\ Scanner
	#	pax-mark m "${D}"/opt/plexmediaserver/Plex\ DLNA\ Server
	#	pax-mark m "${D}"/opt/plexmediaserver/Plex\ Script\ Host
	#	pax-mark m "${D}"/opt/plexmediaserver/Plex\ Relay
	#	pax-mark m "${D}"/opt/plexmediaserver/libcrypto.so.1.0.0
	#	pax-mark m "${D}"/opt/plexmediaserver/libgnsdk_dsp.so.3.07.7
	#fi

	dobin usr/bin/bricscadv16

	domenu usr/share/applications/bricscadv16.desktop
	doicon usr/share/pixmaps/bricscadv16.png

	#dodoc usr/share/doc/plexmediaserver/copyright

	# init files
	#doinitd "${FILESDIR}"/plexmediaserver

	#if use systemd; then
	#	systemd_dounit "${FILESDIR}"/plexmediaserver.service
	#fi

	# directories
	dodir /var/bricsys
	fowners root:root /var/bricsys
	dodir /var/log/bricsys
	fowners root:root /var/log/bricsys
}

pkg_postinst() {
	einfo "To start BricsCad use menu or from console direct type "bricscadv16"."
	einfo "."
}

