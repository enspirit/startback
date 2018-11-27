## 0.3.1 - 2018/11/27

* Subclassing error classes keep orginal status codes, unless overriden

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
