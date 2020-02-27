#!/usr/bin/env python3

import argparse
import toml
import os
from shutil import copyfile


def _parse_xud_docker_conf():
    with open("/root/.xud-docker/xud-docker.conf") as f:
        return toml.loads(f.read())


home_dir = os.environ["HOME_DIR"]
network = os.environ["NETWORK"]
network_dir = home_dir + "/" + network
backup_dir = None
restore_dir = None

copyfile("/usr/local/lib/python3.8/site-packages/launcher/config/xud-docker.conf", "/root/.xud-docker/sample-xud-docker.conf")

try:
    parsed = _parse_xud_docker_conf()
    network_dir = parsed.get(f"{network}-dir", network_dir)
except toml.TomlDecodeError as e:
    print("Failed to parse xud-docker.conf:", e)
    exit(1)
except:
    pass

parser = argparse.ArgumentParser(argument_default=argparse.SUPPRESS)
parser.add_argument(f"--{network}-dir")
args, unknown = parser.parse_known_args()

if hasattr(args, f"{network}_dir"):
    network_dir = getattr(args, f"{network}_dir")

print(f"NETWORK_DIR={network_dir}")
