PALM_SRC="${PN}-${PV}.tar.gz"
#PALM_PATCHES="${PN}-${PV}-patches.tgz"

inherit palm

LICENSE="MIT"
SLOT="0"

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
	einstall man1dir="${D}/usr/share/man/man1" || die "einstall failed"
	dosed /usr/$(get_libdir)/libexpat.la #81568
	dodoc Changes README
	dohtml doc/*
}
