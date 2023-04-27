ARG PYTHON_VERSION=3.10
ARG ALPINE_VERSION=3.14

# define an alias for the specfic python version used in this file.
FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS base

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1
ENV PLANTUML_VER 1.2021.7
ENV PLANTUML_PATH /usr/local/lib/plantuml.jar
ENV PANDOC_VER 2.14.0.1

# Python build stage
FROM base AS python-build-stage

# Install pipenv and compilation dependencies
RUN pip install pipenv
RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && rm -rf /var/cache/apk/*

# Install python dependencies in /.venv
COPY Pipfile .
COPY Pipfile.lock .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy


# Runtime stage
FROM base AS runtime

# Install other packages necessary runtime operations
RUN apk add --no-cache graphviz openjdk11-jre fontconfig make curl ttf-liberation ttf-linux-libertine ttf-dejavu \
    && rm -rf /var/cache/apk/* \
    && curl -LO https://netix.dl.sourceforge.net/project/plantuml/$PLANTUML_VER/plantuml.$PLANTUML_VER.jar \
    && mv plantuml.$PLANTUML_VER.jar $PLANTUML_PATH \
    && curl -LO https://github.com/jgm/pandoc/releases/download/$PANDOC_VER/pandoc-$PANDOC_VER-linux-amd64.tar.gz \
    && tar xvzf pandoc-$PANDOC_VER-linux-amd64.tar.gz --strip-components 1 -C /usr/local/

# Test out Plantuml installation
ENV _JAVA_OPTIONS -Duser.home=/tmp -Dawt.useSystemAAFontSettings=gasp
RUN printf '@startuml\n@enduml' | java -Djava.awt.headless=true -jar $PLANTUML_PATH -tpng -pipe >/dev/null

# Copy virtual env from python-build-stage stage
COPY --from=python-build-stage /.venv /.venv
ENV PATH="/.venv/bin:$PATH" VIRTUAL_ENV=/.venv/

# Create and switch to a new user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
#WORKDIR /home/appuser
USER appuser

# Set the workdir
WORKDIR /usr/src/app
VOLUME /usr/src/app

# Copy application files
COPY . /usr/src/app

# Override ENTRYPOINT rather than CMD so we can pass arbitrary commands to the entrypoint script
ENTRYPOINT ["/usr/src/app/docker/entrypoint.sh"]
