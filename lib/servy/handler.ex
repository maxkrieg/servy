defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> log
    |> route()
    |> format_response()
  end

  def log(conv), do: IO.inspect(conv, label: "Request")

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")
    %{ method: method, path: path, resp_body: "" }
  end

  def route(%{ path: "/wildthings", method: "GET" } = conv) do
    %{ conv | resp_body: "Bears, Lions, and Tigers"}
  end

  def route(%{ path: "/bears", method: "GET" } = conv) do
    %{ conv | resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(conv) do
    %{ conv | resp_body: "Generic response"}
  end

  def format_response(%{ resp_body: resp_body }) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{String.length(resp_body)}

    #{resp_body}
    """
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

response = Servy.Handler.handle(request)
response2 = Servy.Handler.handle(request2)
response3 = Servy.Handler.handle(request3)

IO.puts("------------------")
IO.puts(response)
IO.puts("------------------")
IO.puts(response2)
IO.puts("------------------")
IO.puts(response3)
