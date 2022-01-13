defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  require Logger
  import Servy.Plugins, only: [rewrite_path: 1, rewrite_params: 1, log: 1, track: 1, emojify: 1]
  import Servy.Parser, only: [parse: 1]

  @pages_path Path.expand("../../pages", __DIR__)

  @doc """
  Request response pipe handler
  """
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

  def route(%{ path: "/wildthings", method: "GET" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, and Tigers"}
  end

  def route(%{ path: "/bears", method: "GET" } = conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{ path: "/bears/new", method: "GET" } = conv) do
    open_file("form")
    |> handle_file(conv)
  end

  def route(%{ path: "/bears/" <> id, method: "GET" } = conv) do
    %{ conv | status: 200, resp_body: "GET Bear #{id}"}
  end

  def route(%{ path: "/bears/" <> id, method: "DELETE" } = conv) do
    %{ conv | status: 200, resp_body: "DELETE Bear #{id}"}
  end

  def route(%{ path: "/about", method: "GET" } = conv) do
    open_file("about")
    |> handle_file(conv)
  end

  def route(%{ path: "/pages/" <> file, method: "GET" } = conv) do
    open_file(file)
    |> handle_file(conv)
  end

  def route(%{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here" }
  end

  def open_file(file) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
  end

  def handle_file({:ok, content}, conv), do: %{conv | status: 200, resp_body: content }

  def handle_file({:error, :enoent}, conv), do: %{conv | status: 404, resp_body: "File Not Found"}

  def handle_file({:error, reason}, conv), do: %{conv | status: 500, resp_body: "File error #{reason}"}

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


# TODO: Convert all of these into unit tests

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

request8 = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request9 = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

# TODO: Convert to unit tests

response = Servy.Handler.handle(request)
response2 = Servy.Handler.handle(request2)
response3 = Servy.Handler.handle(request3)
response4 = Servy.Handler.handle(request4)
response5 = Servy.Handler.handle(request5)
response6 = Servy.Handler.handle(request6)
response7 = Servy.Handler.handle(request7)
response8 = Servy.Handler.handle(request8)
response9 = Servy.Handler.handle(request9)

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
IO.puts("------------------")
IO.puts(response8)
IO.puts("------------------")
IO.puts(response9)
