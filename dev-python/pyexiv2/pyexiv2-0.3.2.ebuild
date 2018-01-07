# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils versionator scons-utils python-single-r1

MY_PV=$(get_version_component_range 1-2)
DESCRIPTION="Python binding to exiv2"
HOMEPAGE="http://tilloy.net/dev/pyexiv2/"
SRC_URI="http://launchpad.net/${PN}/${MY_PV}.x/${PV}/+download/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

DEPEND="
	>=media-gfx/exiv2-0.20
	dev-python/sphinx[${PYTHON_USEDEP}]
	>=dev-libs/boost-1.57[python,${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

_get_boostlib() {
	python -c 'import sys; print ("boost_python-%d.%d" % sys.version_info[0:2])'
}

src_compile() {
	escons BOOSTLIB="$(_get_boostlib)" lib
	if use doc; then
		escons doc

		# To enable doins -r in src_install
		rm -R doc/_build/.doctrees || die
	fi
}

src_install() {
	escons DESTDIR="${D}" BOOSTLIB="$(_get_boostlib)" install
	dodoc NEWS README todo

	if use examples; then
		insinto /usr/share/${PN}/examples
		doins src/*example*.py
	fi

	if use doc; then
		docinto html
		dodoc -r doc/html/*
	fi
	python_optimize
}
