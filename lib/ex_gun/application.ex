defmodule ExGun.Application do
  use Application

  @moduledoc false



  def start(_type, _args) do
    children = [
      ExGun.Queue,
      ExGun.Web.Router.spec,
    ]

    opts = [strategy: :one_for_one, name: ExGun.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
