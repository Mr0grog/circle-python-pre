# vim:set ft=dockerfile:

# THIS IS A (SLIGHTLY TWEAKED) copy of the official dockerfile at:
#   https://github.com/CircleCI-Public/cimg-python/blob/main/3.11/Dockerfile
# Care should be taken to keep this inline with that source file.
# Tweaks here are marked with "# TWEAK:"

FROM cimg/base:2024.02

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
# TWEAK: set '--enable-optimizations' via ARG_PYTHON_FLAGS instead of hardcoding
ARG ARG_PYTHON_FLAGS=''
RUN env PYTHON_CONFIGURE_OPTS="--enable-shared $ARG_PYTHON_FLAGS" pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION

RUN python --version && \
	pip --version && \
	pip install --upgrade pip && \
	pip --version && \
	# This installs pipenv at the latest version
	pip install pipenv wheel && \
	pipenv --version && \
	# Install pipx
	pip install --user pipx

# TWEAK: Poetry relies on some Rust-based packages that do not yet have
# appropriate wheels, so we need to install Rust first.
# RUN sudo apt-get update && sudo apt-get install cargo

# TWEAK: Allow Poetry installation to fail with a warning. Poetry has many
#   dependencies; some aren't always compatible with prerelease Pythons.
#   ^ The above also makes this step pretty slow when it is successful, since
#     many deps don't have wheels for a prerelease Python and need from-scratch
#     builds.
#
# This installs version poetry at the latest version. poetry is updated about twice a month.
# RUN curl -sSL https://install.python-poetry.org | python - \
#   || echo 'WARNING: Poetry not installable!'
