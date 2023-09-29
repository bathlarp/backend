# BathLARP Backend

This is the API backend for the BathLARP website.

## Getting started

### VS Code devcontainers

The easiest (and recommended!) way to get started with this application is using
VS Code devcontainers.

Prerequisites:

- Docker (other container runtimes may also work, but haven't been tried)
- VS Code

Steps:

- Clone the repository to a location of your choice.
- Copy `example.env` to `.env`.
- Open the project in VS Code.
- When prompted, choose to reopen in container.

This may take a while the first time while the necessary images are downloaded,
but eventually you should have a development environment up and running,
complete with a database server.

### Without devcontainers

If you want to go it alone, you'll need something along the following lines:

Prerequisites:

- Elixir 1.15.x
  - Follow the instructions [here](https://elixir-lang.org/install.html) to get
    this installed.
- A Postgres database server
  - The development and test configuration assumes that the database server is
    available on a host called `database` and that there's an account called
    `postgres` with a password of `postgres`. If yours isn't, you can set the
    following environment variables to suitable values:
    - `BATHLARP_DATABASE_HOST`: The hostname of your database server.
    - `BATHLARP_DATABASE_USER`: The username of a user on your database server.
      (Must have sufficient privileges to create and drop databases.)
    - `BATHLARP_DATABASE_PASS`: The password of the database user.

## First run

- Make sure that code quality checks are run on each commit:
  - `pre-commit install`
- Create, migrate and seed the database:
  - `mix ecto.setup`

## Handy commands

- Run the tests:
  - `mix test`
- Run the application:
  - `mix phx.server`
  - The application will be made available on <http://localhost:4000> (you'll
    need an API client to interact with it, though).
  - You can also access a dashboard at <http://localhost:4000/dev/dashboard>
    that will give you quite a lot of information about how it's performing.
  - To stop the server again, press Ctrl-C twice.
- Run the application inside an interactive console (handy for debugging):
  - `iex -S mix phx.server`
- Tear down the database and start afresh (DANGER: This will delete any data you
  already had in it!):
  - `mix ecto.reset`

## Code quality

Various checks will be run as part of any PR before it can be merged. To
make life easier for everyone, you can run these locally too:

- Check for code quality issues:
  - `mix credo`
- Fix formatting:
  - `mix format`
