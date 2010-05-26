EAPI="2"
inherit eutils flag-o-matic
SRC_URI="http://26elf.at/files/fische-3.1.4a.tar.gz"
RESTRICT="mirrors"
SLOT="0"
KEYWORDS="arm x86"

S="${WORKDIR}/fische-3.1"

#src_prepare() {
#	epatch ${FILESDIR}/pdl.patch
#}

src_install() {
	into /usr
	dobin src/fische
}

