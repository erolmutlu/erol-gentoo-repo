# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_P="CImg-v.${PV}"

DESCRIPTION="C++ template image processing toolkit"
HOMEPAGE="http://cimg.eu/ https://github.com/dtschump/CImg"
SRC_URI="https://github.com/dtschump/CImg/archive/v.${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CeCILL-2 CeCILL-C"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

S=${WORKDIR}/${MY_P}

src_install() {
	dodoc README.txt
	doheader CImg.h
	use doc && dodoc -r html
}
