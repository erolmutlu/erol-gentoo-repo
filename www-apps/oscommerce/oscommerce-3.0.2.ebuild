# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit webapp depend.php

DESCRIPTION="osCommerce Online Merchant is an Open Source online shop e-commerce solution."
HOMEPAGE="http://www.oscommerce.com/"
P="${PN}-3.0.2"
SRC_URI="http://www.oscommerce.com/ext/${P}.zip"

LICENSE="GPL-2"
KEYWORDS="~x86"

need_httpd_cgi
need_php_httpd


S="${WORKDIR}"/${P}

pkg_setup() {
	webapp_pkg_setup
	require_php_with_use mysqli json
}

src_install() {
	webapp_src_preinst

	dodoc readme.txt
	rm -f readme.txt license.txt

	insinto "${MY_HTDOCSDIR}"
	doins -r ${PN}/*

	webapp_serverowned "${MY_HTDOCSDIR}"/admin/backups
	webapp_serverowned "${MY_HTDOCSDIR}"/pub
	webapp_serverowned "${MY_HTDOCSDIR}"/includes
	webapp_serverowned "${MY_HTDOCSDIR}"/download
	webapp_serverowned "${MY_HTDOCSDIR}"/includes/configure.php
	webapp_configfile  "${MY_HTDOCSDIR}"/includes/configure.php

	webapp_src_install
}


