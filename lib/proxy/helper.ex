defmodule Proxy.Helper do

  use HTTPoison.Base # injects methods post! and get! etc..

  require Logger

  
  @url "http://jobs.asgateway.com"

  
  def process_url(url) do
    @url <> url
  end


  def process_request_body(body) do
    Poison.encode!(body)
  end
  
  def process_request_headers(headers) do
    [{"Content-Type", "application/json"} | headers]
  end


  def process_response_body(body) do
    try do
      Poison.decode!(body)
    rescue
      _ -> body
    end
  end



end
