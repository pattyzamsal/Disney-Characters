SHELL := /bin/bash

.PHONY: install generate open mocks lint help

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install required tools and generate the Xcode project (run this first)
	@echo "→ Installing tools (xcodegen, swiftlint, sourcery)..."
	@brew install xcodegen swiftlint sourcery
	@$(MAKE) generate
	@echo ""
	@echo "✓ Setup complete. Run 'make open' to open the project in Xcode."

generate: ## Regenerate the Xcode project from project.yml
	@echo "→ Generating Xcode project..."
	@cd "Disney Characters" && xcodegen generate
	@echo "✓ Project generated at Disney Characters/DisneyCharacters.xcodeproj"

open: ## Open the project in Xcode
	@open "Disney Characters/DisneyCharacters.xcodeproj"

mocks: ## Regenerate Sourcery mocks after protocol changes
	@echo "→ Regenerating mocks..."
	@sourcery \
		--sources "Disney Characters/DisneyCharacters" \
		--templates Templates/AutoMockable.stencil \
		--output "Disney Characters/DisneyCharactersTests/Mocks/Generated"
	@echo "✓ Mocks regenerated."

lint: ## Run SwiftLint
	@swiftlint --config .swiftlint.yml

.DEFAULT_GOAL := help
