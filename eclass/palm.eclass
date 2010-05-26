inherit eutils

: ${PATCH_LEVEL:=-p1}

WEBOS_VERSION="1.4.1.1"

RESTRICT="mirror"

PALM_URI_BASE="http://palm.cdnetworks.net/opensource/${WEBOS_VERSION}/"

SRC_URI="${PALM_URI_BASE}${PALM_SRC}"

if [ -n "${PALM_PATCHES}" ]; then
	SRC_URI="${SRC_URI} ${PALM_URI_BASE}${PALM_PATCHES}"
fi

DESCRIPTION="Palm Opensource Package: ${PN}"

HOMEPAGE="http://opensource.palm.com/packages.html"

KEYWORDS="arm x86"

EXPORT_FUNCTIONS src_unpack

palm_src_unpack() {
	unpack ${PALM_SRC}
	if [ -n "${PALM_PATCHES}" ]; then
		zcat ${DISTDIR}/${PALM_PATCHES} | patch -d ${S} ${PATCH_LEVEL}
	fi
}
