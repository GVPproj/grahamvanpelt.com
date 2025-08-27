# Tools
GO_BIN := $(shell which go)
AIR_BIN := $(shell which air)
TEMPL_BIN := $(shell which templ)

# Project info
PROJECT_NAME := $(shell basename $(CURDIR))
STATIC_DIR := static

# Build configuration
BUILD_DIR := build
MAIN_GO := cmd/$(PROJECT_NAME)/main.go
TEMPL_FILES := $(shell find . -type f -name "*.templ")
TEMPL_GO_FILES := $(TEMPL_FILES:.templ=_templ.go)

# Simple color scheme
CYAN := \033[36m
DIM := \033[2m
RESET := \033[0m

# Basic symbols
CHECK := ✓
ARROW := →

# Air configuration
AIR_CONFIG := 'root = "."\n\
testdata_dir = "testdata"\n\
tmp_dir = "tmp"\n\
\n\
[build]\n\
  args_bin = ["serve"]\n\
  bin = "./tmp/$(PROJECT_NAME)"\n\
  cmd = "templ generate && go build -o ./tmp/$(PROJECT_NAME) ./$(MAIN_GO)"\n\
  delay = 1000\n\
  exclude_dir = ["assets", "tmp", "vendor", "testdata", "node_modules"]\n\
  exclude_file = []\n\
  exclude_regex = ["_test.go", ".*_templ.go"]\n\
  exclude_unchanged = false\n\
  follow_symlink = false\n\
  full_bin = ""\n\
  include_dir = []\n\
  include_ext = ["go", "tpl", "tmpl", "templ", "html", "css", "js"]\n\
  include_file = []\n\
  kill_delay = "0s"\n\
  log = "build-errors.log"\n\
  poll = false\n\
  poll_interval = 0\n\
  rerun = true\n\
  rerun_delay = 500\n\
  send_interrupt = false\n\
  stop_on_root = false\n\
\n\
[color]\n\
  app = ""\n\
  build = "yellow"\n\
  main = "magenta"\n\
  runner = "green"\n\
  watcher = "cyan"\n\
\n\
[log]\n\
  main_only = false\n\
\n\
[misc]\n\
  clean_on_exit = false\n\
\n\
[screen]\n\
  clear_on_rebuild = false\n\
  keep_scroll = true'

.PHONY: check-deps init create-dirs setup-go setup-css setup-air build serve dev watch clean help templ

check-deps:
	@printf "\n$(CYAN)Checking dependencies$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@test -n "$(GO_BIN)" || (printf "✗ Go not installed\n" && exit 1)
	@test -n "$(TEMPL_BIN)" || (printf "✗ templ not installed\n" && exit 1)
	@printf "$(CHECK) Core dependencies ready\n"
	@if [ -z "$(AIR_BIN)" ]; then \
		printf "$(DIM)Installing Air for hot-reload...$(RESET)\n"; \
		go install github.com/cosmtrek/air@latest; \
	fi
	@printf "$(CHECK) All dependencies ready\n"

create-dirs:
	@printf "\n$(CYAN)Creating project structure$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@mkdir -p $(STATIC_DIR)/js
	@mkdir -p $(STATIC_DIR)/css
	@mkdir -p views/components
	@mkdir -p views/layouts
	@mkdir -p views/pages
	@mkdir -p internal/handler
	@mkdir -p internal/middleware
	@mkdir -p internal/model
	@mkdir -p internal/service
	@mkdir -p internal/util
	@mkdir -p cmd/$(PROJECT_NAME)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p tmp
	@echo "package main\n\nfunc main() {\n\t// TODO: Initialize your server here\n}" > cmd/$(PROJECT_NAME)/main.go
	@echo "package handler" > internal/handler/handler.go
	@echo "package middleware" > internal/middleware/middleware.go
	@echo "package model" > internal/model/model.go
	@echo "package service" > internal/service/service.go
	@echo "package util" > internal/util/util.go
	@echo "// Base layout component" > views/layouts/BaseLayout.templ
	@echo "// Navigation component" > views/components/Navbar.templ
	@echo "// Home page component" > views/pages/HomePage.templ
	@printf "$(CHECK) Project structure created\n"

setup-go:
	@printf "\n$(CYAN)Initializing Go module$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@$(GO_BIN) mod init $(PROJECT_NAME) 2>/dev/null || true
	@$(GO_BIN) mod tidy >/dev/null 2>&1
	@printf "$(CHECK) Go modules ready\n"

setup-css:
	@printf "\n$(CYAN)Setting up CSS$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@echo "/* Reset and base styles */" > $(STATIC_DIR)/css/styles.css
	@echo "* {" >> $(STATIC_DIR)/css/styles.css
	@echo "    box-sizing: border-box;" >> $(STATIC_DIR)/css/styles.css
	@echo "    margin: 0;" >> $(STATIC_DIR)/css/styles.css
	@echo "    padding: 0;" >> $(STATIC_DIR)/css/styles.css
	@echo "}" >> $(STATIC_DIR)/css/styles.css
	@echo "" >> $(STATIC_DIR)/css/styles.css
	@echo "body {" >> $(STATIC_DIR)/css/styles.css
	@echo "    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;" >> $(STATIC_DIR)/css/styles.css
	@echo "    line-height: 1.6;" >> $(STATIC_DIR)/css/styles.css
	@echo "    color: #333;" >> $(STATIC_DIR)/css/styles.css
	@echo "}" >> $(STATIC_DIR)/css/styles.css
	@echo "" >> $(STATIC_DIR)/css/styles.css
	@echo "/* Add your custom styles here */" >> $(STATIC_DIR)/css/styles.css
	@printf "$(CHECK) CSS setup complete\n"

setup-air:
	@printf "\n$(CYAN)Setting up Air configuration$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@echo $(AIR_CONFIG) > .air.toml
	@printf "$(CHECK) Air configuration ready\n"

build: check-deps
	@printf "\n$(CYAN)Building project$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@$(GO_BIN) build -o $(BUILD_DIR)/$(PROJECT_NAME) $(MAIN_GO)
	@printf "$(CHECK) Build complete\n"

templ:
	@printf "\n$(CYAN)Generating templ files$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@$(TEMPL_BIN) generate
	@printf "$(CHECK) Templ files generated\n"

serve: templ
	@printf "\n$(CYAN)Starting server$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@$(GO_BIN) run $(MAIN_GO) serve 

dev: check-deps setup-air
	@printf "\n$(CYAN)Starting development server with hot-reload$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@printf "$(DIM)Watching: Go files, templ files, CSS, and JS$(RESET)\n"
	@air

watch:
	@printf "\n$(CYAN)Watching for changes (fallback method)$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@printf "$(DIM)Tip: Use 'make dev' for better hot-reload with Air$(RESET)\n"
	@find views -type f -name "*.templ" | entr -r make serve

clean:
	@printf "\n$(CYAN)Cleaning build files$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@rm -rf $(BUILD_DIR)
	@rm -rf tmp
	@find . -type f -name "*_templ.go" -delete
	@printf "$(CHECK) Clean complete\n"

init: check-deps create-dirs setup-go setup-css setup-air
	@printf "\n$(CHECK) Project setup complete!\n"
	@printf "\n$(CYAN)Next steps:$(RESET)\n"
	@printf "  $(ARROW) Run '$(CYAN)make dev$(RESET)' to start development server with hot-reload\n"
	@printf "  $(ARROW) Edit files in views/ and see changes instantly\n"

test:
	@printf "\n$(CYAN)Running tests$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@$(GO_BIN) test -v -count=1 -cover ./...

source:
	@printf "\n$(CYAN)Loading environment variables (dotenv)$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@export $(cat .env | xargs)
	@printf "\n$(CHECK) Environment variables loaded\n"

sync:
	@printf "\n$(CYAN)Running browser-sync$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@printf "$(DIM)Note: Use 'make dev' for better hot-reload with Air$(RESET)\n"
	@browser-sync start --proxy "localhost:8090" --files "views/**/*.templ,static/css/*.css"

help:
	@printf "\n$(CYAN)Available commands$(RESET)\n"
	@printf "$(DIM)────────────────────────────────────$(RESET)\n"
	@printf "  make init$(RESET)          $(ARROW) Initialize project\n"
	@printf "  make dev$(RESET)           $(ARROW) Start development server (hot-reload)\n"
	@printf "  make build$(RESET)         $(ARROW) Build project\n"
	@printf "  make serve$(RESET)         $(ARROW) Start server (no hot-reload)\n"
	@printf "  make watch$(RESET)         $(ARROW) Watch for changes (fallback)\n"
	@printf "  make clean$(RESET)         $(ARROW) Clean build files\n"
	@printf "  make source$(RESET)        $(ARROW) Load environment variables\n"
	@printf "  make sync$(RESET)          $(ARROW) run browser-sync (alternative)\n"
	@printf "  make test$(RESET)          $(ARROW) Run tests\n\n"
	@printf "$(CYAN)Recommended workflow:$(RESET)\n"
	@printf "  1. $(CYAN)make init$(RESET) - Set up project\n"
	@printf "  2. $(CYAN)make dev$(RESET)  - Start developing with hot-reload\n\n"
