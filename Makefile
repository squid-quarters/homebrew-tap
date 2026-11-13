CASK := squid-quarters/tap/hyper-chamber@beta
CASK_FILE := Casks/hyper-chamber@beta.rb

.PHONY: check audit-online
check:
	ruby -c $(CASK_FILE)
	brew style $(CASK_FILE)
	brew audit --cask --strict --arch=all $(CASK)

audit-online: check
	brew audit --cask --strict --online --arch=all $(CASK)
