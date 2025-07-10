#!/usr/bin/env bash

set -e -x

# Hardcode server install but only start agent during provisioning if agent is selected
INSTALL_RKE2_TYPE="server"
CNI_PLUGIN_VERSION=1.7.1
ETCD_VER=v3.5.2

INSTALL_RKE2_ARTIFACT_PATH=$COMMON_DIR/rke2 \
	INSTALL_RKE2_TYPE=$INSTALL_RKE2_TYPE \
	INSTALL_RKE2_AGENT_IMAGES_DIR=$COMMON_DIR/rke2/images \
	sh $COMMON_DIR/rke2/install.sh

ln -s /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl
ln -s /var/lib/rancher/rke2/bin/crictl /usr/local/bin/crictl
ln -s /var/lib/rancher/rke2/bin/ctr /usr/local/bin/ctr

echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >>/etc/profile.d/rke2.sh
chmod 644 /etc/profile.d/rke2.sh

mkdir -p /etc/rancher/rke2/config.yaml.d

cp $FILES_DIR/rke2/configs/[0-9]*.yaml /etc/rancher/rke2/config.yaml.d/
for f in /etc/rancher/rke2/config.yaml.d/*.yaml; do
	[ -e "$f" ] && mv "$f" "${f}-disabled"
done

cp $FILES_DIR/rke2/configs/registries.yaml /etc/rancher/rke2/registries.yaml
sed -i "s|%HARBOR_IMAGE_MIRROR_USERNAME%|$HARBOR_IMAGE_MIRROR_USERNAME|g" /etc/rancher/rke2/registries.yaml
sed -i "s|%HARBOR_IMAGE_MIRROR_PASSWORD%|$HARBOR_IMAGE_MIRROR_PASSWORD|g" /etc/rancher/rke2/registries.yaml
sed -i "s|%HARBOR_IMAGE_MIRROR_REGISTRY%|$HARBOR_IMAGE_MIRROR_REGISTRY|g" /etc/rancher/rke2/registries.yaml

systemctl disable rke2-server.service
systemctl disable rke2-agent.service

# Copy rke2-switch-install
cp $FILES_DIR/rke2/bin/rke2-switch-install.sh /ergo/bin/rke2-switch-install
chmod +x /ergo/bin/rke2-switch-install
ln -s /ergo/bin/rke2-switch-install /usr/local/bin/rke2-switch-install
cat <<EOF >/etc/sudoers.d/rke2-switch-install
administrator ALL = (ALL) NOPASSWD: /usr/local/bin/rke2-switch-install
EOF

# Download CNI Plugins
wget https://github.com/containernetworking/plugins/releases/download/v$CNI_PLUGIN_VERSION/cni-plugins-linux-amd64-v$CNI_PLUGIN_VERSION.tgz -O /tmp/cni-plugins-linux.tgz
mkdir -p /opt/cni/bin
tar xvfz /tmp/cni-plugins-linux.tgz -C /opt/cni/bin

# Download etcdctl
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test
curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
cp /tmp/etcd-download-test/{etcd,etcdctl,etcdutl} /usr/local/bin/

echo 'export ETCDCTL_CACERT=/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt' >>/etc/profile.d/rke2.sh
echo 'export ETCDCTL_CERT=/var/lib/rancher/rke2/server/tls/etcd/server-client.crt' >>/etc/profile.d/rke2.sh
echo 'export ETCDCTL_KEY=/var/lib/rancher/rke2/server/tls/etcd/server-client.key' >>/etc/profile.d/rke2.sh
echo 'export ETCDCTL_ENDPOINTS="https://127.0.0.1:2379"' >>/etc/profile.d/rke2.sh
echo 'export ETCDCTL_API=3' >>/etc/profile.d/rke2.sh

# Register provisioner tasks
cp $FILES_DIR/rke2/provisioner/* $PROVISIONER_CONFIGS

# Additional deps
source $FILES_DIR/rke2/democratic-csi-deps.sh
