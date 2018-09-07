# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config



# Mailgun API Credentials
config :ex_gun, :mailgun,
  base_url: "https://api.mailgun.net/v3",
  domain: "sandbox12eda3e8d240484185fda3e4127954d7.mailgun.org",
  api_key: "key-a1101b66aa1e3e425296170c2bf81f7d"



# import_config "#{Mix.env}.exs"

