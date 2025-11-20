# vim:set ft=dockerfile:

# THIS IS A (SLIGHTLY TWEAKED) copy of the official dockerfile at:
#   https://github.com/CircleCI-Public/cimg-python/blob/main/3.11/Dockerfile
# Care should be taken to keep this inline with that source file.
# Tweaks here are marked with "# TWEAK:"

FROM cimg/base:2025.11

# TWEAK: custom maintainer
LABEL maintainer="Rob Brackett (https://github.com/Mr0grog)"

# TWEAK: use arg for PYTHON_VERSION so there's less repetition.
ARG ARG_PYTHON_VERSION
ENV PYENV_ROOT=/home/circleci/.pyenv \
	PATH=/home/circleci/.pyenv/shims:/home/circleci/.pyenv/bin:/home/circleci/.poetry/bin:$PATH \
	PYTHON_VERSION=$ARG_PYTHON_VERSION \
	PIPENV_DEFAULT_PYTHON_VERSION=$ARG_PYTHON_VERSION

RUN sudo apt-get update && sudo apt-get install -y \
		build-essential \
		ca-certificates \
		curl \
		git \
		libbz2-dev \
		liblzma-dev \
		libncurses5-dev \
		libncursesw5-dev \
		libreadline-dev \
		libffi-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		libxmlsec1-dev \
		llvm \
		make \
		python3-openssl \
		tk-dev \
		wget \
		xz-utils \
		zlib1g-dev && \
	curl -sSL "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" | bash && \
	sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# TWEAK: use $PYTHON_VERSION here
# RUN env PYTHON_CONFIGURE_OPTS="--enable-shared --enable-optimizations" pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION
RUN env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION

RUN python --version && \
	pip --version && \
	pip install --upgrade pip && \
	pip --version && \
	pip install wheel

# TWEAK: Install pipenv and pipx separately from pip and allow them to fail.
# They may not be compatible with pre-releases.
RUN pip install pipenv && \
	pipenv --version || \
	echo 'WARNING: pipenv not installable!'
RUN pip install --user pipx && \
	pipx --version || \
	echo 'WARNING: pipx not installable!'

# TWEAK: Poetry relies on some Rust-based packages that do not yet have
# appropriate wheels, so we need to install Rust first.
# RUN sudo apt-get update && sudo apt-get install cargo

# TWEAK: Install preview version of Poetry and allow installation to fail with
#   a warning. Poetry has many dependencies; some aren't always compatible with
#   prerelease Pythons.
#
# This installs version poetry at the latest version. poetry is updated about twice a month.
RUN curl -sSL https://install.python-poetry.org | python - --preview \
  || echo 'WARNING: Poetry not installable!'

# TWEAK: Circle's checkout step requires the project directory to be empty.
RUN mv /home/circleci/project/poetry-installer-error*.log /home/circleci/ || true
