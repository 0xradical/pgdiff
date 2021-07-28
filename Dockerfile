# AS per SELECT version(); on production
FROM postgres:11.10

#  AS per SELECT name, default_version FROM pg_available_extensions where name = 'plv8' on production;
# Version 2.3.9 is 2.3.8 fixed for pg11 compilation
ENV PLV8_VERSION=2.3.9

RUN buildDependencies="build-essential \
    ca-certificates \
    curl \
    git-core \
    python \
    python3 \
    gpp \
    cpp \
    pkg-config \
    apt-transport-https \
    cmake \
    libc++-dev \
    postgresql-server-dev-$PG_MAJOR" \
    runtimeDependencies="libc++1" \
  && apt-get update \
  && apt-get install -y --no-install-recommends ${buildDependencies} ${runtimeDependencies} \
  && mkdir -p /tmp/build \
  && curl -o /tmp/build/v$PLV8_VERSION.tar.gz -SL "https://github.com/plv8/plv8/archive/v${PLV8_VERSION}.tar.gz" \
  && cd /tmp/build \
  && tar -xzf /tmp/build/v$PLV8_VERSION.tar.gz -C /tmp/build/ \
  && cd /tmp/build/plv8-$PLV8_VERSION \
  && make static \
  && make install \
  && strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so \
  && rm -rf /root/.vpython_cipd_cache /root/.vpython-root \
  && apt-get clean \
  && apt-get remove -y ${buildDependencies} \
  && apt-get autoremove -y \
  && rm -rf /tmp/build /var/lib/apt/lists/*

RUN apt update && apt install -qy gettext-base
