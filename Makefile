# target: all - Default target. Does nothing.
all:
	@echo "Hello, this is make for tiny-rewards-tg"
	@echo "Try 'make help' and search available options"

# target: help - List of options
help:
	@egrep "^# target:" [Mm]akefile

# target: serve dev - run docker-compose
serve:
	@sh ./docker-compose/up-dev.sh

# target: down - stop and down docker stack
down:
	@docker compose -f ./docker-compose/docker-stack.yml down

# target: down-rm - stop and down docker stack, then remove all images
down-rm:
	@docker compose -f ./docker-compose/docker-stack.yml down --rmi al

# target: check - run tests, mypy and flake8
check:
	@echo "py-project-template-dev:"
	@docker compose -f ./docker-compose/docker-stack.yml exec py-project-template-dev sh -c "cd .. && sh scripts/check.sh"

# target: config - show docker stack info
config:
	@echo "Services:"
	@docker compose -f ./docker-compose/docker-stack.yml config --services
	@echo "Volumes:"
	@docker compose -f ./docker-compose/docker-stack.yml config --volumes

# target: create - create a python file with optional prompt header
# Usage: make create --path=src/module.py [--pr=prompt_name]
create:
ifndef path
	$(error Argument --path is required. Usage: make create --path=src/module.py)
endif
	@PARENT="$$(dirname "$(path)")"; \
	if [ ! -d "$$PARENT" ]; then \
		echo "Error: directory '$$PARENT' does not exist"; exit 1; \
	fi; \
	if [ -e "$(path)" ]; then \
		echo "Error: file '$(path)' already exists"; exit 1; \
	fi; \
	if [ -n "$(pr)" ]; then \
		PROMPT_FILE=$$(find prompts -maxdepth 1 \( -name "$(pr).*" -o -name "$(pr)" \) 2>/dev/null | head -1); \
		if [ -z "$$PROMPT_FILE" ]; then \
			echo "Error: prompt file '$(pr)' not found in prompts/"; exit 1; \
		fi; \
		printf '"""\n' > "$(path)"; \
		cat "$$PROMPT_FILE" >> "$(path)"; \
		printf '"""\n' >> "$(path)"; \
	else \
		touch "$(path)"; \
	fi; \
	echo "Created: $(path)"

# target: rename - replace 'py-project-template' with --to value in key project files
# Usage: make rename --to=my-new-name
rename:
ifndef to
	$(error Argument --to is required. Usage: make rename --to=my-new-name)
endif
	@sed -i 's/py-project-template/$(to)/g' \
		AGENTS.md \
		Makefile \
		pyproject.toml \
		README.md \
		docker-compose/docker-compose.dev.yml
	@sed -i '/^# target: rename/,$$d' Makefile
