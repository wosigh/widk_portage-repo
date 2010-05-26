PALM_SRC="${PN}-${PV}.tar.gz"

inherit flag-o-matic palm

DESCRIPTION="library of simple functions that are optimized for various CPUs"

LICENSE="BSD-2"
SLOT="0.3"
IUSE="doc"

DEPEND="=dev-libs/glib-2*"

src_compile() {
	strip-flags
	filter-flags -O?
	append-flags -O2
	econf $(use_enable doc gtk-doc) || die "econf failed"
	emake -j1 || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
