FROM elixir:1.8-alpine

RUN mkdir -p /usr/src/myapp \
	&& mkdir -p /usr/src/scripts \
	&& mix local.hex --force \
  && mix local.rebar --force \
	&& apk add --update --no-cache nodejs nodejs-npm make gcc g++ curl

WORKDIR /usr/src/myapp

COPY . /usr/src/myapp/
#COPY mix.exs /usr/src/myapp/mix.exs

ARG MIX_ENV=production
ENV MIX_ENV=${MIX_ENV}
ENV PORT=4000
RUN ["mix", "deps.get"]
RUN ["mix", "compile"]

EXPOSE ${PORT}

COPY ./docker/oms-core-elixir/bootstrap.sh /usr/src/scripts/bootstrap.sh
COPY ./docker/oms-core-elixir/wait.sh /usr/src/scripts/wait.sh

CMD ash /usr/src/scripts/bootstrap.sh \
      && mix phx.server --no-compile
