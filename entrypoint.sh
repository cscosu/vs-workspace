#!/usr/bin/env bash

fnm use 20

sudo dockerd &
/usr/bin/entrypoint.sh --bind-addr 0.0.0.0:8080 /home/coder/workspace
