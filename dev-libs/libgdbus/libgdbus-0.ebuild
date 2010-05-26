EAPI="2"

PALM_SRC="${PN}.tar.gz"
PALM_PATCHES="${PN}-patches.tgz"

inherit palm

LICENSE="LGPL-2"
SLOT="2"

RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}"

src_prepare() {
	sh bootstrap
}
