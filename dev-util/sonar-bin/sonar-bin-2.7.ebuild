inherit java-pkg-2

DESCRIPTION="Sonar is an open platform to manage code quality."
HOMEPAGE="http://sonarsource.org/"
LICENSE="LGPL-3"
MY_PV="${PV/_alpha/M}"
MY_PV="${MY_PV/_rc/-RC}"
MY_P="sonar-${MY_PV}"
SRC_URI="http://dist.sonar.codehaus.org/${MY_P}.zip"
RESTRICT="mirror"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}"

RDEPEND=">=virtual/jdk-1.5"

INSTALL_DIR="/opt/sonar"

pkg_setup() {
    #enewgroup <name> [gid]
    enewgroup sonar
    #enewuser <user> [uid] [shell] [homedir] [groups] [params]
    enewuser sonar -1 /bin/bash /opt/sonar "sonar"
}

src_unpack() {
    unpack ${A}
    cd "${S}"

    # TODO remove unneded files

    # Fix permissions
    chmod -R a-x,a+X conf data extensions extras lib war COPYING
}

src_install() {
    insinto ${INSTALL_DIR}
    doins -r bin conf data extensions extras lib logs war COPYING

    newinitd "${FILESDIR}/init.sh" sonar

    fowners -R sonar:sonar ${INSTALL_DIR}
    fperms 755 "${INSTALL_DIR}/bin/linux-x86-32/sonar.sh"
    fperms 755 "${INSTALL_DIR}/bin/linux-x86-32/wrapper"

    # Protect Sonar conf on upgrade
    echo "CONFIG_PROTECT=\"${INSTALL_DIR}/conf\"" > "${T}/25sonar" || die
    doenvd "${T}/25sonar"
}
