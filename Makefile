.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "minimal      do minimal amount to set up Python environment for writing pytm threat models"

.PHONY: minimal
minimal: venv/bin/activate
venv/bin/activate: requirements.txt
	test -d venv || python3 -m venv venv
	venv/bin/pip install -r requirements.txt
	touch venv/bin/activate
