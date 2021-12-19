#!/bin/bash
# Who:           When:         What:  
# Janusz Kujawa  06/01/2021    Initialize script
# Janusz Kujawa  08/01/2021    Added loadbalancer function for provision LB based on HAProxy
# Janusz Kujawa  16/01/2021    Added case for lack of arguments and option.
#                              Added cleanup ansible/ssk-keys dir
# Janusz Kujawa  19/12/2021    Addopt script for using together with Vanillastack

usage() {                                     
   echo
   echo "Syntax: $0  [-h|d|k|o|s]"
   echo "options:"
   echo "h          Print help available options"
   echo "d          Destroy k8s HandsON LAB"
   echo "k          Start k8s part only"
   echo "o          Start k8s openstack part only"
   echo "s          Print vms status"
   echo
   exit 0
}

no_option() {                            
  usage
  exit 1
}

function func_prov_k8s {
  echo ">>>>>>>> K8S Provisioner <<<<<<"
  vagrant up k8s-00 k8s-01 k8s-02 k8s-03
  echo "========END PROVISIONER========"
}

function func_prov_openstack {
  echo ">>> OpenStack Provisioner <<<"
  vagrant up infra-00 infra-01 infra-02
  echo "========END PROVISIONER========"
}

function func_destroy {
  echo ">>> Destroy all vms <<<"
  vagrant destroy -f
  echo "========END PROVISIONER========"
}

function func_status {
  echo ">>> Status running vms <<<"
  vagrant status
  echo "========END PROVISIONER========"
}

if [[ $# -eq 0 ]] ; then
    echo "!!! No argument and option given !!!"
    no_option
    exit 0
fi

while getopts "hdkos" options; do            
                                                                                        
  case $options in                          
    h)
      usage                                        
      ;;
    d)
      func_destroy
      ;;
    k)
      func_prov_k8s
      ;;
    o)
      func_prov_openstack
      ;;
    s) 
      func_status
      ;;
    *)                                        
      no_option                           
      ;;
  esac
done