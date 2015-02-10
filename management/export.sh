#!/bin/bash

# Set DEBUG=true if you want to skip operations
# that take a long time

BASE_DIR=$(pwd)
OUTPUT_DIR=$BASE_DIR/archive
VAGRANT_DIR=$BASE_DIR/.vagrant/machines/default/virtualbox

if $DEBUG; then
    echo "DEBUG MODE IS ON: this is a dry run."
fi

echo "Exporting Vagrant setup from $BASE_DIR"

# Get the VM ID
# List all VMs, filter by PARTIAL_NAME, get the UUID column, strip braces
PARTIAL_NAME=$(cat $VAGRANT_DIR/action_set_name)
VM_ID=$(VBoxManage list vms | \
        grep "$PARTIAL_NAME" | \
        awk '{print $2}' | \
        sed 's/[{,}]//g')

# Export the OVA
echo "Exporting VirtualBox VM $VM_ID"
mkdir -p $OUTPUT_DIR

if ! $DEBUG; then
    VBoxManage export $VM_ID -o $OUTPUT_DIR/virtualbox.ova
fi

# Export the Vagrant Box
echo "Packaging Vagrant Box"
if ! $DEBUG; then
    # TODO(samstern): make this more general
    vagrant box repackage "ubuntu/trusty32" "virtualbox" "14.04"
    mv $BASE_DIR/package.box $OUTPUT_DIR
fi

# Export the interesting vagrant files
echo "Exporting .vagrant files"
cp $VAGRANT_DIR/private_key $OUTPUT_DIR
cp $VAGRANT_DIR/action_set_name $OUTPUT_DIR
