#!/usr/bin/env just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.

# use with https://github.com/casey/just

export VIRTUAL_ENV  := env_var_or_default("VIRTUAL_ENV", "venv")
export BIN := VIRTUAL_ENV + "/bin"
export PIP := BIN + "/python -m pip"

# enforce our chosen pip compile flags
export COMPILE := BIN + "/pip-compile --allow-unsafe --generate-hashes"

# Setup the current user
export DOCKER_USERID := `id -u`
export DOCKER_GROUPID := `id -g`
export CURRENT_USER := DOCKER_USERID + ":" + DOCKER_GROUPID

export PLANTUML_PATH := "/usr/local/lib/plantuml.jar"

# Load .env files by default
set dotenv-load := true


# VARIABLES
outdir := "tm"


# default recipe to display help information
default:
    @{{ just_executable() }} --list


# clean up temporary files
clean:
    rm -rf venv


# ensure valid virtualenv
virtualenv:
    #!/usr/bin/env bash
    # allow users to specify python version in .env
    PYTHON_VERSION=${PYTHON_VERSION:-python3.10}

    # create venv and upgrade pip
    test -d $VIRTUAL_ENV || { $PYTHON_VERSION -m venv $VIRTUAL_ENV && $PIP install --upgrade pip; }

    # ensure we have pip-tools so we can run pip-compile
    test -e $BIN/pip-compile || $PIP install pip-tools


# Private recipe: Make output directory
_mk-outputdir DIR:
    @mkdir -p {{ DIR }}


# creates GraphViz `.dot` file output to `tm` folder next to `pytm` file
create-dot PYTM_FILE:
    #!/usr/bin/env bash

    # use Bash strict mode - http://redsymbol.net/articles/unofficial-bash-strict-mode/
    set -euo pipefail

    # set variables to make things a bit cleaner
    TM_DIR={{ clean(join(parent_directory(PYTM_FILE), outdir)) }}
    DOT_FILE={{ clean(join(parent_directory(PYTM_FILE), outdir, file_stem(PYTM_FILE))) }}.dot

    {{ just_executable() }} _mk-outputdir ${TM_DIR}
    {{ just_executable() }} docker/run "sh -c 'python {{ PYTM_FILE }} --dfd > ./${DOT_FILE}'"
    echo "--> CREATED '${DOT_FILE}'"


# creates data flow diagram as `.png` file output to `tm` folder next to `pytm` file
create-dfd PYTM_FILE:
    #!/usr/bin/env bash

    # use Bash strict mode - http://redsymbol.net/articles/unofficial-bash-strict-mode/
    set -euo pipefail

    # set variables to make things a bit cleaner
    TM_DIR={{ clean(join(parent_directory(PYTM_FILE), outdir)) }}
    DFD_FILE={{ clean(join(parent_directory(PYTM_FILE), outdir, file_stem(PYTM_FILE))) }}-dfd.png

    {{ just_executable() }} _mk-outputdir ${TM_DIR}
    {{ just_executable() }} docker/run "sh -c 'python {{ PYTM_FILE }} --dfd | dot -Tpng -o ${DFD_FILE}'"
    echo "--> CREATED '${DFD_FILE}'"


# creates sequence diagram as `.png` file output to `tm` folder next to `pytm` file
create-seq PYTM_FILE:
    #!/usr/bin/env bash

    # use Bash strict mode - http://redsymbol.net/articles/unofficial-bash-strict-mode/
    set -euo pipefail

    # set variables to make things a bit cleaner
    TM_DIR={{ clean(join(parent_directory(PYTM_FILE), outdir)) }}
    SEQ_FILE={{ clean(join(parent_directory(PYTM_FILE), outdir, file_stem(PYTM_FILE))) }}-seq.png

    {{ just_executable() }} _mk-outputdir ${TM_DIR}
    {{ just_executable() }} docker/run "sh -c 'python {{ PYTM_FILE }} --seq | java -Djava.awt.headless=true -jar $PLANTUML_PATH -tpng -pipe > ${SEQ_FILE}'"
    echo "--> CREATED '${SEQ_FILE}'"


# describe the properties available for given element(s)
pytm-describe *ELEMENTS="TM Element Boundary ExternalEntity Actor Lambda Server Process SetOfProcesses Datastore Dataflow":
    #!/usr/bin/env bash
    {{ just_executable() }} docker/run "python example-tm.py --describe '{{ ELEMENTS }}'"


# print help dialog for pytm
pytm-help:
    #!/usr/bin/env bash
    {{ just_executable() }} docker/run "python example-tm.py --help"


# build docker image env=dev
docker-build ENV="dev":
    {{ just_executable() }} docker/build {{ ENV }}


# run cmd in dev docker continer
docker-run *ARGS="sh":
    {{ just_executable() }} docker/run {{ ARGS }}


# exec command in an existing dev docker container
docker-exec *ARGS="sh":
    {{ just_executable() }} docker/exec {{ ARGS }}
