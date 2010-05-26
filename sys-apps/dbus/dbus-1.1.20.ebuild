PALM_SRC="${PN}-${PV}.tar.gz"
PALM_PATCHES="${PN}-${PV}-patches.tgz"

inherit palm flag-o-matic

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"

IUSE="debug doc selinux X"

RDEPEND="dev-libs/expat"
DEPEND="${RDEPEND}"

src_compile() {
	# so we can get backtraces from apps
	append-flags -rdynamic
	append-flags -lrt

	local myconf=""

	hasq test ${FEATURES} && myconf="${myconf} --enable-tests=yes"
	# libaudit is *only* used in DBus wrt SELinux support, so disable it, if
	# not on an SELinux profile.
	econf \
		$(use_with X x) \
		$(use_enable kernel_linux inotify) \
		$(use_enable kernel_FreeBSD kqueue) \
		$(use_enable selinux) \
		$(use_enable selinux libaudit)	\
		$(use_enable debug verbose-mode) \
		$(use_enable debug asserts) \
		--with-xml=expat \
		--with-system-pid-file=/var/run/dbus.pid \
		--with-system-socket=/var/run/dbus/system_bus_socket \
		--with-session-socket-dir=/tmp \
		--with-dbus-user=messagebus \
		--localstatedir=/var \
		$(use_enable doc doxygen-docs) \
		--disable-xml-docs \
		${myconf} \
		|| die "econf failed"

	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access

	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	# initscript
	newinitd "${FILESDIR}"/dbus.init-1.0 dbus

	# dbus X session script (#77504)
	# turns out to only work for GDM. has been merged into other desktop
	# (kdm and such scripts)
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}"/30-dbus

	# needs to exist for the system socket
	keepdir /var/run/dbus
	# needs to exist for machine id
	keepdir /var/lib/dbus
	# needs to exist for dbus sessions to launch

	keepdir /usr/lib/dbus-1.0/services
	keepdir /usr/share/dbus-1/services
	keepdir /etc/dbus-1/system.d/
	keepdir /etc/dbus-1/session.d/

	dodoc AUTHORS ChangeLog HACKING NEWS README doc/TODO
	if use doc; then
		dohtml doc/*html
	fi
}

