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
