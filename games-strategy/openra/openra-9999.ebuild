# Distributed under the terms of the GNU General Public License v2

EAPI=5

#MY_PV="release-${PV}"
DESCRIPTION="A free RTS engine supporting games like Command & Conquer, Red Alert and Dune2k"
HOMEPAGE="http://www.openra.net/"
SRC_URI=""

EGIT_REPO_URI="https://github.com/OpenRA/OpenRA.git"
EGIT_BRANCH="bleed"
GIT_ECLASS="git-r3"
inherit eutils gnome2-utils fdo-mime ${GIT_ECLASS}
#mono-env

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc +tools +xdg +zenity"
RESTRICT="mirror"

RDEPEND="dev-dotnet/libgdiplus
     >=dev-lang/mono-3.2
     media-libs/freetype:2[X]
     media-libs/libsdl2[X,opengl,video]
     media-libs/openal
     virtual/jpeg:0
     virtual/opengl
     =dev-lang/lua-5.1*:0
     xdg? ( x11-misc/xdg-utils )
     zenity? ( gnome-extra/zenity )"
DEPEND="${RDEPEND}
     doc? ( || ( app-text/discount
          app-text/peg-markdown
          dev-python/markdown
          dev-perl/Text-Markdown ) )"

#pkg_setup() {
#     mono-env_pkg_setup
#}

src_prepare() {
     emake cli-dependencies
}

src_compile() {
     emake $(usex tools "all" "") $(usex debug "" "DEBUG=false")
     MY_PV=$(git rev-list --count bleed)
     emake VERSION=${MY_PV} man-page
}

src_install()
{
     MY_PV=$(git rev-list --count bleed)
     emake $(usex debug "" "DEBUG=false") \
          prefix=/usr \
          libdir="/usr/$(get_libdir)" \
          DESTDIR="${D}" \
          $(usex tools "install") install-linux-scripts install-man-page
     emake \
          datadir="/usr/share" \
          DESTDIR="${D}" install-linux-mime install-linux-icons

     # desktop directory
     insinto /usr/share/desktop-directories
     doins "${FILESDIR}"/${PN}.directory

     # desktop menu
     insinto /etc/xdg/menus/applications-merged
     doins "${FILESDIR}"/games-${PN}.menu
}

pkg_preinst() {
     gnome2_icon_savelist
}

pkg_postinst() {
     gnome2_icon_cache_update
     fdo-mime_desktop_database_update
     fdo-mime_mime_database_update
}

pkg_postrm() {
     gnome2_icon_cache_update
     fdo-mime_desktop_database_update
     fdo-mime_mime_database_update
}