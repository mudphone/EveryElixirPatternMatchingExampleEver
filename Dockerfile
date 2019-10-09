ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Elixir Hawaiʻi <koba@pasdechocolat.com>"

USER root

#--------------------------+
# BuildPack Deps
# https://github.com/docker-library/buildpack-deps/blob/b0fc01aa5e3aed6820d8fed6f3301e0542fbeb36/bionic/curl/Dockerfile
# https://github.com/docker-library/buildpack-deps/blob/0db0cf15f1c507b17e7edc6dfbe301b8e357568f/bionic/scm/Dockerfile
# https://github.com/docker-library/buildpack-deps/blob/cd0058f0893008c7ffa8e9cb9d3d5208cf5f2f75/bionic/Dockerfile
#

RUN set -ex; \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    netbase \
    wget

RUN set -ex; \
  if ! command -v gpg > /dev/null; then \
    apt-get install -y --no-install-recommends \
      gnupg \
      dirmngr \
    ; \
  fi

# procps is very common in build systems, and is a reasonably small package
RUN apt-get install -y --no-install-recommends \
    bzr \
    git \
    mercurial \
    openssh-client \
    subversion \
    procps

RUN set -ex; \
  apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bzip2 \
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
    \
# https://lists.debian.org/debian-devel-announce/2016/09/msg00000.html
    $( \
# if we use just "apt-cache show" here, it returns zero because "Can't select versions from package 'libmysqlclient-dev' as it is purely virtual", hence the pipe to grep
      if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
        echo 'default-libmysqlclient-dev'; \
      else \
        echo 'libmysqlclient-dev'; \
      fi \
    ) \
  ;


#--------------------------+
# Erlang-OTP 22 
# https://github.com/erlang/docker-erlang-otp/blob/b8d78341fa655cfcd25c1fa37d7d280a07a17517/22/Dockerfile
#
ENV OTP_VERSION="22.1.1" \
    REBAR3_VERSION="3.12.0"

# We'll install the build dependencies for erlang-odbc along with the erlang
# build process:
RUN set -xe \
  && OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
  && OTP_DOWNLOAD_SHA256="9e7e8565a324101ea31fe5f59b8e46f7dabe9b75df9614d24c3abd05885f1773" \
  && runtimeDeps='libodbc1 \
      libsctp1 \
      libwxgtk3.0' \
  && buildDeps='unixodbc-dev \
      libsctp-dev \
      libwxgtk3.0-dev' \
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
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" \
    && make -j$(nproc) \
    && make install ) \
  && find /usr/local -name examples | xargs rm -rf \
  && apt-get purge -y --auto-remove $buildDeps

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
  && REBAR3_DOWNLOAD_SHA256="8ac45498f03e293bc6342ec431888f9a81a4fb9e1177a69965238d127c00a79e" \
  && mkdir -p /usr/src/rebar3-src \
  && curl -fSL -o rebar3-src.tar.gz "$REBAR3_DOWNLOAD_URL" \
  && echo "$REBAR3_DOWNLOAD_SHA256 rebar3-src.tar.gz" | sha256sum -c - \
  && tar -xzf rebar3-src.tar.gz -C /usr/src/rebar3-src --strip-components=1 \
  && rm rebar3-src.tar.gz \
  && cd /usr/src/rebar3-src \
  && HOME=$PWD ./bootstrap \
  && install -v ./rebar3 /usr/local/bin/ \
  && rm -rf /usr/src/rebar3-src


#--------------------------+
# Elixir 1.9
# https://github.com/c0b/docker-elixir/blob/8c92148d07fc89a57706dcb22c926a96e73a4194/1.9/Dockerfile
#

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.9.1" \
  LANG=C.UTF-8

RUN set -xe \
  && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
  && ELIXIR_DOWNLOAD_SHA256="94daa716abbd4493405fb2032514195077ac7bc73dc2999922f13c7d8ea58777" \
  && curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
  && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
  && mkdir -p /usr/local/src/elixir \
  && tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
  && rm elixir-src.tar.gz \
  && cd /usr/local/src/elixir \
  && make install clean


#--------------------------+
# Elixir Hawaiʻi
#

RUN apt-get install -y --no-install-recommends \
    vim \
    emacs \
    nano \
  && rm -rf /var/lib/apt/lists/*


CMD ["iex"]