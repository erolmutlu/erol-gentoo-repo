# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

COMPRESSTYPE=".lzma"
K_PREPATCHED="yes"
UNIPATCH_STRICTORDER="yes"
K_SECURITY_UNSUPPORTED="1"

RESTRICT="binchecks strip primaryuri mirror"

ETYPE="sources"
inherit kernel-2
detect_version
K_NOSETEXTRAVERSION="don't_set_it"

DESCRIPTION="Zen-Sources Kernel Patchset"
HOMEPAGE="http://zen-sources.org"
ZEN_URI="http://zen-sources.org/files/${KV_FULL}.patch${COMPRESSTYPE}"
SRC_URI="${KERNEL_URI} ${ZEN_URI}"

KEYWORDS=""
IUSE=""

src_unpack(){
        kernel-2_src_unpack
        cd ${S}
        epatch ${DISTDIR}/${KV_FULL}.patch${COMPRESSTYPE}
}

K_EXTRAEINFO="For more info on zen-sources, and for how to report problems, see: \
${HOMEPAGE}, also go to #zen-sources on freenode"
