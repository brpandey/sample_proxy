defmodule Proxy.Async do
  @moduledoc """
  Handles coordination of async job processing

  Module is not a standalone process but augments caller's process
  """

  require Logger

  # arbitrary value for timeout, just less than 5 secs
  @timeout 4000

  @success_code 200
  @failure_code 400

  @doc """
  Coordinates processing of async callback by blocking on a task
  that gets unblocked once the post callback handler is correctly 
  triggered and sends the callback message data

  Note called as part of the Plug socket handler process for path /
  """

  def handle_async_callback(id) when is_binary(id) do
    # Create Task process which is a simple receive block,
    # blocking until a message is sent to it.  Works well with 
    # Task yield.  Allows message passing from another process
    # in this case the callback message data

    task =
      Task.async(fn ->
        receive do
          {:notify, msg} -> msg
        end
      end)

    Logger.debug("Task info is #{inspect(task)}")

    # Store id and task.pid into agent so its accessible 
    # eventually by post callback handler process

    Proxy.Cache.create(id, task.pid)

    # Wait until the task pid has received the
    # callback response message from the callback post handler

    {code, data} =
      try do
        {:ok, data} = Task.yield(task, @timeout)

        {@success_code, Poison.decode!(data)}
      catch
        :exit, {:timeout, _} ->
          {@failure_code, %{"error" => "Task Timed Out"}}
      end

    Logger.debug("Response data is #{inspect(data)}")

    # delete id from Cache
    Proxy.Cache.delete(id)

    # Cleanup the task
    Task.shutdown(task)

    {code, data}
  end

  @doc """
  Notify Async logic that callback response has been received
  Note: called as part of the Plug socket handler process for path /callback
  """

  def notify(id, %{} = response) when is_binary(id) do
    # Assert well formed response
    true = Map.has_key?(response, "id")
    true = Map.has_key?(response, "state")
    true = Map.has_key?(response, "startedAt")
    true = Map.has_key?(response, "proof")

    # Notify the cache with response map which sends the map to the cached pid
    Proxy.Cache.notify(id, response)
  end
end
