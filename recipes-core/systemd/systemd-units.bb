SUMMARY = "Specific services for systemd"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PR = "r0"

# can0 service depends on ip which is included in iproute2
RDEPENDS_${PN} += "bash busybox dash e2fsprogs-mke2fs evtest fbida gnupg iproute2 mtd-utils ppp rsync wvdial"

SRC_URI += " \
            file://images/busy.png \
            file://images/done.png \
            file://images/error.png \
            file://images/logo.png \
            file://ble.service \
            file://ble.sh \
            file://can0.service \
            file://can0.sh \
            file://communication.target \
            file://debug.target \
            file://drive.target \
            file://eth1.network \
            file://fwu-usb.service \
            file://fwu-usb.sh \
            file://gpio.service \
            file://gpio.sh \
            file://gsm.service \
            file://gsm.sh \
            file://led.service \
            file://led.sh \
            file://mnt-data.service \
            file://mnt-data.sh \
            file://mnt-rfs.service \
            file://mnt-rfs.sh \
            file://mnt-sda1.service \
            file://mnt-sda1.sh \
            file://usb.service \
            file://usb.sh \
            file://wlan0.network \
            file://wlan0.sh \
            file://wvdial.service \
            file://wvdial-swisscom.service \
"

FILES_${PN}_append = " \
    /mnt/ \
    ${systemd_system_unitdir} \
    ${systemd_unitdir}/network/ \
    ${sysconfdir}/images/ \
    ${sysconfdir}/scripts/ \
"

inherit systemd

NATIVE_SYSTEMD_SUPPORT = "1"

SYSTEMD_SERVICE_${PN} = " \
    can0.service \
    gpio.service \
    led.service \
    mnt-data.service \
    usb.service \
"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -d ${D}${sysconfdir}/scripts
    install -m 0644 ${WORKDIR}/ble.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/ble.sh ${D}${sysconfdir}/scripts/
    install -m 0644 ${WORKDIR}/can0.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/can0.sh ${D}${sysconfdir}/scripts/
    install -m 0644 ${WORKDIR}/gpio.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/gpio.sh ${D}${sysconfdir}/scripts/
    install -m 0644 ${WORKDIR}/gsm.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/gsm.sh ${D}${sysconfdir}/scripts/
    install -m 0644 ${WORKDIR}/led.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/led.sh ${D}${sysconfdir}/scripts/
    install -m 0644 ${WORKDIR}/usb.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/usb.sh ${D}${sysconfdir}/scripts/
    install -m 0755 ${WORKDIR}/wlan0.sh ${D}${sysconfdir}/scripts/

    install -d ${D}/mnt/ubi2
    install -d ${D}/mnt/ubi3
    install -d ${D}/mnt/data
    install -d ${D}/mnt/data_backup
    install -m 0644 ${WORKDIR}/mnt-data.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/mnt-data.sh ${D}${sysconfdir}/scripts/

    install -d ${D}/mnt/rfs_inactive
    install -m 0644 ${WORKDIR}/mnt-rfs.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/mnt-rfs.sh ${D}${sysconfdir}/scripts/

    install -d ${D}/mnt/sda1
    install -m 0644 ${WORKDIR}/mnt-sda1.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/mnt-sda1.sh ${D}${sysconfdir}/scripts/


    install -m 0644 ${WORKDIR}/fwu-usb.service ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/fwu-usb.sh ${D}${sysconfdir}/scripts/

    install -d ${D}${sysconfdir}/images
    install -m 0644 ${WORKDIR}/images/busy.png ${D}${sysconfdir}/images/
    install -m 0644 ${WORKDIR}/images/done.png ${D}${sysconfdir}/images/
    install -m 0644 ${WORKDIR}/images/error.png ${D}${sysconfdir}/images/
    install -m 0644 ${WORKDIR}/images/logo.png ${D}${sysconfdir}/images/

    install -d ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/eth1.network ${D}${systemd_unitdir}/network/
    install -m 0644 ${WORKDIR}/wlan0.network ${D}${systemd_unitdir}/network/
    install -m 0644 ${WORKDIR}/wvdial.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/wvdial-swisscom.service ${D}${systemd_system_unitdir}

    install -m 0644 ${WORKDIR}/communication.target ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/debug.target ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/drive.target ${D}${systemd_system_unitdir}
}
