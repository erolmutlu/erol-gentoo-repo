# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils versionator

# NetworkManager likes itself with capital letters
MY_P=${P/networkmanager/NetworkManager}
MYPV_MINOR=$(get_version_component_range 1-2)

DESCRIPTION="NetworkManager StrongSwan plugin."
HOMEPAGE="http://www.strongswan.org/"
SRC_URI="https://github.com/erolmutlu/erol-gentoo-repo/raw/master/distfiles/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm ~amd64 ~ppc ~x86"
IUSE=""

RDEPEND="
>=net-misc/networkmanager-1.2
>=net-misc/strongswan-5.5.0[networkmanager]"

DEPEND="${RDEPEND}
dev-util/intltool
dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}

src_prepare() {

./autogen.sh
#epatch "${FILESDIR}/${PN}-0001.patch"
#epatch "${FILESDIR}/${PN}-0002.patch"
#epatch "${FILESDIR}/${PN}-0003.patch"
#epatch "${FILESDIR}/${PN}-0004.patch"
#epatch "${FILESDIR}/${PN}-0005.patch"
#epatch "${FILESDIR}/${PN}-0006.patch"
#epatch "${FILESDIR}/${PN}-0007.patch"
#epatch "${FILESDIR}/${PN}-0008.patch"
#epatch "${FILESDIR}/${PN}-0009.patch"
#epatch "${FILESDIR}/${PN}-0010.patch"
#epatch "${FILESDIR}/${PN}-0011.patch"
#epatch "${FILESDIR}/${PN}-0012.patch"
#epatch "${FILESDIR}/${PN}-0013.patch"
#epatch "${FILESDIR}/${PN}-0014.patch"

}

src_configure() {
ECONF="--sysconfdir=/etc --prefix=/usr --libexecdir=/usr/libexec --with-charon=/usr/libexec/strongswan/charon-nm"

econf ${ECONF}
}

src_install() {
emake DESTDIR="${D}" install || die "emake install failed"

dodoc NEWS || die "dodoc failed"
}
