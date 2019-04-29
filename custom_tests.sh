#!/bin/bash

EXIT_CODE=0
CURR_DIR=$(pwd)
TF_ENV=''

touch ~/.ssh/appuser.pub ~/.ssh/appuser

packer_check() {
  cd $CURR_DIR
  echo -e "Packer templates check"
  for f in packer/*.json; do
    if [ $f == "packer/variables.json" ]
    then
      continue
    fi
    echo -n "Validate: ---> $f "
    result="$(packer validate --var-file=packer/variables.json.example $f)"
    if grep -q "success" <<< $result
    then
      echo -e "OK"
    else {
      echo -e "FAIL: $f"
      echo "$result"
      EXIT_CODE=1
    }
    fi
  done
}

ansible_check() {
  echo
  echo -e "Ansible lint validation"
  if (ansible-lint ansible/playbooks/*.yml)
  then
    echo -e "OK"
  else {
    echo -e "FAIL"
    EXIT_CODE=1
  }
  fi
}

terraform_check() {
  echo -e "Terraform check "
  cd $CURR_DIR/terraform/$TF_ENV
  cp terraform.tfvars.example terraform.tfvars
  terraform init -backend=false
  result="$(terraform validate)"
  if grep -q "error:" <<< $result
  then {
    echo -e "FAIL"
    EXIT_CODE=1
  }
  else {
    echo -e "OK"
  }
  fi
  tflint
}

check_badge() {
  if grep -q "\[Build Status\]" README.md; then
    echo -e "Build status exists"
  else {
    echo -e "Build status does not exist"
    EXIT_CODE=1
  }
  fi
}

TF_ENV="stage"
terraform_check
TF_ENV="prod"
terraform_check
packer_check
ansible_check
check_badge
echo "Exit code: $EXIT_CODE"

exit $EXIT_CODE
