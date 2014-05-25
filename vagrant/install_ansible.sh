#!/bin/bash
set -o errexit
yum -y install git python-devel python-setuptools sshpass
easy_install pip
pip install paramiko PyYAML jinja2 httplib2
if [ ! -d ansible ]
  then
  git clone git://github.com/ansible/ansible.git
fi

chown -R vagrant:vagrant ansible
cd ansible
git checkout v1.6.1

VAGRANTHOME="/home/vagrant"
if [[ ! -s "$VAGRANTHOME/.bash_profile" && -s "$VAGRANTHOME/.profile" ]] ; then
  profile_file="$VAGRANTHOME/.profile"
else
  profile_file="$VAGRANTHOME/.bash_profile"
fi

if ! grep -q 'ansible/hacking/env-setup' "${profile_file}" ; then
  echo "Editing ${profile_file} to load ansible on login"
  echo "source \"$VAGRANTHOME/ansible/hacking/env-setup\"" >> "${profile_file}"
fi

if ! grep -q 'EDITOR' "${profile_file}" ; then
  echo "Editing ${profile_file} to set editor"
  echo "export EDITOR=\"/bin/vi\"" >> "${profile_file}"
fi

KNOWN_HOSTS="$VAGRANTHOME/.ssh/known_hosts"
if ! grep -q '192.168.111.100' "${KNOWN_HOSTS}" ; then
  echo "Adding deployment to $KNOWN_HOSTS"
  ssh-keyscan 192.168.111.100 >> "${KNOWN_HOSTS}"
  chmod 600 ${KNOWN_HOSTS}
fi

if ! grep -q '192.168.111.101' "${KNOWN_HOSTS}" ; then
  echo "Adding deployment to $KNOWN_HOSTS"
  ssh-keyscan 192.168.111.101 >> "${KNOWN_HOSTS}"
  chmod 600 ${KNOWN_HOSTS}
fi

if [ ! -f "/home/vagrant/.ssh/id_rsa"  ] ; then
  ssh-keygen -f /home/vagrant/.ssh/id_rsa -b 2048 -t rsa -N ""
  chown -R vagrant:vagrant /home/vagrant/.ssh/
fi
