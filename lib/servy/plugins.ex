defmodule Servy.Plugins do

  require Logger

  def rewrite_path(%{ path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def rewrite_params(%{ path: "/bears?id=" <> id } = conv) do
    %{conv | path: "/bears/#{id}" }
  end

  def rewrite_params(conv), do: conv

  def log(conv) do
    Logger.info("Request #{inspect(conv)}")
    conv
  end

  def track(%{status: 404, path: path} = conv) do
    Logger.warn("Warning: #{path} does not exist")
    conv
  end

  def track(conv), do: conv

  def emojify(%{ status: 200, resp_body: resp_body } = conv) do
    emojies = String.duplicate("😃", 5)
    resp_body = emojies <> "\n" <> resp_body <> "\n" <> emojies
    %{ conv | resp_body: resp_body}
  end

  def emojify(conv), do: conv
end
