# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools git-r3 flag-o-matic versionator

DESCRIPTION="Terminal multiplexer"
HOMEPAGE="https://tmux.github.io/"
SRC_URI="https://raw.githubusercontent.com/przepompownia/tmux-bash-completion/678a27616b70c649c6701cae9cd8c92b58cc051b/completions/tmux -> tmux-bash-completion-678a27616b70c649c6701cae9cd8c92b58cc051b"
EGIT_REPO_URI="https://github.com/tmux/tmux.git"

LICENSE="ISC"
SLOT="0"
KEYWORDS=""
IUSE="debug selinux utempter vim-syntax kernel_FreeBSD kernel_linux"

CDEPEND="
	dev-libs/libevent:0=
	sys-libs/ncurses:0=
	utempter? (
		kernel_linux? ( sys-libs/libutempter )
		kernel_FreeBSD? ( || ( >=sys-freebsd/freebsd-lib-9.0 sys-libs/libutempter ) )
	)"

DEPEND="
	${CDEPEND}
	virtual/pkgconfig"

RDEPEND="
	${CDEPEND}
	selinux? ( sec-policy/selinux-screen )
	vim-syntax? ( app-vim/vim-tmux )"

DOCS=( CHANGES README TODO )

PATCHES=(
	"${FILESDIR}/${PN}-2.4-flags.patch"

	# usptream fixes (can be removed with next version bump)
)

S="${WORKDIR}/${P/_/-}"

src_prepare() {
	# bug 438558
	# 1.7 segfaults when entering copy mode if compiled with -Os
	replace-flags -Os -O2

	# regenerate aclocal.m4 to support earlier automake versions
	rm -f aclocal.m4 || die

	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--sysconfdir="${EPREFIX}"/etc
		$(use_enable debug)
		$(use_enable utempter)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	einstalldocs

	dodoc example_tmux.conf
	docompress -x /usr/share/doc/${PF}/example_tmux.conf
}

pkg_postinst() {
	if ! version_is_at_least 1.9a ${REPLACING_VERSIONS:-1.9a}; then
		echo
		ewarn "Some configuration options changed in this release."
		ewarn "Please read the CHANGES file in /usr/share/doc/${PF}/"
		ewarn
		ewarn "WARNING: After updating to ${P} you will _not_ be able to connect to any"
		ewarn "older, running tmux server instances. You'll have to use an existing client to"
		ewarn "end your old sessions or kill the old server instances. Otherwise you'll have"
		ewarn "to temporarily downgrade to access them."
		echo
	fi
}
