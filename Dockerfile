ARG ELIXIR_VERSION=1.12.1
ARG ERLANG_VERSION=24.0.1
ARG ALPINE_VERSION=3.13.3
ARG LINUX_VERSION=alpine-$ALPINE_VERSION

#########################
# Stage: deps-assets    #
#########################
FROM hexpm/elixir:$ELIXIR_VERSION-erlang-$ERLANG_VERSION-$LINUX_VERSION as build

RUN apk add --no-cache \
  build-base \
  npm \
  git

WORKDIR /app
ENV HEX_HTTP_TIMEOUT=20

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=nokey

COPY mix.exs mix.lock ./
COPY apps/faqcheck/mix.exs apps/faqcheck/mix.exs
COPY apps/faqcheck_web/mix.exs apps/faqcheck_web/mix.exs

COPY config config

RUN mix deps.get --only prod && \
    mix deps.compile

COPY apps/faqcheck_web/assets/package.json apps/faqcheck_web/assets/package-lock.json ./apps/faqcheck_web/assets/
RUN npm --prefix ./apps/faqcheck_web/assets ci --progress=false --no-audit --loglevel=error

COPY apps/faqcheck/priv/ ./apps/faqcheck/priv/
COPY apps/faqcheck_web/priv/ ./apps/faqcheck_web/priv/
COPY apps/faqcheck_web/assets/ ./apps/faqcheck_web/assets/

RUN npm run --prefix ./apps/faqcheck_web/assets deploy
RUN mix phx.digest

COPY apps/faqcheck/lib apps/faqcheck/lib
COPY apps/faqcheck_web/lib apps/faqcheck_web/lib
COPY rel rel

RUN mix do compile, release


## second stage

FROM alpine:$ALPINE_VERSION AS app
RUN apk add --no-cache \
    libstdc++ \
    openssl \
    ncurses-libs

WORKDIR /app
RUN chown nobody:nobody /app
USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/faqcheck_umbrella ./

ENV HOME=/app
ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=nokey
ENV PORT=4000
CMD ["bin/faqcheck_umbrella", "start"]



# COPY config /app/config
# COPY mix.exs /app/
# COPY mix.* /app/
# COPY apps/faqcheck/mix.exs /app/apps/faqcheck
# COPY apps/faqcheck_web/mix.exs /app/apps/faqcheck_web/

# ENV MIX_ENV=prod
# RUN mix do deps.get --only $MIX_ENV, deps.compile

# COPY . /app/


# WORKDIR /app/apps/faqcheck_web
# # RUN MIX_ENV=prod mix compile
# RUN npm install --prefix ./assets
# RUN npm run deploy --prefix ./assets
# # RUN mix phx.digest


# #WORKDIR /app
# #RUN MIX_ENV=prod mix release

# #########################
# # Stage: release        #
# #########################

# FROM hexpm/elixir:$ELIXIR_VERSION-erlang-$ERLANG_VERSION-$LINUX_VERSION as release

# RUN apk --no-cache add git

# ENV MIX_ENV=prod

# WORKDIR /app

# COPY . /app/
# COPY --from=deps-assets /app/apps/faqcheck_web/priv/static/ /app/apps/faqcheck_web/priv/static/
# COPY --from=deps-assets /app/deps/ /app/deps/

# RUN

# RUN mix local.rebar --force \
#  && mix local.hex --if-missing --force \
#  && mix do deps.get --only $MIX_ENV, deps.compile, phx.digest

# RUN mix release \
#  && rm -rf /app/deps

# #########################
# # Stage: production     #
# #########################
# FROM alpine:$ALPINE_VERSION as production

# COPY --from=release /app/_build/prod/rel/app_umbrella ./

# RUN chmod +x /app/bin/*
# ENV HOME=/app

# CMD ["bin/app_umbrella", "start"]