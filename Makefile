OUTPUT_DIR := $(CURDIR)/output

.PHONY: build clean clean-pyc lint lint-lax test

clean:
	@rm -rf $(OUTPUT_DIR)/*

build:
	@$(MAKE) clean
	@$(CURDIR)/build.sh

deploy:
	@$(CURDIR)/deploy.sh

