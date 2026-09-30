# Startback - Got Your Ruby Back

Yet another ruby framework, I'm afraid. Here, we srongly seperate between:

1. the web layer, in charge of a quality HTTP handling
2. the operations layer, in charge of the high-level software operations
3. the database layer, abstracted using the Relations As First Class Citizen pattern

Currently,

1. is handled using extra support on top of Sinatra
2. is handled using Startback specific classes
3. is handled using Bmg

## Public API

This gem uses semantic versioning. The public API is defined as follows:

* All ruby classes, require path, constructor arguments, and public methods.

* The `enspirit/startback:api` and `enspirit/startback:web` docker images and
  main `CMD`.

Upgrading across a major version? See [UPGRADING.md](UPGRADING.md).

## Supported rubies

CI runs the suite on **Ruby 3.2, 3.3, 3.4 and 4.0** -- the whole range
`required_ruby_version` allows. Docker images are released for 3.4 and 4.0.

## Running the tests

    make tests

The `Startback::Event::Bus::Bunny::Async` specs need a real RabbitMQ broker --
mocking bunny would only assert that Startback calls the methods Startback
calls. Start one and point the suite at it:

    make rabbitmq.up
    export STARTBACK_BUS_BUNNY_ASYNC_URL=amqp://guest:guest@localhost:5672
    make tests
    make rabbitmq.down

Without a broker those specs **skip**, and the suite is still green. CI sets
`STARTBACK_SPEC_REQUIRE_BUNNY=1`, which turns "no broker" into a failure, so
that a broken service container cannot quietly take the coverage away.

## Docker images

    docker pull enspirit/startback:api    # ruby 3.4
    docker pull enspirit/startback:web    # ruby 3.4, plus nodejs and yarn

The tags that name no ruby version -- `:api`, `:api-2.1.0`, `:api-2.1` -- are
built with `DEFAULT_MRI_VERSION`, currently **3.4**. Every ruby version listed
in `RELEASE_MRI_VERSIONS` is also reachable by name:

    docker pull enspirit/startback:api-ruby4.0
    docker pull enspirit/startback:api-2.1.0-ruby4.0

Both variables live at the bottom of the [Makefile](Makefile). Adding a ruby
version to the release matrix means listing it there and in the
`ruby-version` matrix of the tests and release-images workflows.

`make images` builds and pushes one ruby version (`MRI_VERSION`, defaulting to
`DEFAULT_MRI_VERSION`); `make images.all` walks the whole matrix, as the
release workflow does with one job per version.
