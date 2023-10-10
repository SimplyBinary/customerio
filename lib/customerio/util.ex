defmodule Customerio.Util do
  @moduledoc false

  @type value :: number | String.t() | atom()
  @behavioral_base_route "https://track.customer.io/api/v1/"
  @api_base_route "https://api.customer.io/v1/"

  defp put_opts(:tracking, opts) do
    tracking_site_id = Application.get_env(:customerio, :tracking_site_id)
    tracking_api_key = Application.get_env(:customerio, :tracking_api_key)
    Keyword.merge([basic_auth: {tracking_site_id, tracking_api_key}], opts)
  end

  defp put_opts(:api, opts), do: opts

  defp get_headers(:tracking) do
    [{"Content-Type", "application/json"}]
  end

  defp get_headers(:api) do
    app_api_key = Application.get_env(:customerio, :app_api_key)

    [
      {"Authorization", "Bearer #{app_api_key}"},
      {"Content-Type", "application/json"}
    ]
  end

  @typedoc """
  Available HTTP methods
  """
  @type method :: :get | :post | :delete | :put | :patch

  @doc """
  This method sends requests to `customer.io` Behavioral API endpoint, with
  defined method, route, body and Hackney options.
  """
  @spec send_behavioral_request(
          method :: method,
          route :: String.t(),
          data_map :: map(),
          opts :: Keyword.t()
        ) :: {:ok, String.t()} | {:error, Customerio.Error.t()}
  def send_behavioral_request(method, route, data_map, opts \\ []) do
    send_request(
      method,
      @behavioral_base_route <> route,
      data_map,
      get_headers(:tracking),
      put_opts(:tracking, opts)
    )
  end

  @doc """
  This method sends requests to `customer.io` API endpoint, with
  defined method, route, body and Hackney options.
  """
  @spec send_api_request(
          method :: method,
          route :: String.t(),
          data_map :: map(),
          opts :: Keyword.t()
        ) :: {:ok, String.t()} | {:error, Customerio.Error.t()}
  def send_api_request(method, route, data_map, opts \\ []) do
    send_request(
      method,
      @api_base_route <> route,
      data_map,
      get_headers(:api),
      put_opts(:api, opts)
    )
  end

  @spec send_request(
          method :: method,
          route :: String.t(),
          data_map :: map(),
          headers :: Keyword.t(),
          opts :: Keyword.t()
        ) :: {:ok, String.t()} | {:error, Customerio.Error.t()}
  defp send_request(method, route, data_map, headers, opts) do
    case :hackney.request(
           method,
           route,
           headers,
           data_map |> Jason.encode!(),
           opts
         ) do
      {:ok, 200, _, client_ref} ->
        case :hackney.body(client_ref) do
          {:ok, data} -> {:ok, data}
          _ -> {:error, %Customerio.Error{reason: "hackney internal error"}}
        end

      {:ok, status_code, _, client_ref} ->
        {:error, %Customerio.Error{code: status_code, reason: elem(:hackney.body(client_ref), 1)}}

      {:error, reason} ->
        {:error, %Customerio.Error{reason: reason}}
    end
  end
end
