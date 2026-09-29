# Upgrading Startback

## From 1.2.x to 2.0.0

**Startback's own API has not changed.** Every class, require path, constructor
argument and public method behaves as it did in 1.2.x. What changed is the
dependency floor: Sinatra 4, and therefore Rack 3, are now required, and the
other dependencies moved to their latest major.

So almost everything below is about *your* application code meeting Rack 3 and
Sinatra 4, not about Startback. Each section is written as: what you will see,
why, and what to do.

Rough budget: a small API service usually needs **two changes** -- setting
`RACK_ENV`, and lowercasing any response triples it builds by hand. The rest
depends on what you use.

---

## Before you start

| | |
|---|---|
| Ruby | **>= 3.2** is now enforced by the gemspec. 3.1 is end of life. |
| webspicy | **Must move to 1.x.** See [webspicy](#10-webspicy-must-move-to-1x) -- this one fails to install, it does not degrade quietly. |
| Everything else | Installs fine; behaviour changes are listed below. |

Start with:

```sh
bundle update startback
bundle exec rake test    # or whatever runs your suite
```

Most failures will be issue 1 or issue 2.

---

## 1. Every request returns `403 Host not permitted`

**You will see** every request failing with status 403 and a `text/plain` body
reading `Host not permitted` -- in your test suite first, and in local
development if you reach the app through anything other than `localhost`.

**Why.** Sinatra 4.1 added `Rack::Protection::HostAuthorization` (for
CVE-2024-21510). In the `development` environment it only accepts `localhost`,
`*.localhost`, `*.test` and IP literals as `Host`. `development` is the
environment Sinatra picks when **neither `RACK_ENV` nor `APP_ENV` is set**,
which is the common case in test suites and docker-compose.

Test suites are hit systematically because `Rack::Test` sends requests to
`example.org`, and so does webspicy's `RackTestClient`.

**Production is not affected**: outside `development`, the permitted list is
empty, which means "allow everything".

**Fix, for test suites** -- set the environment before Sinatra is loaded, i.e.
at the very top of `spec_helper.rb` (or your webspicy `config.rb`), *above* the
`require`s:

```ruby
ENV['RACK_ENV'] ||= 'test'

require 'startback'
```

**Fix, for local development behind a custom hostname** -- either set
`RACK_ENV` in your docker-compose/`.env`, or declare the hosts:

```ruby
class MyApi < Startback::Web::Api
  set :host_authorization, { permitted_hosts: ['.my-app.internal', '.localhost'] }
end
```

A leading dot matches subdomains. Passing an empty list disables the check
entirely -- reasonable for a service that only ever sits behind a trusted
reverse proxy, but it is opting out of a CVE fix, so do it deliberately.

---

## 2. A response header appears twice, or a middleware stops seeing it

**You will see** responses carrying, say, both `Cache-Control` and
`cache-control` with different values; or a middleware that used to read a
header no longer finding it; or a caching proxy behaving oddly.

**Why.** The Rack 3 SPEC states that response header keys *"must not contain
uppercase ASCII characters (A-Z)"*. Rack 3 middleware therefore looks headers
up in lowercase. A triple you build by hand with `"Content-Type"` is a
different key from the `"content-type"` everything else uses, so instead of
overriding, it coexists.

Nothing raises. This is a silent behaviour change, which is what makes it worth
hunting for deliberately.

**Fix.** Lowercase the header names in any response triple your code builds:

```ruby
# before
[200, { "Content-Type" => "application/json" }, [body]]

# after
[200, { "content-type" => "application/json" }, [body]]
```

Grep for it:

```sh
grep -rnE '"(Content-Type|Cache-Control|Location|Content-Length|X-[A-Za-z-]+)"\s*=>' app lib
```

You do **not** need to change:

* `content_type :json` and friends inside a Sinatra route -- Sinatra normalizes.
* Reading headers from a response object (`response['Content-Type']`) --
  `Rack::Headers` is case-insensitive on read.
* Startback's own middlewares. `AutoCaching`, `CorsHeaders`, `HealthCheck`,
  `Shield` and `CatchAll` were all fixed in this release; `AutoCaching` and
  `CorsHeaders` had exactly this duplication bug.

---

## 3. `undefined method 'each' for an instance of String`

**You will see** that error, or a blank response body.

**Why.** Rack 3 requires a response body to respond to `each` or `call`. A bare
String is no longer a valid body.

**Fix.** Wrap it:

```ruby
# before
[404, { "content-type" => "text/plain" }, "NotFound"]

# after
[404, { "content-type" => "text/plain" }, ["NotFound"]]
```

---

## 4. `uninitialized constant` for a Rack 2 class

Rack 3 removed a number of constants. If your app or a third-party middleware
uses one, it fails at load time:

| Removed | Use instead |
|---|---|
| `Rack::Utils::HeaderHash` | `Rack::Headers` |
| `Rack::File` | `Rack::Files` |
| `Rack::Session::Cookie` | the `rack-session` gem (Sinatra already depends on it) |
| `Rack::Handler` | `Rackup::Handler`, from the `rackup` gem |

If the failure comes from a gem rather than your code, check whether it has a
Rack 3 compatible release. This is the most common reason an upgrade stalls,
and it is nothing Startback can shield you from.

Sinatra 4 also dropped the `IndifferentHash` initializer, disabled
`session_hijacking` protection by default, and removed
`Rack::Protection::EncryptedCookie` (cookies are still encrypted, by
`Rack::Session::Cookie`). And if you start the server by running the app file
directly rather than through `config.ru` + puma, you now need the `rackup` gem
in your Gemfile.

---

## 5. Puma: lifecycle hooks renamed, and a new default bind

Puma goes from 6 to 8, crossing two majors. Startback never loads puma itself
-- it ships it for you -- so nothing here is detectable by Startback's tests.

**Puma 7 renamed every lifecycle hook.** If your `puma.rb` uses the old names
they are simply not called, silently:

| Before | After |
|---|---|
| `on_worker_boot` | `before_worker_boot` |
| `on_worker_shutdown` | `before_worker_shutdown` |
| `on_restart` | `before_restart` |
| `on_booted` | `after_booted` |
| `on_stopped` | `after_stopped` |
| `on_refork` | `before_refork` |
| `on_thread_start` | `before_thread_start` |

This matters most for database connection handling, which is usually exactly
what those hooks do.

**Puma 7 also** made `preload_app!` the default in clustered mode, and requires
a config instance to be `clamp`-ed before values are read.

**Puma 8** changed the default production bind from `0.0.0.0` to `::` when an
IPv6 interface is available. In a container that publishes ports over IPv4
only, this can make the service unreachable. Bind explicitly if you care:

```ruby
# puma.rb
bind 'tcp://0.0.0.0:3000'
```

**Not ready?** `gem 'puma', '~> 6.0'` in your Gemfile. Startback accepts
`>= 6.0.2, < 9.0`.

---

## 6. `undefined method 'fast_generate' for module JSON`

**Why.** json 3 removed `JSON.fast_generate`.

**Fix.** `JSON.generate`. It is the same output; `fast_generate` only skipped
the circular-reference check.

Startback used it internally in `Security::RateLimiter` and
`Caching::EntityCache#encode_key`, and both now use `JSON.generate`. **The
generated strings are identical**, so cache entries and rate-limit counters
survive the upgrade -- no cache flush needed.

---

## 7. jwt 2 to 3

Only relevant if your application uses JWT; Startback ships the gem but never
loads it. jwt 3 is a real break:

* RSA keys must be **at least 2048 bits**. Shorter keys now raise.
* Base64 decoding follows RFC 4648 strictly; tolerantly-encoded tokens that
  used to decode now fail.
* The payload cannot be read before the signature is verified.
* `HS512256` is gone.
* Custom algorithms must include `JWT::JWA::SigningAlgorithm`.
* Since 3.3: if you rescue `JWT::DecodeError`, `JWT::IncorrectAlgorithm` or
  `ArgumentError` **around `JWT.encode`**, rescue `JWT::EncodeError` instead.
  Decoding is unaffected.

Read jwt's own `UPGRADING.md` before taking it. **Not ready?**
`gem 'jwt', '~> 2.1'`. Startback accepts `>= 2.1, < 4.0`.

---

## 8. finitio 0.12 to 1.0: check your `.fio` schemas

Two removals affect schemas, and one of them changes meaning silently:

* `Fixnum` and `Bignum` are gone from `finitio/data`. Use `Integer`. This one
  fails loudly.
* **`FalseClass` was a bug and is now fixed.** It used to be an alias of
  `.TrueClass`, so it accepted `true` and rejected `false`. If a schema of
  yours worked around that -- writing `FalseClass` where it meant a *true*
  value -- it now means the opposite.

Grep before upgrading:

```sh
grep -rn "Fixnum\|Bignum\|FalseClass" --include=*.fio .
```

**Not ready?** `gem 'finitio', '~> 0.12'`. Startback accepts `>= 0.12, < 2.0`.

---

## 9. bunny 2 to 3, if you use the event bus

Applies to `Startback::Event::Bus::Bunny::Async` only.

* Versioned delivery tags are removed.
* Passive declarations (`passive: true`) are no longer replayed by topology
  recovery.
* The `openssl` gem >= 3.3 is now required, which means a native build --
  watch slim/alpine images.

**Heads up on coverage:** Startback's test matrix has no RabbitMQ, so the Bunny
bus is upgraded but *unverified by the suite*. If you use it, exercise it in a
staging environment rather than trusting the green build.

**Not ready?** `gem 'bunny', '~> 2.14'`. Startback accepts `>= 2.14, < 4.0`.

---

## 10. webspicy must move to 1.x

**You will see** `bundle install` fail outright:

```
Because every version of startback depends on rack-robustness >= 2.0, < 3.0
  and webspicy >= 0.25.0 depends on rack-robustness >= 1.2, < 2.0,
  every version of startback is incompatible with webspicy >= 0.25.0.
```

**Why.** Every webspicy 0.27.x release caps `finitio < 0.13`, `http < 6.0` and
`rack-robustness < 2.0`. webspicy 1.0 widened all three.

**Fix.** `gem 'webspicy', '>= 1.0', '< 2.0'`.

There is no way around this one, and no quiet degradation: bundler refuses to
resolve.

Coming from 0.26 or earlier, note that webspicy validates unstructured
response bodies against `output_schema` since 0.27, where it used to skip
them. A content-negotiating endpoint may need its schema widened accordingly
(e.g. `[Todo]|Csv` for one serving both JSON and CSV).

---

## Opting out, gem by gem

Startback deliberately declares **wide ranges** for the dependencies it does
not use itself, so you can stay on an older major while still upgrading
Startback. Add the pin to your own Gemfile:

| Gem | Startback accepts | Pin to stay put |
|---|---|---|
| puma | `>= 6.0.2, < 9.0` | `gem 'puma', '~> 6.0'` |
| jwt | `>= 2.1, < 4.0` | `gem 'jwt', '~> 2.1'` |
| http | `>= 5.0, < 7.0` | `gem 'http', '~> 5.0'` |
| bunny | `>= 2.14, < 4.0` | `gem 'bunny', '~> 2.14'` |
| finitio | `>= 0.12, < 2.0` | `gem 'finitio', '~> 0.12'` |
| json | `>= 2.6, < 4.0` | `gem 'json', '~> 2.6'` |

These cannot be opted out of, because Startback's own code depends on them:

| Gem | Required |
|---|---|
| sinatra | `>= 4.0, < 5.0` -- the middlewares use `Rack::Headers`, Rack 3 only |
| rack-robustness | `>= 2.0, < 3.0` -- `Shield` and `CatchAll` subclass it |
| Ruby | `>= 3.2` |

---

## Checklist

- [ ] Ruby >= 3.2
- [ ] `RACK_ENV` set in the test suite, at the top of `spec_helper.rb`
- [ ] Response triples built by hand use lowercase header names
- [ ] Response bodies are arrays, not bare Strings
- [ ] No `Rack::Utils::HeaderHash` / `Rack::File` / `Rack::Handler` left, in
      your code or your gems
- [ ] `puma.rb` lifecycle hooks renamed; bind address checked
- [ ] No `JSON.fast_generate` left
- [ ] `.fio` schemas grepped for `Fixnum`, `Bignum`, `FalseClass`
- [ ] webspicy on 1.x
- [ ] jwt / bunny reviewed, or pinned
- [ ] Bunny event bus exercised somewhere real, since CI does not cover it
