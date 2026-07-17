# The Blog Platform

A small multi-user blogging platform built with Ruby on Rails. See the
[documentation](#documentation) for an overview of its features.

## Requirements

The application runs entirely in Docker, so the only prerequisite is Docker
with the Compose plugin:

- **macOS / Windows** — install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
- **Linux** — install [Docker Engine](https://docs.docker.com/engine/install/) and the [Compose plugin](https://docs.docker.com/compose/install/).

## Getting started

1. From the project root, build and start the services:

   ```
   docker compose up -d
   ```

2. The first run takes a few minutes while the image builds, the database is
   created and migrated, and the JavaScript packages are installed. Webpacker
   or database errors during this initial startup are expected and clear up
   once setup finishes.

3. Open <http://localhost:3000>.

Stop the services with `docker compose down`.

## Running the tests

```
docker compose exec web bash -c "RAILS_ENV=test bundle exec rails db:prepare && RAILS_ENV=test bundle exec rails test"
```

The suite also runs automatically on every push via GitHub Actions.

## Documentation

Project documentation lives in the [`docs/`](docs/) folder:

- [Application Overview](docs/overview.md) — navigation and core features.
- [Bugs Found](docs/bugs.md) — defects discovered while working on the project.
