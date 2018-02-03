defmodule SampleProxy do
  use Application
  require Logger

  def start(_type, args) do
    _ = Logger.info("Starting SampleProxy Application, args: #{inspect(args)}")
    Proxy.Server.start_server()
    Proxy.Cache.start_link()
  end
end
