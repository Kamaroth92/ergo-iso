#!/usr/bin/env bash

set -e -x

cat <<EOF >/etc/multipath.conf
defaults {
    user_friendly_names yes
    find_multipaths yes
}
EOF
