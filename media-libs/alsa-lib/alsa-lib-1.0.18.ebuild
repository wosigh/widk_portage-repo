PALM_SRC="${PN}-${PV}.tgz"
PALM_PATCHES="${PN}-${PV}-patch.gz"
PATCH_LEVEL="-p0"

inherit palm toolchain-funcs

LICENSE="LGPL-2"
SLOT="2"

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc ChangeLog TODO || die
}
