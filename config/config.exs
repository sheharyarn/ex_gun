# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config



# Mailgun API Credentials
config :ex_gun, :mailgun,
  base_url: "https://api.mailgun.net/v3",
  api_key:  System.get_env("EXGUN_MAILGUN_KEY"),
  domain:   System.get_env("EXGUN_MAILGUN_DOMAIN")



# import_config "#{Mix.env}.exs"

