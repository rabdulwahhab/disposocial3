# Disposocial3

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix

## Deployment

Env vars needed:
- `GEOAPIFY_KEY`: geoapify API key
- `MAILERSEND_SMTP_USERNAME`: the smtp username
- `MAILERSEND_SMTP_PASSWORD`: the smtp password
- `DATABASE_PATH`: the path to the sqlite3 db
- `PHX_HOST`: the domain that this web app will use (e.g. rabdulwahhab.com)
- `PORT`: the port to run the app on
- `SECRET_KEY_BASE`: self-explanatory. Generate on dev machine with `mix phx.gen.secret`

0. Build code for prod
```
mix clean
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix phx.gen.release [--docker]
MIX_ENV=prod mix release
```

1. Build the Docker image
```
sudo docker image build --tag rabdulwahhab/my_site:latest .
```

2. Run a container with it
```
sudo docker run [-it] [-d] --restart always --env-file .env -p 127.0.0.1:<HOST_PORT>:<CONTAINER_PORT> my_site:<version>
```

If deploying the container on another machine, then you either need to:
1. Push the above image to a registry and pull on the machine, then run
2. Build the code and then build the image on the machine (steps 0 and 1)

```
docker push rabdulwahhab/my_site:latest
