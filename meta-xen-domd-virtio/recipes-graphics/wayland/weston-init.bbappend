FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_install:append() {
    sed -i ${D}/etc/xdg/weston/weston.ini \
        -e '$a [output]' \
        -e '$a name=DP-1' \
        -e '$a app-ids=DomU' \
        -e '$a [output]' \
        -e '$a name=DSI-1' \
        -e '$a app-ids=DomA' \

    sed -i ${D}/${libdir}/systemd/system/weston.service \
        -e 's|/usr/bin/weston|/usr/bin/weston --debug --log=/tmp/weston|'
}

