# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/Attic/ncurses-5.4-r6.ebuild,v 1.15 2008/11/03 03:55:12 vapier dead $

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="console display library"
HOMEPAGE="http://www.gnu.org/software/ncurses/"
SRC_URI="mirror://gnu/ncurses/${P}.tar.gz"

LICENSE="MIT"
SLOT="5"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="gpm build bootstrap debug doc minimal unicode nocxx"

DEPEND="gpm? ( sys-libs/gpm )"
RDEPEND="${DEPEND}"

pkg_setup() {
	# check for unicode use flag, see bug #78313
	if ! use unicode && [[ -f ${ROOT}/usr/lib/libncursesw.so ]] && [[ ${COMPILE_NCURSES} != "true" ]] ; then
		ewarn "Remerging ncurses without unicode in USE flags may break your system."
		ewarn "For more information see http://bugs.gentoo.org/78313"
		ewarn "If you still want continue, export COMPILE_NCURSES to 'true'."
		die "refusing to rebuild ncurses w/out unicode"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-xterm.patch
	epatch "${FILESDIR}"/${P}-share-sed.patch #42336
	epatch "${FILESDIR}"/${P}-c++-templates.patch #90819
	epatch "${FILESDIR}"/cross-compile-fix.patch
}

src_compile() {
	tc-export BUILD_CC
	filter-flags -fno-exceptions

	# Protect the user from themselves #115036
	unset TERMINFO

	# From version 5.3, ncurses also build c++ bindings, and as
	# we do not have a c++ compiler during bootstrap, disable
	# building it.  We will rebuild ncurses after gcc's second
	# build in bootstrap.sh.
	local myconf=""
	( use build || use bootstrap || use nocxx ) \
		&& myconf="${myconf} --without-cxx --without-cxx-binding --without-ada"

	# First we build the regular ncurses ...
	mkdir "${WORKDIR}"/narrowc
	cd "${WORKDIR}"/narrowc
	do_compile ${myconf}

	# Then we build the UTF-8 version
	if use unicode ; then
		mkdir "${WORKDIR}"/widec
		cd "${WORKDIR}"/widec
		do_compile ${myconf} --enable-widec --includedir=/usr/include/ncursesw
	fi
}
do_compile() {
	ECONF_SOURCE=${S}

	# We need the basic terminfo files in /etc, bug #37026.  We will
	# add '--with-terminfo-dirs' and then populate /etc/terminfo in
	# src_install() ...
	econf \
		--libdir=/$(get_libdir) \
		--with-terminfo-dirs="/etc/terminfo:/usr/share/terminfo" \
		--disable-termcap \
		--with-shared \
		--with-rcs-ids \
		--without-ada \
		--enable-symlinks \
		--with-build-cflags='-march="i486"' \
		--program-prefix="" \
		$(use_with debug) \
		$(use_with gpm) \
		"$@" \
		|| die "configure failed"

	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package
	# in parallel.  This is not really a perf hit since the source
	# generation is quite small.  -vapier
	emake -j1 sources || die "make sources failed"
	emake || die "make failed"
}

src_install() {
	# install unicode version first so that the non-unicode
	# files overwrite the unicode versions
	if use unicode ; then
		cd "${WORKDIR}"/widec
		sed -i '2iexit 0' man/edit_man.sh
		make DESTDIR="${D}" install || die "make widec install failed"
	fi
	cd "${WORKDIR}"/narrowc
	make DESTDIR="${D}" install || die "make narrowc install failed"

	# Move static and extraneous ncurses libraries out of /lib
	dodir /usr/$(get_libdir)
	cd "${D}"/$(get_libdir)
	mv libform* libmenu* libpanel* *.a "${D}"/usr/$(get_libdir)/
	gen_usr_ldscript lib{,n}curses.so
	use unicode && gen_usr_ldscript lib{,n}cursesw.so

	# We need the basic terminfo files in /etc, bug #37026
	einfo "Installing basic terminfo files in /etc..."
	for x in ansi console dumb linux rxvt screen sun vt{52,100,102,200,220} \
	         xterm xterm-color xterm-xfree86
	do
		local termfile=$(find "${D}"/usr/share/terminfo/ -name "${x}" 2>/dev/null)
		local basedir=$(basename $(dirname "${termfile}"))

		if [[ -n ${termfile} ]] ; then
			dodir /etc/terminfo/${basedir}
			mv ${termfile} "${D}"/etc/terminfo/${basedir}/
			dosym ../../../../etc/terminfo/${basedir}/${x} \
				/usr/share/terminfo/${basedir}/${x}
		fi
	done

	# Build fails to create this ...
	dosym ../share/terminfo /usr/$(get_libdir)/terminfo

	echo "CONFIG_PROTECT_MASK=\"/etc/terminfo\"" > "${T}"/50ncurses
	doenvd "${T}"/50ncurses

	if use build ; then
		cd "${D}"
		rm -rf usr/share/man
		cd usr/share/terminfo
		cp -pPR l/linux n/nxterm v/vt100 "${T}"
		rm -rf *
		mkdir l x v
		cp -pPR "${T}"/linux l
		cp -pPR "${T}"/nxterm x/xterm
		cp -pPR "${T}"/vt100 v
	else
		use minimal && rm -r "${D}"/usr/share/terminfo
		cd "${S}"
		dodoc ANNOUNCE MANIFEST NEWS README* TO-DO doc/*.doc
		use doc && dohtml -r doc/html/
	fi
}

pkg_preinst() {
	use unicode || preserve_old_lib /$(get_libdir)/libncursesw.so.5
}

pkg_postinst() {
	use unicode || preserve_old_lib_notify /$(get_libdir)/libncursesw.so.5
}
