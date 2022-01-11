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
    %{
      method: method,
      path: path,
      resp_body: "",
      status: nil
    }
  end

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

response = Servy.Handler.handle(request)
response2 = Servy.Handler.handle(request2)
response3 = Servy.Handler.handle(request3)
response4 = Servy.Handler.handle(request4)
response5 = Servy.Handler.handle(request5)

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
