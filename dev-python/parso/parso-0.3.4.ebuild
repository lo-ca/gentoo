# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} )

inherit distutils-r1

DESCRIPTION="a python parser that supports error recovery and round-trip parsing"
HOMEPAGE="https://github.com/davidhalter/parso https://pypi.org/project/parso/"
SRC_URI="https://github.com/davidhalter/${PN}/archive/v${PV/_p*/}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P/_p*}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86"
IUSE="doc test"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx )
	test? ( dev-python/pytest[${PYTHON_USEDEP}] 
			dev-python/docopt[${PYTHON_USEDEP}] )"

python_test() {
	py.test -v test || die "tests failed with ${EPYTHON}"
}

python_compile_all() {
	use doc && emake -C docs html
}

python_install_all() {
	use doc && HTML_DOCS=( "${S}"/docs/_build/html/. )
	distutils-r1_python_install_all
}
