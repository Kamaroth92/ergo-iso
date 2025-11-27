#!/usr/bin/env bash

set -e -x

add-apt-repository --yes --update ppa:ansible/ansible
apt install --yes ansible
