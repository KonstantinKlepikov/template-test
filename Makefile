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
	@echo "MyBrilliantProject-dev:"
	@docker compose -f ./docker-compose/docker-stack.yml exec MyBrilliantProject-dev sh -c "cd .. && sh scripts/check.sh"

# target: config - show docker stack info
config:
	@echo "Services:"
	@docker compose -f ./docker-compose/docker-stack.yml config --services
	@echo "Volumes:"
	@docker compose -f ./docker-compose/docker-stack.yml config --volumes

# target: create - create a python file with optional prompt header
# Usage: make create path=src/module.py [pr=prompt1[,prompt2,...]]
create:
ifndef path
	$(error Argument --path is required. Usage: make create path=src/module.py)
endif
	@PARENT="$$(dirname "$(path)")"; \
	if [ ! -d "$$PARENT" ]; then \
		echo "Error: directory '$$PARENT' does not exist"; exit 1; \
	fi; \
	PROMPT_BLOCK=""; \
	if [ -n "$(pr)" ]; then \
		TMPBLOCK=$$(mktemp); \
		for name in $$(echo "$(pr)" | tr ',' ' '); do \
			PROMPT_FILE=$$(find prompts -maxdepth 1 \( -name "$$name.*" -o -name "$$name" \) 2>/dev/null | head -1); \
			if [ -z "$$PROMPT_FILE" ]; then \
				echo "Error: prompt file '$$name' not found in prompts/"; rm -f "$$TMPBLOCK"; exit 1; \
			fi; \
			printf '"""\n' >> "$$TMPBLOCK"; \
			cat "$$PROMPT_FILE" >> "$$TMPBLOCK"; \
			printf '"""\n' >> "$$TMPBLOCK"; \
		done; \
		PROMPT_BLOCK="$$TMPBLOCK"; \
	fi; \
	if [ -e "$(path)" ]; then \
		if [ -z "$(pr)" ]; then \
			echo "Error: file '$(path)' already exists"; exit 1; \
		fi; \
		TMPFILE=$$(mktemp); \
		awk -v pfile="$$PROMPT_BLOCK" 'BEGIN{b=0;d=0} !d&&/^"""$$/{if(b){b=0;h=h $$0"\n";next}else{b=1;h=h $$0"\n";next}} !d&&b{h=h $$0"\n";next} !d{d=1;printf "%s",h;while((getline l<pfile)>0)print l;print;next} {print} END{if(!d){printf "%s",h;while((getline l<pfile)>0)print l}}' "$(path)" > "$$TMPFILE" && mv "$$TMPFILE" "$(path)"; \
		rm -f "$$PROMPT_BLOCK"; \
		echo "Updated: $(path)"; \
	else \
		if [ -n "$(pr)" ]; then \
			cat "$$PROMPT_BLOCK" > "$(path)"; \
			rm -f "$$PROMPT_BLOCK"; \
		else \
			touch "$(path)"; \
		fi; \
		echo "Created: $(path)"; \
	fi

# target: clean - remove leading triple-quoted comment block from a python file
# Usage: make clean path=src/module.py
clean:
ifndef path
	$(error Argument path is required. Usage: make clean path=src/module.py)
endif
	@if [ ! -f "$(path)" ]; then \
		echo "Error: file '$(path)' does not exist"; exit 1; \
	fi; \
	sed -i '/^"""/,/^"""/d' "$(path)"; \
	sed -i '/./,$$!d' "$(path)"; \
	echo "Cleaned: $(path)"
