EAPI="2"

PALM_SRC="${PN}-${PV}.tgz"
PALM_PATCHES="${PN}-${PV}-patch.gz"
PATCH_LEVEL="-p0"

inherit palm

LICENSE="LGPL-2"
SLOT="2"

RDEPEND=""
DEPEND="${RDEPEND}"

src_prepare() {
	sh autogen.sh
}

src_install() {
    emake DESTDIR="${D}" install || die "Install failed"
}	
