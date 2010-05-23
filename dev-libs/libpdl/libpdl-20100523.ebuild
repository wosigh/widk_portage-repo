SRC_URI="https://cdn.downloads.palm.com/sdkdownloads/PDK/Palm-PDK.dmg"

SLOT="0"
IUSE="0"
KEYWORDS="arm x86"

DEPENDS=""
RDEPENDS="${DEPENDS}"

src_unpack() {
	7z x ${DISTDIR}/Palm-PDK.dmg
	mkdir mnt
	mount -o loop 4.hfs mnt
	cp mnt/PalmPDK.pkg/Contents/Packages/palmpdk.pkg/Contents/Archive.pax.gz ./
	umount mnt
	gunzip Archive.pax.gz
	if [ "${ARCH}" == "arm" ]; then
		pax -r -f Archive.pax ./opt/PalmPDK/device/lib/libpdl.so
	else
		pax -r -f Archive.pax ./opt/PalmPDK/host/lib/libpdl.so
	fi
	pax -r -f Archive.pax ./opt/PalmPDK/include/PDL.h
	pax -r -f Archive.pax ./opt/PalmPDK/include/PDL_Mojo.h
	pax -r -f Archive.pax ./opt/PalmPDK/include/PDL_Services.h
	pax -r -f Archive.pax ./opt/PalmPDK/include/PDL_types.h
}

src_install() {
	cd ${WORKDIR}
	into /usr
        if [ "${ARCH}" == "arm" ]; then
                dolib.so opt/PalmPDK/device/lib/libpdl.so
        else
                dolib.so opt/PalmPDK/host/lib/libpdl.so
        fi
	insinto /usr/include
	doins opt/PalmPDK/include/*
}

