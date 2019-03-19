#!/bin/bash
KEYINFO_FILE=$(HOME)/.irvinecubesat.keyInfo
KEYTOOL=scripts/opensslKeyTool.sh
# short host name
HOST_NAME=$(shell hostname -s)

$(KEYINFO_FILE):
	@$(KEYTOOL) -f $(KEYINFO_FILE) -g $$USER-$(HOST_NAME)-irvinecubesat

genKeys: 
	$(MAKE) $(KEYINFO_FILE)
	scripts/cubeSatNetSetupRequest.sh
