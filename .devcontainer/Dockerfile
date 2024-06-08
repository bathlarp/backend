FROM qmcgaw/basedevcontainer:v0.25.0-debian

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG EXTHOME
ENV OTP_VERSION="26.2.5" \
	REBAR3_VERSION="3.23.0" \
	ELIXIR_VERSION="v1.16.3" \
	LANG=C.UTF-8

# Erlang prerequisites (from buildpack-deps)
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
	autoconf \
	automake \
	bzip2 \
	curl \
	default-libmysqlclient-dev \
	dpkg-dev \
	file \
	g++ \
	gcc \
	imagemagick \
	libbz2-dev \
	libc6-dev \
	libcurl4-openssl-dev \
	libdb-dev \
	libevent-dev \
	libffi-dev \
	libgdbm-dev \
	libglib2.0-dev \
	libgmp-dev \
	libjpeg-dev \
	libkrb5-dev \
	liblzma-dev \
	libmagickcore-dev \
	libmagickwand-dev \
	libmaxminddb-dev \
	libncurses5-dev \
	libncursesw5-dev \
	libpng-dev \
	libpq-dev \
	libreadline-dev \
	libsqlite3-dev \
	libssl-dev \
	libtool \
	libwebp-dev \
	libxml2-dev \
	libxslt-dev \
	libyaml-dev \
	make \
	patch \
	unzip \
	xz-utils \
	zlib1g-dev \
	; \
	rm -rf /var/lib/apt/lists/*

# Install Erlang - taken from:
# https://github.com/erlang/docker-erlang-otp/blob/8b812830f95216a3d8a253c24af2c55a1da4935b/26/Dockerfile
RUN set -xe \
	&& OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
	&& OTP_DOWNLOAD_SHA256="d34b409cb5968ae47dd5a0c4f85b925d5601898d90788bbb08d514964a3a141d" \
	&& runtimeDeps='libodbc1 \
	libsctp1 \
	libwxgtk3.2-1 \
	libwxgtk-webview3.2-1' \
	&& buildDeps='unixodbc-dev \
	libsctp-dev \
	libwxgtk-webview3.2-dev' \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends $runtimeDeps \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
	&& echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
	&& export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
	&& mkdir -vp $ERL_TOP \
	&& tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
	&& rm otp-src.tar.gz \
	&& ( cd $ERL_TOP \
	&& ./otp_build autoconf \
	&& gnuArch="$(dpkg-architecture --query DEB_HOST_GNU_TYPE)" \
	&& ./configure --build="$gnuArch" \
	&& make -j$(nproc) \
	&& make -j$(nproc) docs DOC_TARGETS=chunks \
	&& make install install-docs DOC_TARGETS=chunks ) \
	&& find /usr/local -name examples | xargs rm -rf \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf $ERL_TOP /var/lib/apt/lists/*

# extra useful tools here: rebar & rebar3

ENV REBAR_VERSION="2.6.4"

RUN set -xe \
	&& REBAR_DOWNLOAD_URL="https://github.com/rebar/rebar/archive/${REBAR_VERSION}.tar.gz" \
	&& REBAR_DOWNLOAD_SHA256="577246bafa2eb2b2c3f1d0c157408650446884555bf87901508ce71d5cc0bd07" \
	&& mkdir -p /usr/src/rebar-src \
	&& curl -fSL -o rebar-src.tar.gz "$REBAR_DOWNLOAD_URL" \
	&& echo "$REBAR_DOWNLOAD_SHA256 rebar-src.tar.gz" | sha256sum -c - \
	&& tar -xzf rebar-src.tar.gz -C /usr/src/rebar-src --strip-components=1 \
	&& rm rebar-src.tar.gz \
	&& cd /usr/src/rebar-src \
	&& ./bootstrap \
	&& install -v ./rebar /usr/local/bin/ \
	&& rm -rf /usr/src/rebar-src

RUN set -xe \
	&& REBAR3_DOWNLOAD_URL="https://github.com/erlang/rebar3/archive/${REBAR3_VERSION}.tar.gz" \
	&& REBAR3_DOWNLOAD_SHA256="00646b692762ffd340560e8f16486dbda840e1546749ee5a7f58feeb77e7b516" \
	&& mkdir -p /usr/src/rebar3-src \
	&& curl -fSL -o rebar3-src.tar.gz "$REBAR3_DOWNLOAD_URL" \
	&& echo "$REBAR3_DOWNLOAD_SHA256 rebar3-src.tar.gz" | sha256sum -c - \
	&& tar -xzf rebar3-src.tar.gz -C /usr/src/rebar3-src --strip-components=1 \
	&& rm rebar3-src.tar.gz \
	&& cd /usr/src/rebar3-src \
	&& HOME=$PWD ./bootstrap \
	&& install -v ./rebar3 /usr/local/bin/ \
	&& rm -rf /usr/src/rebar3-src

# Install Elixir - taken from:
# https://github.com/erlef/docker-elixir/blob/f749dfb8a5b1e6945b2369e143107b9ad3b16664/1.16/Dockerfile
RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="a163128e618e5205ea749f8effafa5b540008fd0bed863e75e2e09663a00ec45" \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean \
	&& find /usr/local/src/elixir/ -type f -not -regex "/usr/local/src/elixir/lib/[^\/]*/lib.*" -exec rm -rf {} + \
	&& find /usr/local/src/elixir/ -type d -depth -empty -delete

# Set up non-root user
RUN groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
	&& apt-get update \
	&& apt-get install -y sudo \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME \
	&& usermod --shell /bin/zsh root

RUN cp -r /root/. /home/${USERNAME} \
	&& chown -R ${USER_UID}:${USER_GID} /home/${USERNAME} \
	&& chmod a+rx /usr/local/bin/*
RUN sed -i -e s/root/home\\/${USERNAME}/ /home/${USERNAME}/.zshrc
RUN apt-get update -y \
	&& apt-get install -y --no-install-recommends \
	inotify-tools \
	pgcli \
	libpq-dev \
	httpie \
	build-essential \
	erlang-dev \
	libc-dev \
	python3-typing-extensions \
	pre-commit \
	&& rm -r /var/cache/* /var/lib/apt/lists/*
USER ${USERNAME}
COPY .ssh.sh /home/${USERNAME}/.ssh.sh
USER root
RUN chmod +x /home/${USERNAME}/.ssh.sh
RUN usermod --shell /usr/bin/zsh ${USERNAME}
USER ${USERNAME}
