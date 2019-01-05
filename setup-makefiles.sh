#!/bin/bash
#
# Copyright (C) 2018 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

DEVICE=dragon
VENDOR=google

INITIAL_COPYRIGHT_YEAR=2019

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

LINEAGE_ROOT="$MY_DIR"/../../..

HELPER="$LINEAGE_ROOT"/vendor/lineage/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

# Initialize the helper
setup_vendor "$DEVICE" "$VENDOR" "$LINEAGE_ROOT" false

# Copyright headers and guards
write_headers "$DEVICE"

# The standard blobs
write_makefiles "$MY_DIR"/proprietary-files.txt true

# Deal with files that needs to be put in rootfs
if [ -f proprietary-files-rootfs.txt ]; then
    # We will change PRODUCTMK to create a new file.
    # Save original value and restore when done.
    SAVED_PRODUCTMK=$PRODUCTMK
    export PRODUCTMK=${PRODUCTMK/%.mk/-rootfs.mk}

    # Copyright headers but not guards
    write_header "$PRODUCTMK"

    # General copy routine
    parse_file_list proprietary-files-rootfs.txt

    # Require using "system/vendor" instead of $(TARGET_COPY_OUT_VENDOR),
    # make the following sed easier
    write_product_copy_files FALSE

    # The key: replace system/ in target with root/
    sed -i 's|:system|:root|g' "$PRODUCTMK"

    # Include rootfs file list
    printf "\n\$(call inherit-product,vendor/$VENDOR/$DEVICE/$(basename $PRODUCTMK))" >> $SAVED_PRODUCTMK

    # Restore file name
    export PRODUCTMK=$SAVED_PRODUCTMK
    unset SAVED_PRODUCTMK
fi

# Finish
write_footers
