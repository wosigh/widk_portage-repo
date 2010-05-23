PALM_SRC="${PN}-${PV}.tar.gz"
PALM_PATCHES="${PN}-${PV}-patches.tgz"

inherit palm toolchain-funcs

LICENSE="LGPL-2"
SLOT="2"

RDEPEND=""
DEPEND="${RDEPEND}"

src_compile() {
	econf --enable-broken_linker --with-build-cflags="${CFLAGS}" || die
	emake || die
}
