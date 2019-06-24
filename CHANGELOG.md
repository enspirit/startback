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
