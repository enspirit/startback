## 0.16.0

* Upgraded puma to 6.x

* The .api and .web images no longer specify default -t
  (threads) and -w (workers) options to puma commandline.

  One should use PUMA_MIN_THREADS, PUMA_MAX_THREADS and
  WEB_CONCURRENCY envionment variables instead. For the record,
  the default values (under MRI & puma 6.0.x) are 0, 5 and 0
  (no forking model), respectively.

  Stricly speaking, this is a broken API, even if you will
  probably not notice the change.

  Also, note that the .engine image now uses `-t 1:1 -w 0`,
  which should be backward compatible as well. We stopped
  using the workers mode, since only one worker makes little
  sense.

* Default ruby version is now 3.1 instead of 2.7

  If you need ruby 2.7, you must say it explicitely, e.g.
  `enspirit/startback:base-0.16-ruby2.7`

## 0.15.5 - 2023-01-11

* [startback-jobs] add support for job failures. Failed jobs
are considered ready (`isReady: true`) but have a new flag
(`hasFailed: true`) that tracks the failure. The failure
itself is dumped in `opResult`. The API that serves the job
result always dumps the `opResult` and uses a 200 status code
in case of success and 272 in case of failure.

## 0.15.4 - 2022-10-13

* BadRequestError and subclasses (40x) are now logged in WARN
  severity instead of ERROR by the Trailer. This is considered
  a good idea on almost all Enspirit projects, so we dare doing
  it on a tiny version bump (angel emoji).

## 0.15.3 - 2022-09-30

* Rebuilding of docker images on latest ruby versions.

## 0.15.2 - 2022-08-03

* Allow finitio 0.11 to be used. It's safe.

## 0.15.1 - 2022-06-22

* Fix Web::CorsHeaders. An empty value is not allowed, the
  header should simply not be present.

## 0.15.0 - 2022-06-22

* POSSIBLY BREAKING: when a Finitio::TypeError is raised
  (typically by an operation failing to validate its input),
  the `location` field of the error is now dumped. This may
  possibly break webspicy tests that validate error responses
  very strictly.

* Web::CorsHeaders now support more bouncing options and can be
  used to whitelist some urls (with wildcards) that are
  authorized to bounce.

## 0.14.4 - 2022-06-15

* Removed startback-tests.gemspec that is not a valid gem
  anyway.

## 0.14.3 - 2022-06-15

* [startback-jobs] properly let inspect a job and its embedded
  results.


## 0.14.2 - 2022-06-08

* [startback-websocket] Fix inclusion of javascript files in gem.

## 0.14.1 - 2022-06-08

* Fix the build chain: release of ruby gems.

## 0.14.0 - 2022-06-07

* Fix Engine: memoize the bus and run main agent class in
  addition to its subclasses.

* BREAKING: Remove serverengine and webrick. Engines should now be started with
  puma and a config.engine.ru instead of engine.rb

## 0.13.0 - 2022-05-31

* Contributes Startback::Model, Startback::Services, as well
  as Startback::Support::DataObject and Startback::Support::World

* Added the notion of context world, through Context.world,
  Context#world and Context#with_world.

* Context.new yields the context instance if a block is given

* Bmg minimal dependency is now 0.20.0

* POSSIBLY BREAKING: Operation now has a default constructor that
  expects a Hash and installs it under `@input` with an attr_reader.

  This may break the audit trailer and/or bus dump for legacy
  operations that named their input `request`.

## 0.12.3 - 2022-05-25

* Event.json is idempotent.

## 0.12.2 - 2022-05-20

* See 0.12.0, same release

## 0.12.1 - 2022-05-19

* See 0.12.0, same release

## 0.12.0 - 2022-05-19

This release enhances the event layer of Startback with the
Event, Bus, Engine and Agent collaborating classes.

Unfortunately it comes with a couple of BREAKING changes:

* `Context::Middleware` now longer takes a context_class
  option, but simply a Context instance (or subclass). That
  instance will be duped and result installed in Rack env.
  Doing so allows building a default context instance with,
  e.g. a logger, and make sure it will be properly reused.

* `Startback::Bus` is moved to `Startback::Event::Bus`

* `Startback::Event.json` contract has changed. The default
  contract expects the event type to be a fully classified
  class name (subclass of Event) and will attempt to factor
  one. The second argument is no longer a world (Hash) but
  a context instance to attach to the event. A context fork
  is made, using the event context data passed through the
  Context h_factory (if event contains context info).

* `Startback::Engine` constructor takes ServerEngine options
  under a `:server_engine` key (was the options themselves).

* `Startback::Agent` has a new protocol that relies on agent
  instances and the presence of an `Engine`. The `listen` class
  method no longer exists. You must use the `sync` and `async`
  instance methods instead. Your agent instance should be
  created withing the engine (see `create_agents` and
  `auto_create_agents` there)

* `Bus::Bunny` now has `autoconnect: false` by default. You
  should explicit connect your engine instance instead.

* `Bus::Bunny` now has `abort_on_exception: true` by default.
  It's much safer but you need a supervisor like Kubernetes
  in pratice.

## 0.11.6 - Unreleased

* Extend the Bus abstraction with connect/disconnect.

* Bunny::Async now has an autoconnect option (defaulting to true
  for backward compatibility) that can be used to avoid connecting
  too early.

* Bunny::Async now has `:abort_on_exception` and
  `:consumer_pool_size` options that control the main channel
  behavior. Their default values are chosen to stay backward
  compatible.

## 0.11.5 - 2022-05-18

* Add Startback::Support::Env with `env` and `env!` helper
  methods.

* Startback no longer includes a trace in the warning message
  sometimes seen because one uses the default logger.

* Added Startback::Event::Agent class, for agents reacting to
  events on a bus.

* Added Startback::Event::Engine class, that runs an infinite
  loop using ServerEngine and includes a Webrick small rack
  app with a default and overridable healthcheck behavior.

## 0.11.4 - 2022-05-18

* Allow logging Strings & Exceptions directly in both trailer
  and Robusness helpers.

## 0.11.3 - 2022-05-10

* Keep allowing `require 'audit/trailer'` alone without an
  error.

## 0.11.2 - 2022-05-10

* Audit::Trailer and Audit::Prometheus support any op object
  responding to `op_name` and `op_data` and use them in
  priority over dedicated logic to extract logging info.

  Their `#call` method are now part of the public API and
  can thus be called by end-user code.

## 0.11.1 - 2022-05-10

* We no longer let the Sinatra layer dump errors in log.

## 0.11.0 - 2022-04-21

* Require bmg >= 0.19.0

## 0.10.1 - 2021-12-23

* Add support for causes in Startback::Errors::Error

* The Shield rack middleware dumps the causes to json, provided
  they are subclasses of Startback::Error.

* Error & their causes are now properly dumped in the audit
  trail.

## 0.10.0 - 2021-12-22

* Add support for operations's transaction policy and transaction
  manager helper

* Fix audit trail on multi operations. The op_data recursively
  collect data of sub operations.

## 0.9.1 - 2021-12-13

* Fixing thread safetiness of async bus (bunny channels)

## 0.9.0 - 2021-08-27

* BREAKING CHANGE: all docker images now run Puma as app on port 3000 instead
of root on port 80.

* Upgrades uglify.js to 4.2, to enable support for ES6.
## 0.8.3 - 2021-05-25

* Update dependencies for security patches.

## 0.8.2

* Release gem in jenkins pipeline.

## 0.8.1

* Web::Api#serve not support Path instances as entities to serve. Sinatra's send_file is
  then used on the path. DTOs returning Path instances are supported too.

## 0.8.0 - 2021/03/12

- Bumped finitio to 0.10
- Bumped webspicy to 0.20
- Bumped bmg to 0.18

## 0.7.6 - 2020/12/11

* Include version.

## 0.7.5 - 2020/12/11

* Prometheus metrics include startback_version and have customisable with prefix and labels.

## 0.7.4 - 2020/12/10

* Move prometheus-client as a dependency for base.

## 0.7.3 - 2020/12/08

* Add prometheus auditor and rack middleware exposing metrics for
  operations. The auditor implements the around_run contract.

      # Usage example:
      around_run(Startback::Audit::Prometheus.new)

      # ... in api (exposing /metrics endpoint)
      use Startback::Web::Prometheus

## 0.7.2 - 2020/08/27

* Api#with_context and Operation#with_context allow running a block
  with an ephemeral context. The original one is restored after the
  block execution.

      # With an explicit context created from scratch
      ctx = ...
      with_context(ctx) do
        # will be run using `ctx`, instead of the original one
        run MyOperation.new
      end
      ... # original context is restored here

      # With a context dup
      with_context do |ctx|
        ctx.foo = "bar"
        # will be run using `ctx`, instead of the original one
        run MyOperation.new
      end
      ... # original context restored; foo=bar is no longer true

* DateTime and Time monkey patches are corrected regarding `to_s`
  when the latter takes a parameter (activesupport does).

* Bmg "0.17.5" is now a minimum.

## 0.7.1

* Context#dup now correctly cleans all factored abstractions.

## 0.7.0

* Bumped bmg dependency to 0.17.x to get recent optimizations and bug
  fixes.

## 0.6.0

* Docker images now have the startback gem install together with all
  dependencies. This saves build time of image users, since many gems
  that require native extensions are already installed and will be
  reused by bundler.

## 0.5.5

* All docker images now run the software as app:app, for improved security.

## 0.5.4

* Docker images added for the various variants we have: base, api, web,
  engine.

## 0.5.3 - 2019/10/23

* Added a `Startback::Caching::NoStore` abstraction, the easiest way
  to disable caching in practice.

## 0.5.2 - 2019/10/23

* Fine-tuned `Robustness` once again, to trace when default logger is
  (incorrectly?) used.

* Fixed `EntityCache` and `CatchAll` logging to use the context when
  defined and avoid therefore to end up on the default logger.

## 0.5.1 - 2019/10/19

* Improved `EntityCache` with a protocol to convert candidate keys to
  primary keys. The class documentation and vocabulary has been improved
  to be more intuitive for users with a relational database background.

  Methods `full_key` and `load_raw_data` are renamed in a backwards
  compatible way to `primary_key` and `load_entity`, respectively. The
  old methods will be removed in 0.6.0.

* Improved `EntityCache` with logging. Cache hits are logged in debug.
  Cache miss & outdated are logged in info.

* Fine-tuned `Robustness`, log & audit trail to make them easier to use.
  In particular, the 25 lines of the backtrace are dumped in `op_data`
  on fatal errors.

## 0.5.0 - 2019/10/16

* BREAKING CHANGE: Operation#bind no longer returns new operation
  instances, it mutates the operation on which it is called. This is to
  prevent counterintuitive behaviors when operations are passed around
  while binding is actually rather hidden.

* BREAKING CHANGE: Web::CatchAll only dumps 10 stacktrace lines, to
  prevent logs from growing too much, and make sure that logs under
  passenger do not end up being broken.

* Add support for run `around` hooks in `Web::Api`, through an
  OperationRunner support module. The same module is included by
  the `Operation` class itself, since it can run sub operations.

* Before (resp. after) hooks are added to the `Operation` abstraction.
  They are called right before (resp. after) `call` by operation runners,
  that is `Web::Api` and `Operation` itself.

* Introduce an `operation_world` overridable method to participate
  to the world construction in `Web::Api`. This aims at preventing
  `run` cowboy overriding.

* The `Context` abstraction now has a dump & reload protocol that allows
  being passed around in a distributed architecture.

* The `Context` abstraction now acts as a factory for related abstractions.
  That factory has a caching mechanism, to prevent creating the same classes
  over and over again and reduce memory footprint.

* Add Startback::Web::Middleware helper module, that gives access to the
  running context installed by Startback::Context::Middleware under a
  simple `context` method.

* Add eventing support through the `Startback::Event` and `Startback::Bus`
  abstractions. Please `require 'startback/bus'` explicitely to use them.

* Add `Startback::Caching::EntityCache` abstraction and protocol for making
  caching and invalidation easier on individual objects.
  Please `require 'startback/caching/entity_cache'` explicitely to use them.

* Add log & audit trail abstractions, through the `Stackback::Audit::Trailer`
  class. The class can be registered as an operation's around callback and
  will dump a json log of operation executions and their timing.

## 0.4.5 - 2019/06/24

* [CatchAll] Log error message and error backtrace as two different lines,
  to avoid message being stripped because the stacktrace is too long.

## 0.4.4 - 2019/03/12

* Startback::Web::HealthCheck correctly returns an empty array as third
  rack 204 response, to meet the spec and avoid crashes with webrick.

## 0.4.3 - 2019/03/08

* `Context::Middleware.context(env)` can now be used to return the context
  installed on an environment. To avoid having to know the key itself that
  might change in the future.

* The Errors module now expose many utility methods to raise errors without
  having to know all error classes. Those methods are available in Operation
  and Api instances. The module can also be included by users to get the new
  methods available elsewhere.

* The error `No method unsupported_content_type` is now fixed when a media
  type is unsupported. A correct 415 HTTP error is returned instead.

* Ruby's NotImplementedError are now catched by the Shield and transformed
  to a 501 HTPP response.

* Severe errors catched by CatchAll are not logged with both the message and
  the full stack trace.

## 0.4.2 - 2019/03/08

* Startback::Web::AutoCaching no longer overrides Cache-Control headers
  set down the middleware chain. It trusts existing headers by default.

## 0.4.1 - 2019/03/06

* Add a NgHtmlTransformer tool to MagicAssets. Useful for angular assets
  with a component folder structure.

## 0.4.0 - 2019/03/06

* BREAKING CHANGE: the various web components are not longer required by
  default. The user must require each component it uses.

* Add a Startback::Web::AutoCaching rack middleware to help setting
  the Cache-Control header in development/production environments,
  according to middleware construction parameters and/or environment
  variables.

* Add a Startback::Web::CorsHeaders rack middleware to help setting
  the various Cross-Origin Response Headers correctly, while supporting
  good default values and configuration through middleware construction
  parameters and/or environment variables.

* Add a Startback::Web::MagicAssets middleware and application, to help
  managing js/css assets using Sprockets.

## 0.3.2 - 2018/11/27

* Subclassing error classes keep orginal status codes, unless overriden

## 0.3.1 - 2019/01/30

* Fix file upload raising an exception about `file` not being defined.

## 0.3.0 - 2018/10/12

* Enhanced CatchAll to support an `error_handler` on the context. Fatal
  exceptions are passed to the error handler when provided.

## 0.2.0 - 2018/09/26

* Context::Middleware now accepts a `context_class` option allowing
  to specify a subclass of Context as actual context class. This allows
  application to make the context more specific without monkey patching
  Startback classes.

* Main abstractions cleaned and documented

## 0.1.0

Birthday
