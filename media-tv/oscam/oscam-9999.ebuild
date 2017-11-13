# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils systemd

#
# Just define the OSCAM_VCS="svn" environment variable in system make.conf
# if you want to pull from upstream subversion repository instead of git fork.
#
# You can also customize the respective REPO_URI there
#

if [ "${OSCAM_VCS}" == "svn" ] ; then
	inherit subversion
	ESVN_REPO_URI="${OSCAM_ESVN_REPO_URI:-http://streamboard.tv/svn/oscam/trunk}"
else
	inherit git-2
	EGIT_REPO_URI="${OSCAM_EGIT_REPO_URI:-git://github.com/gfto/oscam.git}"
fi

DESCRIPTION="OSCam is an Open Source Conditional Access Module software"
HOMEPAGE="www.streamboard.tv/wiki/OSCam/de/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

PROTOCOLS="camd33 camd35 camd35_tcp cccam cccshare constcw gbox ghttp newcamd pandora radegast serial"
for share in ${PROTOCOLS}; do
	IUSE_PROTOCOLS+=" +protocol_${share}"
done

READERS="bulcrypt conax cryptoworks dgcrypt dre griffin irdeto nagra seca tongfang viaccess videoguard"
for card in ${READERS}; do
	IUSE_READERS+=" +reader_${card}"
done

CARD_READERS="phoenix internal sc8in1 mp35 smargo smartreader db2com stapi"
for cardreader in ${CARD_READERS}; do
	IUSE_CARDREADERS+=" +cardreader_${cardreader}"
done

IUSE="${IUSE_PROTOCOLS} ${IUSE_READERS} ${IUSE_CARDREADERS}
	+anticasc cacheex cw_cycle_check debug +dvbapi ipv6 irdeto_guessing lcd led loadbalancing +monitor pcsc +reader +ssl touch usb +www"

REQUIRED_USE="
	protocol_camd35_tcp?	( protocol_camd35 )
	reader_nagra?		( reader )
	reader_irdeto?		( reader irdeto_guessing )
	reader_conax?		( reader )
	reader_cryptoworks?	( reader )
	reader_seca?		( reader )
	reader_viaccess?	( reader )
	reader_videoguard?	( reader )
	reader_dre?		( reader )
	reader_tongfang?	( reader )
	reader_bulcrypt?	( reader )
	reader_griffin?		( reader )
	reader_dgcrypt?		( reader )
	cardreader_db2com?	( reader )
	cardreader_internal?	( reader )
	cardreader_mp35?	( reader usb )
	cardreader_phoenix?	( reader usb )
	cardreader_sc8in1?	( reader usb )
	cardreader_smargo?	( reader usb )
	cardreader_smartreader?	( reader usb )
	cardreader_stapi?	( reader )
	pcsc?			( reader usb )
"

DEPEND="dev-util/cmake"
RDEPEND="${DEPEND}
	dev-libs/openssl
	usb? ( virtual/libusb:1
	       dev-libs/libusb-compat )
	pcsc? ( sys-apps/pcsc-lite )"

RESTRICT="mirror strip"

S="${WORKDIR}/${PN}"

src_prepare() {
	if [ "${OSCAM_VCS}" != "svn" ] ; then
		sed -i "s:svnversion -n .:git describe --always:" config.sh || die "Failed to patch the GIT commit as build string"
	fi

	sed -i "s:share/doc/oscam:share/doc/oscam-${PV}:" CMakeLists.txt || die "Failed to modify doc path"

	epatch_user
}

src_configure() {
	local mycmakeargs="
		-DCS_CONFDIR=/etc/oscam
		-DCMAKE_VERBOSE_MAKEFILE=ON
		-INCLUDED=Yes
		$(cmake-utils_use debug WITH_DEBUG)
		$(cmake-utils_use www WEBIF)
		$(cmake-utils_use touch TOUCH)
		$(cmake-utils_use dvbapi HAVE_DVBAPI)
		$(cmake-utils_use irdeto_guessing IRDETO_GUESSING)
		$(cmake-utils_use anticasc CS_ANTICASC)
		$(cmake-utils_use monitor MODULE_MONITOR)
		$(cmake-utils_use ssl WITH_SSL)
		$(cmake-utils_use loadbalancing WITH_LB)
		$(cmake-utils_use cacheex CS_CACHEEX)
		$(cmake-utils_use led LEDSUPPORT)
		$(cmake-utils_use lcd LCDSUPPORT)
		$(cmake-utils_use ipv6 IPV6SUPPORT)
		$(cmake-utils_use cw_cycle_check CW_CYCLE_CHECK)
		$(cmake-utils_use protocol_camd33 MODULE_CAMD33)
		$(cmake-utils_use protocol_camd35 MODULE_CAMD35)
		$(cmake-utils_use protocol_camd35_tcp MODULE_CAMD35_TCP)
		$(cmake-utils_use protocol_newcamd MODULE_NEWCAMD)
		$(cmake-utils_use protocol_cccam MODULE_CCCAM)
		$(cmake-utils_use protocol_cccshare MODULE_CCCSHARE)
		$(cmake-utils_use protocol_gbox MODULE_GBOX)
		$(cmake-utils_use protocol_radegast MODULE_RADEGAST)
		$(cmake-utils_use protocol_serial MODULE_SERIAL)
		$(cmake-utils_use protocol_constcw MODULE_CONSTCW)
		$(cmake-utils_use protocol_pandora MODULE_PANDORA)
		$(cmake-utils_use protocol_ghttp MODULE_GHTTP)
		$(cmake-utils_use reader WITH_CARDREADER)
		$(cmake-utils_use reader_nagra READER_NAGRA)
		$(cmake-utils_use reader_irdeto READER_IRDETO)
		$(cmake-utils_use reader_conax READER_CONAX)
		$(cmake-utils_use reader_cryptoworks READER_CRYPTOWORKS)
		$(cmake-utils_use reader_seca READER_SECA)
		$(cmake-utils_use reader_viaccess READER_VIACCESS)
		$(cmake-utils_use reader_videoguard READER_VIDEOGUARD)
		$(cmake-utils_use reader_dre READER_DRE)
		$(cmake-utils_use reader_tongfang READER_TONGFANG)
		$(cmake-utils_use reader_bulcrypt READER_BULCRYPT)
		$(cmake-utils_use reader_griffin READER_GRIFFIN)
		$(cmake-utils_use reader_dgcrypt READER_DGCRYPT)
		$(cmake-utils_use cardreader_phoenix CARDREADER_PHOENIX)
		$(cmake-utils_use cardreader_internal CARDREADER_INTERNAL)
		$(cmake-utils_use cardreader_sc8in1 CARDREADER_SC8IN1)
		$(cmake-utils_use cardreader_mp35 CARDREADER_MP35)
		$(cmake-utils_use cardreader_smargo CARDREADER_SMARGO)
		$(cmake-utils_use cardreader_smartreader CARDREADER_SMART)
		$(cmake-utils_use cardreader_db2com CARDREADER_DB2COM)
		$(cmake-utils_use cardreader_stapi CARDREADER_STAPI)
		"

		use usb && mycmakeargs="-DSTATIC_LIBUSB=0 ${mycmakeargs}"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use cardreader_smargo; then
		dobin "${WORKDIR}"/"${P}"_build/utils/list_smargo
	fi

	dobin "${FILESDIR}/oscam_watchdog.sh" || die "dobin oscam_watchdog.sh failed"

	insinto "/etc/${PN}"
	doins -r Distribution/doc/example/*
	fperms 0755 /etc/${PN} # ??? all executable ???

	systemd_dounit "${FILESDIR}/${PN}.service"

	newinitd "${FILESDIR}/${PN}.initd" oscam
	newconfd "${FILESDIR}/${PN}.confd" oscam

	keepdir "/var/log/${PN}/emm"
}

pkg_postinst() {
	einfo "Please refer to the wiki for assistance with the setup"
	einfo "located at http://www.streamboard.tv/wiki/OSCam/en"
}


