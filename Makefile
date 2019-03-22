#!/bin/bash
KEYINFO_FILE=$(HOME)/.irvinecubesat.keyInfo
KEYTOOL=scripts/opensslKeyTool.sh
# short host name
HOST_NAME=$(shell hostname -s)

$(KEYINFO_FILE):
	@$(KEYTOOL) -f $(KEYINFO_FILE) -i

genKeys: 
	$(MAKE) $(KEYINFO_FILE)
	@. $(KEYINFO_FILE); echo "Email the VPN administrator $$keyDir/$${keyName}.cert"

