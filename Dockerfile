FROM elixir:1.7.4-alpine

RUN mkdir -p /usr/src/myapp \
	&& mkdir -p /usr/src/scripts \
	&& mix local.hex --force \
    && mix local.rebar --force \
	&& apk add --update --no-cache nodejs nodejs-npm make gcc g++

COPY ./docker/oms-core-elixir/bootstrap.sh /usr/src/scripts/bootstrap.sh
COPY ./docker/oms-core-elixir/wait.sh /usr/src/scripts/wait.sh
COPY ./ /usr/src/myapp

WORKDIR /usr/src/myapp

EXPOSE 4000

CMD ash /usr/src/scripts/bootstrap.sh && mix phx.server
