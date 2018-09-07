defmodule ExGun.Client.Template do
  @moduledoc """
  Builds Email Templates according to given EEx files
  """

  @root_dir Path.join(:code.priv_dir(:ex_gun), "email_templates")


  def load(name, bindings \\ []) do
    bindings = Enum.into(bindings, [])
    template = Path.join(@root_dir, "#{name}.html.eex")

    case File.exists?(template) do
      true  -> EEx.eval_file(template, bindings)
      false -> raise "Template '#{name}.html.eex' does not exist"
    end

  rescue
    CompileError ->
      raise "Required Attribute Bindings not specified"
  end

end
