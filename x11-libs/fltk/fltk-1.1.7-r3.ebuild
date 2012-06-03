# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/fltk/fltk-1.1.7-r3.ebuild,v 1.1 2007/12/15 21:12:22 coldwind Exp $

inherit eutils toolchain-funcs multilib

DESCRIPTION="C++ user interface toolkit for X and OpenGL."
HOMEPAGE="http://www.fltk.org"
SRC_URI="http://ftp.easysw.com/pub/${PN}/${PV}/${P}-source.tar.bz2"

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
LICENSE="FLTK LGPL-2"

PV_MAJOR=${PV/.*/}
PV_MINOR=${PV#${PV_MAJOR}.}
PV_MINOR=${PV_MINOR/.*}
SLOT="1.1"

INCDIR=/usr/include/fltk-${SLOT}
LIBDIR=/usr/$(get_libdir)/fltk-${SLOT}

IUSE="noxft opengl debug"

DEPEND="
	x11-libs/libXext
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libXt
	x11-proto/xextproto
	!noxft? ( virtual/xft )
	media-libs/libpng
	virtual/jpeg
	opengl? ( virtual/opengl )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/libs-1.7.diff"
	epatch "${FILESDIR}/${P}-amd64.patch"
	epatch "${FILESDIR}/${P}-as-needed.patch"
	epatch "${FILESDIR}/${P}-dieonerrors.patch"
	epatch "${FILESDIR}/${P}-maxmin-typo.patch"
	epatch "${FILESDIR}/${P}-xft-and-misc.patch"

	sed -i -e '/C\(XX\)\?FLAGS=/s:@C\(XX\)\?FLAGS@::' \
		"${S}/fltk-config.in" || die "unable to sed out compile flags"

	if use multilib; then
		cd "${WORKDIR}"
		mkdir 32
		mv "${P}" 32/ || die
		unpack ${A}
		cd "${S}"
		epatch "${FILESDIR}/libs-1.7.diff"
		epatch "${FILESDIR}/${P}-amd64.patch"
		epatch "${FILESDIR}/${P}-as-needed.patch"
		epatch "${FILESDIR}/${P}-dieonerrors.patch"
		epatch "${FILESDIR}/${P}-maxmin-typo.patch"
		epatch "${FILESDIR}/${P}-xft-and-misc.patch"
		sed -i -e '/C\(XX\)\?FLAGS=/s:@C\(XX\)\?FLAGS@::' \
			"${S}/fltk-config.in" || die "unable to sed out compile flags"
	fi
}

src_compile() {
	local myconf
	myconf="--enable-shared --enable-xdbe --enable-threads"

	if ! use noxft; then
		myconf="${myconf} --enable-xft"
	else
		myconf="${myconf} --disable-xft"
	fi

	use debug && myconf="${myconf} --enable-debug"

	use opengl || myconf="${myconf} --disable-gl"

	# needed for glibc-2.3.1 (as far as i can test)
	# otherwise libstdc++ won't be linked. #17894 and #15572
	# doesn't happen for glibc-2.3.2 - <liquidx@gentoo.org>
	export CXX=$(tc-getCXX)
	export CC=$(tc-getCC)

	# bug #19894
	export C_INCLUDE_PATH="${C_INCLUDE_PATH}:/usr/include/freetype2"
	export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}:/usr/include/freetype2"

	if use multilib; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}"
		econf \
			--includedir=${INCDIR}\
			--libdir=/usr/$(get_libdir)/fltk-${SLOT} \
			${myconf} || die "Configuration in 32bit build-dir Failed"
		emake || die "doing 32bit stuff failed"
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	econf \
		--includedir=${INCDIR}\
		--libdir=/usr/$(get_libdir)/fltk-${SLOT} \
		${myconf} || die "Configuration Failed"

	emake || die "Parallel Make Failed"
}

src_install() {
	if use multilib; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}"
		einstall \
			includedir="${D}${INCDIR}" \
			libdir="${D}/usr/$(get_libdir)/fltk-${SLOT}" || die "Installation of 32 bit version Failed"
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	einstall \
		includedir="${D}${INCDIR}" \
		libdir="${D}/usr/$(get_libdir)/fltk-${SLOT}" || die "Installation Failed"

	ranlib "${D}${LIBDIR}"/*.a

	insinto /usr/share/cmake/Modules
	doins "${FILESDIR}"/FLTKConfig.cmake CMake/FLTKUse.cmake

	dodoc CHANGES README

	if use multilib; then
		echo "LDPATH=/usr/lib32/fltk-${SLOT}:/usr/lib64/fltk-${SLOT}" > 99fltk-${SLOT}
		else
		echo "LDPATH=${LIBDIR}" > 99fltk-${SLOT}
	fi

	echo "FLTK_DOCDIR=/usr/share/doc/${PF}/html" >> 99fltk-${SLOT}

	doenvd 99fltk-${SLOT}

	dohtml -A xbm,xpm,h,cxx,fl,menu -r "${D}"/usr/share/doc/fltk/*
	rm -rf "${D}"/usr/share/doc/fltk
	rm -rf "${D}"/usr/share/man/cat{1,3}

	sed -i -e 's,^LDFLAGS=.*$,LDFLAGS="",g' "${D}/usr/bin/fltk-config" || \
		die "sed of fltk-config failed"

}

pkg_postinst() {
	ewarn "the xft USE flag has been changed to noxft. this was because most"
	ewarn "users want xft, but if you do not, be sure to change the flag"
}
