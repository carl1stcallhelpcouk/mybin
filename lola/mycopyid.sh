#!/bin/bash
ssh-keygen -t rsa -b 4096
ssh-copy-id pi
ssh-copy-id dell-server
ssh-copy-id nas
ssh-copy-id gw
