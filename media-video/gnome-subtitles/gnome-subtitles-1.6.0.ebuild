# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
GNOME2_LA_PUNT="yes"

inherit mono-env gnome2

DESCRIPTION="Video subtitling for the Gnome desktop"
HOMEPAGE="http://gnome-subtitles.sourceforge.net/"
SRC_URI="https://github.com/erolmutlu/erol-gentoo-repo/blob/master/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND="
	>=dev-lang/mono-4.0
	>=dev-dotnet/gtk-sharp-2.99.2
	media-libs/gstreamer:1.0
	>=app-text/gtkspell-3.0
	>=app-text/enchant-1.6
	media-libs/gst-plugins-base:1.0
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	app-text/gnome-doc-utils
"

src_compile() {
	MAKEOPTS="${MAKEOPTS} -j1" gnome2_src_compile #508842
}
