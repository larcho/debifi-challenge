# Bugs Found

This document records the defects found in the application while working on it,
whether during exploration, while building out the test suite, or during later
review. Each entry notes where the problem was, its impact, and how it was
resolved. All items below have been fixed; the commit that addressed each one
is referenced.

## Summary

| # | Bug | Area | Severity | Status |
|---|-----|------|----------|--------|
| 1 | Search input allowed SQL injection | Posts search | Critical | Fixed (`fd6ffcf`) |
| 2 | Post body rendered unsanitized (stored XSS) | Post display | Critical | Fixed (`fd6ffcf`) |
| 3 | Editing a post never saved changes | Posts update | High | Fixed (`e42edfa`) |
| 4 | Database configured for the wrong engine | Config | High | Fixed (`d0c5703`) |
| 5 | Test runs used the development database | Config | High | Fixed (`d0c5703`) |
| 6 | Title search only matched suffixes | Posts search | Medium | Fixed (`fd6ffcf`) |
| 7 | "Title too long" error showed a broken message | Validation | Low | Fixed (`e42edfa`) |
| 8 | Post pages required login but the list did not | Access control | Low | Fixed (`46d81c5`) |
| 9 | Missing posts showed an internal error | Error handling | Medium | Fixed (`b684dc3`) |
| 10 | Plans page showed a badly rounded exchange rate | Plans page | Low | Fixed (`c50ca70`) |

---

## 1. Search input allowed SQL injection (Critical)

**Location:** `app/controllers/posts_controller.rb` (`#index`)

The post search built its SQL query by interpolating the raw search term
directly into the query string
(`where("title ILIKE '%#{q}' OR html_body ILIKE '%#{q}%'")`). A crafted search
term such as `' OR 1=1 --` could break out of the intended query and run
arbitrary SQL, exposing or manipulating data.

**Fix:** The query now uses a bound parameter and escapes `LIKE` wildcards with
`sanitize_sql_like`, so user input is always treated as literal text.

## 2. Post body rendered unsanitized — stored XSS (Critical)

**Location:** `app/views/posts/_post.html.erb`

Post bodies were rendered with `raw`, outputting whatever HTML a user had
saved without any cleaning. Because posts are visible to everyone, a post
containing `<script>` or an inline event handler would execute in the browser
of every visitor who viewed it — a stored cross-site scripting vulnerability.

**Fix:** Post bodies are now rendered through `sanitize`, which preserves safe
formatting tags while stripping scripts and inline event handlers.

## 3. Editing a post never saved changes (High)

**Location:** `app/controllers/posts_controller.rb` (`#update`)

The update action looked up the post and immediately redirected with a
"Post was saved" message without ever applying the submitted values. Edits
appeared to succeed but silently discarded all changes, and invalid input was
never reported.

**Fix:** The action now applies the submitted parameters and re-renders the
edit form with validation errors when the update fails.

## 4. Database configured for the wrong engine (High)

**Location:** `config/database.yml`

The database configuration declared the SQLite adapter, but the application
targets PostgreSQL everywhere else (the `pg` gem, the schema definition, and
the Docker setup). The configuration could not actually connect the app to its
real database and contradicted the rest of the project.

**Fix:** `database.yml` was rewritten for PostgreSQL with proper per-environment
database names.

## 5. Test runs used the development database (High)

**Location:** `docker-compose.yml`

A single `DATABASE_URL` pointing at the development database was applied to
every environment, including the test environment. Running the test suite
would therefore read and write the development data instead of an isolated
test database.

**Fix:** The blanket `DATABASE_URL` was removed so that `database.yml` drives
the connection per environment (development uses `blog_dev`, test uses
`blog_test`).

## 6. Title search only matched suffixes (Medium)

**Location:** `app/controllers/posts_controller.rb` (`#index`)

The title portion of the search pattern was missing its trailing wildcard
(`'%#{q}'` instead of `'%#{q}%'`), so a search only matched titles that *ended*
with the search term. Matching text in the middle of a title returned nothing.

**Fix:** The rewritten, parameterized query uses a `%term%` pattern for both the
title and the body, so titles match the search term anywhere.

## 7. "Title too long" error showed a broken message (Low)

**Location:** `config/locales/en.yml`

The custom validation message for a too-long post title was set to the literal
translation key path, so submitting an over-long title displayed
`en.activerecord.errors.models.post.attributes.title.too_long` instead of a
readable message. (The too-short message was unaffected and worked normally.)

**Fix:** The message was restored to the standard "is too long (maximum is
%{count} characters)" text.

## 8. Post pages required login but the list did not (Low)

**Location:** `app/controllers/posts_controller.rb`

The post list was open to visitors, but opening an individual post required
signing in. A guest could see a post in the list yet be redirected to the
login screen when trying to read it — an inconsistent experience.

**Fix:** Viewing an individual post no longer requires authentication, matching
the public post list.

## 9. Missing posts showed an internal error (Medium)

**Location:** `app/controllers/posts_controller.rb`

Opening a post that does not exist (for example `/posts/2` after it was deleted)
raised `ActiveRecord::RecordNotFound`, which surfaced an internal error page
instead of a proper "not found" response. The same happened when acting on
another user's post, which is looked up through the current user's posts.

**Fix:** `ApplicationController` now rescues `RecordNotFound` and renders an
in-app "Not found" page with a 404 status.

## 10. Plans page showed a badly rounded exchange rate (Low)

**Location:** `app/views/pages/plans.html.erb`, `app/services/exchange_rate_fetcher_service.rb`

The Monthly plan printed the raw, high-precision result of the currency
conversion (for example `105.4940263364437080317432 CZK`) because the value was
never rounded for display.

**Fix:** The converted amount is rounded to a whole koruna, matching the Yearly
plan. The exchange-rate lookup was also switched to the free, key-less
Frankfurter API, which returns the rate directly.
