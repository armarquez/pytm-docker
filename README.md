# pytm-renderer

Putting [`pytm` threat modeling tool](https://github.com/izar/pytm) into a Docker container w/ a command runner to make rendering simplistic.

## Pre-reqs

### Software requirements

You will need the following to be installed:

- [just](https://github.com/casey/just#packages)
- [Docker](https://docs.docker.com/engine/install/)

### Creating pytm threat model

Write up your `pytm` threat model file.

If you are starting from fresh, you can utilize the `Makefile` to create your virtual environment:

```bash
$ pwd
~/pytm-renderer
$ make minimal
$ source venv/bin/activate
```

If you have a virtual environment that you would like to continue using, just install the Python requirements:

```bash
$ pwd
~/pytm-renderer
$ pip install -r requirements.txt
```

If you want to test this tool right away, you can use the `example/example-tm.py` file.

## Rendering

### Rendering Threat Model

Render threat model diagram to `.png` file using `just` recipes works by supplying the location of your `pytm` file. The path must be relative to top directory containing the `Justfile`. For example:

```bash
$ pwd
~/pytm-renderer
$ just create-dfd example/example-tm.py
```

This will create a data flow diagram as `.png` file output to `tm` folder next to specified `pytm` file:

```bash
$ pwd
~/pytm-renderer
$ tree example
example/
├── tm
│   └── example-tm.png
└── example-tm.py
```

### Help Menu

This repo uses [`just`](https://github.com/casey/just) command runner (think `make` but easier to create commands) to make things much easier for executing "recipes". To see what recipes are available to easily run:

```bash
$ pwd
~/pytm-renderer
$ just  # Which runs `just --list`
Available recipes:
    clean                  # clean up temporary files
    create-dfd PYTM_FILE   # creates data flow diagram as `.png` file output to `tm` folder next to `pytm` file
    create-dot PYTM_FILE   # creates GraphViz `.dot` file output to `tm` folder next to `pytm` file
    create-seq PYTM_FILE   # creates sequence diagram as `.png` file output to `tm` folder next to `pytm` file
    default                # default recipe to display help information
    docker-build ENV="dev" # build docker image env=dev
    docker-exec *ARGS="sh" # exec command in an existing dev docker container
    docker-run *ARGS="sh"  # run cmd in dev docker continer
    pytm-describe *ELEMENTS="TM Element Boundary ExternalEntity Actor Lambda Server Process SetOfProcesses Datastore Dataflow" # describe the properties available for given element(s)
    pytm-help              # print help dialog for pytm
    virtualenv             # ensure valid virtualenv
```
