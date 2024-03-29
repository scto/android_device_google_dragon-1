#!/vendor/bin/sh
#
# Intialize region settings. Ref: crosbug.com/p/44779

REGION_VPD_FILE=/sys/firmware/vpd/ro/region

REGION="us"
LANGUAGE="en"
COUNTRY="US"

if [ -f "${REGION_VPD_FILE}" ]; then
  REGION="$(cat ${REGION_VPD_FILE})"
fi

case "${REGION}" in
  gb | ie)
    COUNTRY="GB"
    ;;
  au | nz)
    COUNTRY="AU"
    ;;
  de)
    COUNTRY="DE"
    ;;
esac

setprop persist.sys.wifi.country_code "00"
setprop ro.boot.wificountrycode "00"
