#!/bin/bash

ORIGINAL_EDID_FILE="$(dirname "$0")/sys_class_drm_card0-DP-1_edid"
TRIMMED_EDID_FILE="/tmp/sys_class_drm_card0-DP-1_edid_trimmed"
D=/sys/kernel/debug/dri/0/DP-1

echo "Trim \"$ORIGINAL_EDID_FILE\" to avoid mode switch issues upon hotplug trigger" >&2
"$(dirname "$0")"/trim_edid.sh "$ORIGINAL_EDID_FILE" "$TRIMMED_EDID_FILE"

echo "Writing edid from \"$TRIMMED_EDID_FILE\" to \"$D/edid_override\"" >&2
sudo sh -c "cat $TRIMMED_EDID_FILE > $D/edid_override"

echo "Set DP-1 to force=on" >&2
sudo sh -c "echo on > $D/force"

echo "Trigger hotplug" >&2
sudo sh -c "echo 1 > $D/trigger_hotplug"
