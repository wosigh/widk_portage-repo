EAPI="2"

PALM_SRC="${PN}-${PV}.tar.gz"
#PALM_PATCHES="${PN}-${PV}-patches.tgz"

inherit palm

LICENSE="LGPL-2"
SLOT="2"

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
        emake -j1 DESTDIR="${D}" htmldocdir="/usr/share/doc/${PF}/html" install || die "emake install failed."
        dodoc AUTHORS ChangeLog NEWS README TODO
}
