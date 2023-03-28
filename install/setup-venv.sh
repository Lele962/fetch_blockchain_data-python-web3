#!/bin/bash

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install wheel

pip install pyyaml colorama requests semantic_version docker py-cpuinfo
