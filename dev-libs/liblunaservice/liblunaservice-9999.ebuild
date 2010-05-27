EGIT_REPO_URI="git://git.webos-internals.org/libraries/lunaservice.git"

inherit git toolchain-funcs

SLOT="0"
IUSE="0"
KEYWORDS="arm x86"

DEPENDS=""
RDEPENDS="${DEPENDS}"

src_compile() {
	tc-getCC
	emake
}

src_install() {
	into /usr
	dolib.so liblunaservice.so
	insinto /usr/include/lunaservice
	doins *.h
}

