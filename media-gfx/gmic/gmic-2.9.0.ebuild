# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CMAKE_MAKEFILE_GENERATOR="emake"
CMAKE_BUILD_TYPE=Release
#CMAKE_MIN_VERSION="3.12.1"

inherit bash-completion-r1 cmake-utils

DESCRIPTION="GREYC's Magic Image Converter"
HOMEPAGE="http://gmic.eu/ https://github.com/dtschump/gmic https://framagit.org/dtschump/gmic"
GMIC_QT_URI="https://github.com/c-koi/gmic-qt/archive/v.${PV}.tar.gz -> gmic-qt-${PV}.tar.gz"
if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/dtschump/gmic.git"
	EGIT_REPO_URI_2="https://github.com/c-koi/gmic-qt.git"
	inherit git-r3
else
	SRC_URI="https://github.com/dtschump/gmic/archive/v.${PV}.tar.gz -> ${P}.tar.gz
		https://gmic.eu/gmic_stdlib$(ver_rs 1- '').h
		gimp? ( ${GMIC_QT_URI} )
		gui? ( ${GMIC_QT_URI} )
		krita? ( ${GMIC_QT_URI} )
	"
	KEYWORDS="~amd64 ~x86"
fi
LICENSE="CeCILL-2 GPL-3"
SLOT="0"
IUSE="bash-completion +cli ffmpeg fftw gimp graphicsmagick gui jpeg krita opencv openexr openmp png static-libs tiff X"
REQUIRED_USE="
	|| ( cli gimp gui krita )
	gimp? ( png fftw X )
	gui? ( png fftw X )
	krita? ( png fftw X )
"

QT_DEPS="
	dev-qt/qtcore:5=
	dev-qt/qtgui:5=
	dev-qt/qtnetwork:5=
	dev-qt/qtwidgets:5=
"
COMMON_DEPEND="
	fftw? ( sci-libs/fftw:3.0=[threads] )
	gimp? (
		>=media-gfx/gimp-2.8.0
		${QT_DEPS}
	)
	graphicsmagick? ( media-gfx/graphicsmagick:0= )
	gui? ( ${QT_DEPS} )
	jpeg? ( virtual/jpeg:0 )
	krita? ( ${QT_DEPS} )
	~media-libs/cimg-${PV}
	net-misc/curl
	opencv? ( >=media-libs/opencv-2.3.1a-r1:0= )
	openexr? (
		media-libs/ilmbase:0=
		media-libs/openexr:0=
	)
	png? ( media-libs/libpng:0= )
	sys-libs/zlib:0=
	tiff? ( media-libs/tiff:0 )
	X? (
		x11-libs/libX11
		x11-libs/libXext
	)
"
RDEPEND="${COMMON_DEPEND}
	ffmpeg? ( media-video/ffmpeg:0= )
"
DEPEND="${COMMON_DEPEND}
	gimp? ( dev-qt/linguist-tools:5 )
	gui? ( dev-qt/linguist-tools:5 )
	krita? ( dev-qt/linguist-tools:5 )
	virtual/pkgconfig
"

if [[ ${PV} == "9999" ]]; then
	GMIC_QT_DIR="gmic-qt"
	S="${WORKDIR}/${PN}"
else
	GMIC_QT_DIR="gmic-qt-v.${PV}"
	S="${WORKDIR}/${PN}-v.${PV}"
fi

pkg_pretend() {
	if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi

	if ! test-flag-CXX -std=c++11 ; then
		die "You need at least GCC 4.7.x or Clang >= 3.3 for C++11-specific compiler flags"
	fi
}

if [[ ${PV} == "9999" ]]; then
	src_unpack() {
		EGIT_CHECKOUT_DIR="${S}"
		git-r3_src_unpack

		if use gimp || use gui || use krita; then
			EGIT_REPO_URI="${EGIT_REPO_URI_2}"
			EGIT_CHECKOUT_DIR="${WORKDIR}/${GMIC_QT_DIR}"
			git-r3_src_unpack
		fi
	}
fi

src_prepare() {
	if [[ ${PV} != "9999" ]]; then
		ln -s "${EPREFIX}"/usr/include/CImg.h ./src/ || die
		cp -a "${DISTDIR}/gmic_stdlib$(ver_rs 1- '').h" src/gmic_stdlib.h || die
	fi
	cmake-utils_src_prepare

	if [[ ${PV} != "9999" ]]; then
		ln -sr ../${PN}-v.${PV} ../${PN}
	fi

	if use gimp || use gui || use krita; then
		sed -i \
			-e '/CMAKE_CXX_FLAGS_RELEASE/d' \
			../${GMIC_QT_DIR}/CMakeLists.txt || die "sed failed"
		local S="${WORKDIR}/${GMIC_QT_DIR}"
		#PATCHES=(
		#	"${FILESDIR}/gmic-2.5.6-fftw.patch"
		#)
		cmake-utils_src_prepare
	fi
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_LIB=ON
		-DBUILD_LIB_STATIC=$(usex static-libs ON OFF)
		-DBUILD_CLI=$(usex cli ON OFF)
		-DBUILD_MAN=$(usex cli ON OFF)
		-DBUILD_BASH_COMPLETION=$(usex cli $(usex bash-completion ON OFF) OFF)
		-DENABLE_X=$(usex X ON OFF)
		-DENABLE_FFMPEG=$(usex ffmpeg ON OFF)
		-DENABLE_FFTW=$(usex fftw ON OFF)
		-DENABLE_GRAPHICSMAGICK=$(usex graphicsmagick ON OFF)
		-DENABLE_JPEG=$(usex jpeg ON OFF)
		-DENABLE_OPENCV=$(usex opencv ON OFF)
		-DENABLE_OPENEXR=$(usex openexr ON OFF)
		-DENABLE_OPENMP=$(usex openmp ON OFF)
		-DENABLE_PNG=$(usex png ON OFF)
		-DENABLE_TIFF=$(usex tiff ON OFF)
		-DENABLE_ZLIB=ON
		-DENABLE_DYNAMIC_LINKING=ON
		-DCUSTOM_CFLAGS=ON
	)

	CMAKE_USE_DIR=${S}
	cmake-utils_src_configure

	# gmic-qt
	local CMAKE_USE_DIR="${WORKDIR}/${GMIC_QT_DIR}"
	mycmakeargs=(
		-DENABLE_DYNAMIC_LINKING=ON
		-DGMIC_LIB_PATH="../${P}_build"
	)
	local BUILD_DIR
	if use gimp; then
		BUILD_DIR=${WORKDIR}/gimp_build
		mycmakeargs+=( -DGMIC_QT_HOST=gimp )
		cmake-utils_src_configure
	fi
	if use gui; then
		BUILD_DIR=${WORKDIR}/gui_build
		mycmakeargs+=( -DGMIC_QT_HOST=none )
		cmake-utils_src_configure
	fi
	if use krita; then
		BUILD_DIR=${WORKDIR}/krita_build
		mycmakeargs+=( -DGMIC_QT_HOST=krita )
		cmake-utils_src_configure
	fi
}

src_compile() {
	cmake-utils_src_compile

	# gmic-qt
	local S="${WORKDIR}/${GMIC_QT_DIR}"
	local BUILD_DIR
	if use gimp; then
		BUILD_DIR="${WORKDIR}/gimp_build"
		cmake-utils_src_compile
	fi
	if use gui; then
		BUILD_DIR="${WORKDIR}/gui_build"
		cmake-utils_src_compile
	fi
	if use krita; then
		BUILD_DIR="${WORKDIR}/krita_build"
		cmake-utils_src_compile
	fi
}

src_install() {
	dodoc README

	# - the Gimp plugin dir is also searched by non-Gimp tools, and it's
	#   hardcoded in "gmic_stdlib.gmic"
	# - using the GMIC_SYSTEM_PATH env var to specify another system dir here
	#   might mean that this big file will be automatically downloaded in
	#   "~/.config/gmic/" when the user runs a tool before updating and sourcing
	#   the new environment
	local PLUGIN_DIR="/usr/$(get_libdir)/gimp/2.0/plug-ins/"
	insinto "${PLUGIN_DIR}"
	doins "resources/gmic_cluts.gmz"

	cmake-utils_src_install

	# By default, "gmic.cpp" includes "gmic.h" which defines "cimg_plugin" to "gmic.cpp" and then
	# includes "CImg.h" which includes "cimg_plugin" which is "gmic.cpp", of course.
	#
	# Yes, upstream is bad and they should feel bad. Undo this madness so we can build media-gfx/zart
	# using the installed "gmic.h".
	sed -i -e '/^#define cimg.*_plugin/d' "${ED}/usr/include/gmic.h" || die "sed failed"

	use cli && use bash-completion && newbashcomp "${WORKDIR}/${P}_build/resources/${PN}_bashcompletion.sh" ${PN}

	# gmic-qt
	if use gimp; then
		exeinto "${PLUGIN_DIR}"
		doexe "${WORKDIR}/gimp_build/gmic_gimp_qt"
	fi
	if use gui; then
		dobin "${WORKDIR}/gui_build/gmic_qt"
	fi
	if use krita; then
		dobin "${WORKDIR}/krita_build/gmic_krita_qt"
	fi
}
