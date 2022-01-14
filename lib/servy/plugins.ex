defmodule Servy.Plugins do

  require Logger

  alias Servy.Conv

  def rewrite_path(%Conv{ path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def rewrite_params(%Conv{ path: "/bears?id=" <> id } = conv) do
    %{conv | path: "/bears/#{id}" }
  end

  def rewrite_params(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    Logger.info("Request #{inspect(conv)}")
    conv
  end

  def track(%Conv{status: 404, path: path} = conv) do
    Logger.warn("Warning: #{path} does not exist")
    conv
  end

  def track(%Conv{} = conv), do: conv

  def emojify(%Conv{ status: 200, resp_body: resp_body } = conv) do
    emojies = String.duplicate("😃", 5)
    resp_body = emojies <> "\n" <> resp_body <> "\n" <> emojies
    %{ conv | resp_body: resp_body}
  end

  def emojify(%Conv{} = conv), do: conv
end
