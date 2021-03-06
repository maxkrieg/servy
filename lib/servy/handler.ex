defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  require Logger
  alias Servy.Conv
  alias Servy.BearController
  import Servy.Plugins, only: [rewrite_path: 1, rewrite_params: 1, log: 1, track: 1, emojify: 1]
  import Servy.Parser, only: [parse: 1]

  @pages_path Path.expand("pages", File.cwd!)

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

  def route(%Conv{ path: "/wildthings", method: "GET" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, and Tigers"}
  end

  def route(%Conv{method: "POST", path: "/bears", params: params } = conv) do
    BearController.create(conv, params)
  end

  def route(%Conv{ path: "/bears", method: "GET" } = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ path: "/bears/new", method: "GET" } = conv) do
    open_file("form")
    |> handle_file(conv)
  end

  def route(%Conv{ path: "/bears/" <> id, method: "GET" } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ path: "/bears/" <> id, method: "DELETE" } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{ path: "/about", method: "GET" } = conv) do
    open_file("about")
    |> handle_file(conv)
  end

  def route(%Conv{ path: "/pages/" <> file, method: "GET" } = conv) do
    open_file(file)
    |> handle_file(conv)
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here" }
  end

  def open_file(file) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
  end

  def handle_file({:ok, content}, %Conv{} = conv), do: %{conv | status: 200, resp_body: content }

  def handle_file({:error, :enoent}, %Conv{} = conv), do: %{conv | status: 404, resp_body: "File Not Found"}

  def handle_file({:error, reason}, %Conv{} = conv), do: %{conv | status: 500, resp_body: "File error #{reason}"}

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
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

request10 = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

# TODO: Convert to unit tests
IO.puts("------------------")
Servy.Handler.handle(request) |> IO.puts()
Servy.Handler.handle(request2) |> IO.puts()
Servy.Handler.handle(request3) |> IO.puts()
Servy.Handler.handle(request4) |> IO.puts()
Servy.Handler.handle(request5) |> IO.puts()
Servy.Handler.handle(request6) |> IO.puts()
Servy.Handler.handle(request7) |> IO.puts()
Servy.Handler.handle(request8) |> IO.puts()
Servy.Handler.handle(request9) |> IO.puts()
Servy.Handler.handle(request10) |> IO.puts()
