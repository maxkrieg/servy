defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> rewrite_params()
    |> log()
    |> route()
    |> track()
    |> emojify()
    |> format_response()
  end

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")
    %{
      method: method,
      path: path,
      resp_body: "",
      status: nil
    }
  end

  def rewrite_path(%{ path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def rewrite_params(%{ path: "/bears?id=" <> id } = conv) do
    %{conv | path: "/bears/#{id}" }
  end

  def rewrite_params(conv), do: conv

  def log(conv), do: IO.inspect(conv, label: "Request")

  def route(%{ path: "/wildthings", method: "GET" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, and Tigers"}
  end

  def route(%{ path: "/bears", method: "GET" } = conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{ path: "/bears/" <> id, method: "GET" } = conv) do
    %{ conv | status: 200, resp_body: "GET Bear #{id}"}
  end

  def route(%{ path: "/bears/" <> id, method: "DELETE" } = conv) do
    %{ conv | status: 200, resp_body: "DELETE Bear #{id}"}
  end

  def route(%{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here" }
  end

  def track(%{status: 404, path: path} = conv) do
    IO.puts("Warning: #{path} does not exist")
    conv
  end

  def track(conv), do: conv

  def emojify(%{ status: 200, resp_body: resp_body } = conv) do
    emojies = String.duplicate("😃", 5)
    resp_body = emojies <> "\n" <> resp_body <> "\n" <> emojies
    %{ conv | resp_body: resp_body}
  end

  def emojify(conv), do: conv

  def format_response(%{ resp_body: resp_body, status: status }) do
    """
    HTTP/1.1 #{status} #{status_reason(status)}
    Content-Type: text/html
    Content-Length: #{String.length(resp_body)}

    #{resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end


request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request2 = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request3 = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request4 = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request5 = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request6 = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request7 = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
response2 = Servy.Handler.handle(request2)
response3 = Servy.Handler.handle(request3)
response4 = Servy.Handler.handle(request4)
response5 = Servy.Handler.handle(request5)
response6 = Servy.Handler.handle(request6)
response7 = Servy.Handler.handle(request7)

IO.puts("------------------")
IO.puts(response)
IO.puts("------------------")
IO.puts(response2)
IO.puts("------------------")
IO.puts(response3)
IO.puts("------------------")
IO.puts(response4)
IO.puts("------------------")
IO.puts(response5)
IO.puts("------------------")
IO.puts(response6)
IO.puts("------------------")
IO.puts(response7)
