# Use an official Elixir image as the base
FROM elixir:1.18.3

# Set-up for switching to non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV LANG=C.UTF-8
ENV TERM=xterm-256color

# Set up non-root user
RUN groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
	&& apt-get update \
	&& apt-get install -y sudo \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME

RUN cp -r /root/. /home/${USERNAME} \
	&& chown -R ${USER_UID}:${USER_GID} /home/${USERNAME} \
	&& chmod a+rx /usr/local/bin/*

# Install dependencies and inotify-tools
RUN apt-get update -y \
	&& apt-get install -y --no-install-recommends \
	curl \
	git \
	pgcli \
	libpq-dev \
	httpie \
	build-essential \
	erlang-dev \
	libc-dev \
	python3-typing-extensions \
	pre-commit \
	pipx \
	&& rm -r /var/cache/* /var/lib/apt/lists/*

# Set up project folder
ENV APP_HOME=/app
RUN mkdir $APP_HOME && chown -R ${USER_UID}:${USER_GID} ${APP_HOME}
WORKDIR $APP_HOME

RUN usermod --shell /bin/bash ${USERNAME}
USER ${USERNAME}

# Install Hex and Rebar3
RUN mix local.hex --force && mix local.rebar --force

# Install Commitizen locally
RUN pipx ensurepath \
	&& pipx install commitizen \
	&& pipx upgrade commitizen