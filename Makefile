.DEFAULT_GOAL := help

.PHONY: help fmt lint smoke check

help: ## list every target
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-8s %s\n", $$1, $$2}'

fmt: ## format every Lua file with stylua
	stylua .

lint: ## fail if a Lua file is not formatted
	stylua --check .

# -c runs before VimEnter, so the check waits for the doormat to open
smoke: ## start a bare nvim headless and check the doormat opens
	nvim --clean --headless --cmd "set rtp^=." -c "lua vim.schedule(function() dofile('scripts/smoke.lua') end)"

check: fmt lint smoke ## the gate before any commit
