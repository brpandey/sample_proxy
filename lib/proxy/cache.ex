defmodule Proxy.Cache do
  @moduledoc """
  Cache holds key value pairs of job ids and job task pids
  This is implemented via a separate Agent process

  NOTE: 
  For prototype purposes:

  No supervision tree is currently used to restart Agent or 
  recover Agent values over

  If the task crashed no attempt is made to monitor the crashed task
  and insert a new task pid.  The task doesn't use a supervisor as well.

  The notify function uses response data size that is easily permissible to send
  as a message
  """

  require Logger

  @name __MODULE__


  @doc "Starts cache"
  def start_link do
    Agent.start_link(fn -> %{} end, name: @name) 
  end 


  @doc "Creates cache entry using the key value pair of id and pid"
  def create(id, pid) when is_binary(id) and is_pid(pid) do
    Agent.update(@name, &Map.put(&1, id, pid))    
  end


  @doc "Notify the cache with response map which sends the map to the cached pid"
  def notify(id, %{} = response) when is_binary(id) do

    # Retrieve pid value given id key
    pid = Agent.get(@name, &Map.get(&1, id))

    # Quick assert
    true = is_pid(pid)

    # Encode response map into a string format to later send
    {:ok, data} = Poison.encode(response)

    Logger.debug("notify: #{inspect pid}, #{inspect data}")

    # Pass message to pid with response data
    # Note: If data were to increase in size to say 1MB would probably want 
    # different scheme

    Kernel.send pid, {:notify, data}

  end

  @doc "Clean up the cache state when id key is no longer needed"
  def delete(id) when is_binary(id) do
    Agent.update(@name, &Map.delete(&1, id))    
  end


end
