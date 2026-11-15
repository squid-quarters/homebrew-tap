CASKS := squid-quarters/tap/hyper-chamber squid-quarters/tap/hyper-chamber@beta
CASK_FILES := Casks/hyper-chamber.rb Casks/hyper-chamber@beta.rb

.PHONY: check audit-online
check:
	ruby -c Casks/hyper-chamber.rb
	ruby -c Casks/hyper-chamber@beta.rb
	brew style $(CASK_FILES)
	brew audit --cask --strict --arch=all $(CASKS)

audit-online: check
	brew audit --cask --strict --online --arch=all $(CASKS)
