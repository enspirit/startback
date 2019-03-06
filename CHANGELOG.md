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
