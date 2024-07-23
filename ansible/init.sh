#!/bin/bash

ANSIBLE_VERSION=2.17

if [ -z "$(command -v apt-get)" ]; then
    echo
    echo "?Currently, eddie only support apt-base systems e.g. Ubuntu"
    echo
    exit 1
fi

sudo apt-get install -y python3-pip curl wget
if [ $? != 0 ]; then
    echo
    echo "?Could not install python3-pip, curl, wget"
    echo
    exit 1
fi

if [ -z "$(command -v ansible)" ]; then
    sudo pip3 install --upgrade -I ansible-core==2.17
    if [ $? != 0 ]; then
        echo
        echo "?Could not install ansible"
        echo
        exit 1
    fi
fi

if [ -z "$(command -v terraform)" ]; then
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    if [ $? != 0 ]; then
        echo
        echo "?Could not install hashicorp keyring"
        echo
        exit 1
    fi
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    if [ $? != 0 ]; then
        echo
        echo "?Could not install hashicorp deb repo"
        echo
        exit 1
    fi

    sudo apt update && sudo apt install terraform
    if [ $? != 0 ]; then
        echo
        echo "?Could not install terraform"
        echo
        exit 1
    fi
fi


if [ ! -e /usr/local/bin/gocmd ]; then
    GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt)
    curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -
    if [ $? != 0 ]; then
        echo
        echo "?Could not install gocmds"
        echo
        exit 1
    fi
    chmod a+x gocmd
    sudo mv gocmd /usr/local/bin
fi

echo
echo "### Finished with eddie init.sh ###"
echo


