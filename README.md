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

## Getting Started

```bash
$ mix deps.get
$ mix compile
$ iex -S mix
```



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
```

```elixir
# Example: Welcome Template with name attribute

ExGun.Client.send_email(%{
  to: "authorized@example.com",
  subject: "Welcome to ExGun!",
  template: :welcome,
  attributes: %{ name: "John" },
})
```

```elixir
# Example: Password Reset Template with name and link attributes

ExGun.Client.send_email(%{
  to: "authorized@example.com",
  subject: "Reset Your Password",
  template: :password_reset,
  attributes: %{ name: "Joyce", link: "http://example.com/password/reset" },
})
```
