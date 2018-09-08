ExGun
=====

> Basic Mailgun API Implementation


## Configuration

You need to pass your Mailgun API Key and Domain via the environment variables. They will be then loaded
into the application automatically (or you can directly specify them in `config/config.exs`).

```bash
$ export EXGUN_MAILGUN_KEY="<YOUR_API_KEY>"
$ export EXGUN_MAILGUN_DOMAIN="<YOUR_DOMAIN>"
```

<br/>



## Getting Started

```bash
$ mix deps.get
$ mix compile
$ iex -S mix
```

<br/>




## Sending Emails via Commands

All (valid) emails are added to the Mailgun queue immediately and sent from the default address of
`noreply@test.mailgun.org`. You can change this address by modifying the `@from_email` attribute in the
`ExGun.Client` module.


### Simple Emails

You can send simple emails by calling `ExGun.Client.send_email/1` and passing these three attributes:

 - `to:` Address to send to emails (Remember to add it to authorized recipients for Sandbox domains)
 - `subject:` Subject of the Email
 - `body:` HTML body of the email


```elixir
# Example

ExGun.Client.send_email(%{
  to: "authorized.address@example.com",
  subject: "Test Email",
  body: "<p>Hello! This is a test email!</p>",
})
# => {:ok, %{id: "...", message: "Queued. Thank you."}}
```


### Templated Emails

You can also send templated emails, but a template first needs to be defined in the `priv/email_templates`
directory. Three templates have already been defined in the directory: `welcome.html.eex` (with one attribute `name`),
`no_attrs.html.eex` (with no attribute bindings) and `password_reset.html.eex` (with two attributes `name` and `link`).
You need to pass a map with at least three params to send a templated email:

 - `to:` Address to send to emails
 - `subject:` Subject of the Email
 - `template:` Name of the template (without the `.html.eex` part)
 - `attributes:` An optional map of attribute bindings for the template


```elixir
# Example: Template with no attributes
ExGun.Client.send_email(%{
  to: "authorized@example.com",
  subject: "No Attrs",
  template: "no_attrs",
})


# Example: Welcome Template with name attribute
ExGun.Client.send_email(%{
  to: "authorized@example.com",
  subject: "Welcome to ExGun!",
  template: :welcome,
  attributes: %{ name: "John" },
})
```

**NOTE:** If you absolutely want to use JSON, use `send_email_json/1`:

```elixir
ExGun.Client.send_email_json ~S({
  "to": "authorized@example.com",
  "subject": "Reset Your Password",
  "template": "password_reset",
  "attributes": {
    "name": "Joyce",
    "link": "http://example.com/password/reset"
  }
})
```

<br/>



## Sending Emails via API

The application also starts an extremely light-weight Web Server on port `4000` that accepts JSON
web requests to send emails. Complication authorization or a large framework like Phoenix were not
used on purpose. Instead, it's a simple `Plug.Router` definition (`ExGun.Web.Router`) was used that
handles these requests.


To send a simple email via cURL:

```bash
curl http://localhost:4000/send-email \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"to": "authorized@example.com", "subject": "Test from cURL", "body": "Hello!"}'

# => {"id":"...","message":"Queued. Thank you."}
```


To send a templated email via cURL:

```bash
curl http://localhost:4000/send-email \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "to": "authorized@example.com",
    "subject": "Test from cURL",
    "template": "password_reset",
    "attributes": {
      "name": "John",
      "link": "http://example.com/password/reset"
    }
  }'

# => {"id":"...","message":"Queued. Thank you."}
```

<br/>



## Sending Emails via Queue

Finally, a long-running GenServer process is also started as part of the Application Supervision
Tree. It listens to an AMQP protocol based exchange/queue (RabbitMQ in this example) and on
receiving a payload, passes it to `ExGun.Client.send_email_json`. In case of success or failure,
the responses are logged to the console (email jobs are not restarted on purpose).

To test emails via RabbitMQ, pass it a JSON payload. You can also do that directly within the
application:

```elixir
ExGun.Queue.enqueue ~S({
  "to": "authorized@example.com",
  "subject": "Reset Your Password",
  "template": "password_reset",
  "attributes": {
    "name": "Joyce",
    "link": "http://example.com/password/reset"
  }
})
```
