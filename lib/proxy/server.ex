defmodule Proxy.Server do
  @moduledoc """
  Handles proxy server routes.  
  One route is used by the jobclient, the other by the job server.
  Uses Cowboy for the web server which uses Ranch to handle socket acceptor pools
  """

  require Logger
  use Plug.Router


  plug Plug.Parsers,
  pass: ["*/*"],
  parsers: [:json, :multipart],
  json_decoder: Poison


  plug :match
  plug :dispatch


  @port 3738

  # path for proxied jobs server
  @upstream_path "/start"

  # call back path for jobs server to use
  @callback_path "/callback"

  # job status state names
  @initial_state "running"
  @completed_state "completed"


  @doc "Starts the cowboy web server"
  def start_server do
    Plug.Adapters.Cowboy.http(__MODULE__, nil, port: @port)
  end


  # Post macro, matches POST request and / path  (Accessed by jobclient)
  post "/" do

    conn = conn |> Plug.Conn.fetch_query_params

    # Extract params
    %{params: %{} = params} = conn

    Logger.debug """
      handler 1a
      Conn: #{inspect conn}
    """

    # Make sure params has account key

    cond do 
      Map.has_key?(params, "account") ->

        # Add wait and callback attributes to params

        callback_url = conn.host <> @callback_path

        async_params = 
          params 
          |> Map.put("wait", false) # we want async mode not sync
          |> Map.put("callback", callback_url) # allows job server to call us back


        response = Proxy.Helper.post!(@upstream_path, async_params, [])
        
        # 1st Response Example

        # %HTTPoison.Response{body: %{"id" => "55e7869a3382f973", "state" => "running"}, headers: [{"Connection", "keep-alive"}, {"Server", "Cowboy"}, {"Date", "Wed, 30 Aug 2017 21:48:47 GMT"}, {"Content-Length", "43"}, {"Content-Type", "application/json; charset=utf-8"}, {"Cache-Control", "max-age=0, private, must-revalidate"}, {"Via", "1.1 vegur"}], status_code: 200}


        Logger.debug """
        handler 1b
        async_params: #{inspect async_params}
        Response: #{inspect response}
        """

        # retrieve job id
        id = response.body["id"]

        # assert state is correct
        @initial_state = response.body["state"]


        # let Proxy Async handle the details of the async callback
        # coordination given the job id

        # Note method blocks until callback is performed

        {code, data} = Proxy.Async.handle_async_callback(id)

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(code, Poison.encode!(data))
        
      
      true ->

        msg = %{"Error" => "Account omitted"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(400, Poison.encode!(msg))
        
    end
      
  end


  # Post macro, matches POST request and /callback path  (Accessed by job server)
  post @callback_path do

    conn = conn |> Plug.Conn.fetch_query_params

    %{params: %{} = params} = conn

    Logger.debug """
      handler 2
      Conn: #{inspect conn}
    """


    # Method: "POST"
    # Path: 8b2fc331.ngrok.io/callback
    # Parameters: %{"id" => "55e7869a3382f973", "proof" => "8EB212F97573C8E0605078568084BAB430D71F4A", "startedAt" => "2017-08-30T21:48:48.444Z", "state" => "completed"}
    # Headers: [{"content-type", "application/json"}, {"user-agent", "hackney/1.2.0"}, {"host", "8b2fc331.ngrok.io"}, {"content-length", "135"}, {"x-forwarded-for", "54.224.200.76"}]


    # retrieve job id
    id = params["id"]

    # assert state is correct
    @completed_state = params["state"]

    # notify Proxy.Async of job completed data
    Proxy.Async.notify(id, params)

    # send reponse back to proxied server
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, Poison.encode!(%{"Thank You For" => "Remembering to Callback!!!!"}))

  end


  # default match macro
  match _ do
    Plug.Conn.send_resp(conn, 404, "not found")
  end
  
end
