#!/bin/bash
set -e

red="\e[1;31m"
green="\e[1;32m"
blink="\e[1;31m"
NC="\e[0m" # No Color

function info {
  echo -e "${green}INFO: ${NC} $1"
}
function warn {
  echo -e "${blink}WARN: ${NC} $1"
}
function error {
  echo -e "${red}ERROR: ${NC} $1"
}

CONFIG=$1

VERSION_CFG="https://raw.githubusercontent.com/eea/eea.plonebuildout.core/master/latest/versions.cfg"

PIP=$(curl -sSL $VERSION_CFG | grep "^pip\s*=\s*" | sed 's/ *//g' | sed 's/^.*\=\s*//g')
SETUPTOOLS=$(curl -sSL $VERSION_CFG | grep "^setuptools\s*\=\s*" | sed 's/ *//g' | sed 's/=//g' | sed 's/[a-z]//g')
ZCBUILDOUT=$(curl -sSL $VERSION_CFG | grep "^zc\.buildout\s*=\s*" | sed 's/ *//g' | sed 's/^.*\=\s*//g')
WHEEL=$(curl -sSL $VERSION_CFG | grep "^wheel\s*=\s*" | sed 's/ *//g' | sed 's/^.*\=\s*//g')

if [ -z "$CONFIG" ]; then
  if [ -s "development.cfg" ]; then
    CONFIG="development.cfg"
  else
    CONFIG="buildout.cfg"
  fi
fi

#echo -e "${green}"
info "Using $CONFIG"

if [ -z "$PIP" ]; then
  PIP="9.0.1"
fi

info "Using pip $PIP"

if [ -z "$SETUPTOOLS" ]; then
  SETUPTOOLS="33.1.1"
fi

info "Using setuptools $SETUPTOOLS"

if [ -z "$ZCBUILDOUT" ]; then
  ZCBUILDOUT="2.9.5"
fi

info "Using zc.buildout $ZCBUILDOUT"

if [ -z "$WHEEL" ]; then
  WHEEL="0.29.0"
fi

info "Using wheel $WHEEL"

if [ -z "$PYTHON" ]; then
  PYTHON="/usr/bin/env python2.7"
fi

# Make sure python is 2.7 or later
PYTHON_OK=`$PYTHON -c 'import sys
print (sys.version_info >= (2, 7) and "1" or "0")'`

if [ "$PYTHON_OK" = '0' ]; then
    error "Python 2.7 or later is required"
    error "EXAMPLE USAGE: PYTHON=/path/to/python2.7 ./install.sh"
    exit 0
fi

info "Using Python: "
$($PYTHON --version)

info "Create venv"
virtualenv -p2 venv

info "Running: venv/bin/pip install pip==$PIP setuptools==$SETUPTOOLS zc.buildout==$ZCBUILDOUT wheel==$WHEEL"
./venv/bin/pip install pip==$PIP setuptools==$SETUPTOOLS zc.buildout==$ZCBUILDOUT wheel==$WHEEL

echo ""
echo "========================================================================="
info "All set. Now you can run ./venv/bin/buildout -c $CONFIG"
echo "========================================================================="
echo ""
