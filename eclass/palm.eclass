EAPI="2"

inherit eutils

WEBOS_VERSION="1.4.1.1"

RESTRICT="mirror"

SRC_URI="${PALM_SRC_URI} ${PALM_PATCHES_URI}"

DESCRIPTION="Palm Opensource Package: ${PN}"

HOMEPAGE="http://opensource.palm.com/packages.html"

KEYWORDS="arm x86"

EXPORT_FUNCTIONS src_prepare

: ${PATCHES=DIR:=".."}

palm_src_prepare() {
	if [[ -n ${PALM_PATCHES_URI} ]]; then
		for patch in $(ls ${PATCHES_DIR}/*.patch); do
			epatch ${patch}
		done
	fi
}
