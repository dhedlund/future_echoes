defmodule FutureEchoes.ConfigProvider do
  @moduledoc """
  Configuration provider module for FutureEchoes and dependencies.

  This configuration provider reads configs from the environment and .env files.
  It is responsible for casting and validation. An environment variable should
  be cast to a known type before being validated. Validation functions should
  return the same type they are provided.

  Values provided by this module should be converted when used to configure an
  application.

  This module handles all necessary environment variable parsing for runtime
  configuration.
  """

  use Vapor.Planner

  require Logger

  @type cidr_range :: {:inet.ip_address(), range}
  @type ip :: :inet.ip_address() | cidr_range
  @type ipv4_range :: 0..32
  @type ipv6_range :: 1..128
  @type range :: ipv4_range | ipv6_range

  # ============================================================================
  # Configuration mapping

  dotenv()

  # The second parameter to the `config/2` macro *must* be an explicit call to
  # one of the appropriate functions provided by `Vapor.Planner`.
  #
  # Default value should be the same type as the output of a variable's map
  # function

  config :future_echoes,
         env([
           {:arnolds_haircut, "ARNOLDS_HAIRCUT", required: false},
           {:holly, "HOLLY_CONFIG", required: true, map: &(&1 |> decode() |> cast_json(:map, keys: :atoms))},
           {:listers_goldfish, "GOLDFISH", required: false, default: [], map: &cast_comma_separated_list/1},
           {:white_corridor_159_vocab_unit, "WHITE_CORRIDOR_159_VOCAB", required: false, map: &cast_atom/1}
         ])

  config :libcluster,
         env([
           {:dns_query, "CLUSTER_DNS_QUERY", required: false},
           {:enabled?, "ENABLE_CLUSTERING", required: false, default: true, map: &cast_boolean/1},
           {:node_basename, "NODE_SNAME", required: false}
         ])

  # ============================================================================
  # Casting and validation implementations

  @spec cast_atom(String.t()) :: atom
  @doc """
  Casts a string to an atom.

  ## Example:

      iex> cast_atom("fishyfish")
      :fishyfish
  """
  def cast_atom(input), do: String.to_atom(input)

  @doc """
  Decodes a json data structure, ensuring it is the correct type.

  Accepts an optional list of opts that will be passed to the Jason decoder.

  ## Examples

      iex> cast_json(~S|{"foo": "bar"}|, :map)
      %{"foo" => "bar"}

      iex> cast_json(~S|["foo", "bar"]|, :list)
      ["foo", "bar"]

      iex> cast_json(~S|{"foo": "bar"}|, :map, keys: :atoms)
      %{foo: "bar"}

      iex> cast_json(nil, :map)
      nil
  """
  @spec cast_json(input :: String.t() | nil, type :: :list | :map, jason_opts :: Keyword.t()) ::
          map | list | nil
  def cast_json(input, type, jason_opts \\ [])

  def cast_json(nil = _input, _type, _jason_opts), do: nil

  def cast_json("" <> _ = input, type, jason_opts) do
    case {type, Jason.decode!(input, jason_opts)} do
      {:list, value} when is_list(value) -> value
      {:map, value} when is_map(value) -> value
    end
  end

  @spec cast_boolean(String.t()) :: boolean
  @doc """
  Casts the strings "true" and "false" to their boolean atom form.

  This function will accept any case for the input strings, so "TRUE", "True",
  and "tRUE" are all equivalent.

  ## Examples:

      iex> cast_boolean("true")
      true

      iex> cast_boolean("TRUE")
      true

      iex> cast_boolean("1")
      true

      iex> cast_boolean("yes")
      true

      iex> cast_boolean("FALsE")
      false

      iex> cast_boolean("false")
      false
  """
  def cast_boolean(input), do: input |> String.downcase() |> do_cast_boolean()

  defp do_cast_boolean(val) when val in ~w(1 true yes), do: true
  defp do_cast_boolean(_), do: false

  @spec cast_comma_separated_list(String.t()) :: [String.t()]
  @spec cast_comma_separated_list(String.t(), (String.t() -> term)) :: [term]
  @doc """
  Casts a comma-separated list string to a list of strings. Takes an optional
  transformation function to apply to each element.

  ## Examples:

      iex> cast_comma_separated_list("1,,2")
      ["1", "2"]

      iex> cast_comma_separated_list("cat, dog", fn x -> String.to_atom(x) end)
      [:cat, :dog]
  """
  def cast_comma_separated_list(input, transform \\ fn x -> x end) do
    input
    |> String.trim("\"")
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(transform)
  end

  @spec cast_float(String.t()) :: float
  @doc """
  Casts a string to an integer.

  ## Example:

      iex> cast_float("1.5")
      1.5
  """
  def cast_float(input), do: String.to_float(input)

  @spec cast_integer(String.t()) :: integer
  @doc """
  Casts a string to an integer.

  ## Example:

      iex> cast_integer("20")
      20
  """
  def cast_integer(input), do: String.to_integer(input)

  @spec cast_ip(String.t()) :: ip
  @doc """
  Casts an IP in string form to a structured form.

  If the string given is a bare IP such as `1.2.3.4`, this function returns a
  4-element (IPv4) or 8-element (IPv6) tuple representing each segment of the
  IP.

  If the string given is in CIDR notation, `10.0.0.0/8`, this function returns a
  2-element tuple with an IP address of the form and the bitmask provided as the
  second element.

  ## Examples:

      iex> cast_ip("192.168.0.2")
      {192, 168, 0, 2}

      iex> cast_ip("1::1")
      {1, 0, 0, 0, 0, 0, 0, 1}

      iex> cast_ip("10.0.0.0/8")
      {{10, 0, 0, 0}, 8}

      iex> cast_ip("1::1/48")
      {{1, 0, 0, 0, 0, 0, 0, 1}, 48}
  """
  def cast_ip(input) do
    input
    |> String.split("/", parts: 2)
    |> do_cast_ip()
  end

  defp do_cast_ip([ip_str, range_str]),
    do: {parse_ip(ip_str), String.to_integer(range_str)}

  defp do_cast_ip([ip_str]),
    do: parse_ip(ip_str)

  defp parse_ip(ip_str) do
    {:ok, ip} =
      ip_str
      |> to_charlist()
      |> :inet.parse_strict_address()

    ip
  end

  @spec cast_module(String.t()) :: module
  @doc """
  Casts a string to a Module atom.

  ## Examples:

      iex> cast_module("KittyTown")
      KittyTown

      iex> cast_module("Ops.Repo")
      Ops.Repo
  """
  def cast_module(input), do: Module.concat([input])

  @doc """
  Optionally decodes a string based on a known encoding prefix if found.

  Returns nil if the input or decoded input is empty/blank.

  ## Examples

      iex> decode("base64:d29vdA")
      "woot"

      iex> decode("base64:ICB3b290CiA=")
      "woot"

      iex> decode(nil)
      nil

      iex> decode("")
      nil
  """
  @spec decode(maybe_encoded_input :: String.t() | nil) :: String.t() | nil
  def decode(nil = _maybe_encoded_input), do: nil
  def decode("base64:" <> base64_input), do: decode_base64(base64_input)
  def decode("" <> _ = unencoded_input), do: trim_string_or_nil(unencoded_input)

  defp trim_string_or_nil(string) do
    case String.trim(string) do
      "" -> nil
      value -> value
    end
  end

  @doc """
  Decodes and trims base64 encoded input. Empty value returns nil.

  ## Examples

      iex> decode_base64("d29vdA==")
      "woot"

      iex> decode_base64("ICB3b290CiA=")
      "woot"

      iex> decode_base64("d29vdA")
      "woot"

      iex> decode_base64(nil)
      nil

      iex> decode_base64("")
      nil

      iex> decode_base64("Cg==")
      nil

      iex> decode_base64("!@$%^&*()_")
      ** (ArgumentError) encoded input is not base64 encoded
  """
  @spec decode_base64(base64_input :: String.t() | nil) :: String.t() | nil
  def decode_base64(nil = _base64_input), do: nil
  def decode_base64("" = _base64_input), do: nil

  def decode_base64(base64_input) do
    case Base.decode64(base64_input, ignore: :whitespace, padding: false) do
      {:ok, decoded_input} -> trim_string_or_nil(decoded_input)
      :error -> raise ArgumentError, "encoded input is not base64 encoded"
    end
  end

  @spec validate_ip(ip) :: ip
  @doc """
  Validates that a provided ip is correct.

  When provided with an `{ip, range}` tuple, this validates that the provide
  block range is valid for the IP type.

  ## Examples:

      iex> validate_ip({192, 168, 0, 2})
      {192, 168, 0, 2}

      iex> validate_ip({1, 0, 0, 0, 0, 0, 0, 1})
      {1, 0, 0, 0, 0, 0, 0, 1}

      iex> validate_ip({{10, 0, 0, 0}, 8})
      {{10, 0, 0, 0}, 8}

      iex> validate_ip({{1, 0, 0, 0, 0, 0, 0, 1}, 48})
      {{1, 0, 0, 0, 0, 0, 0, 1}, 48}
  """
  def validate_ip({{_, _, _, _}, range} = input) when 0 <= range and range <= 32,
    do: input

  def validate_ip({{_, _, _, _, _, _, _, _}, range} = input) when 1 <= range and range <= 128,
    do: input

  def validate_ip({_, _, _, _} = ip), do: ip
  def validate_ip({_, _, _, _, _, _, _, _} = ip), do: ip

  @spec ip_to_string(ip :: ip) :: String.t()
  @doc """
  Converts an `t:ip()` to a string format. Does not validate the provided IP.

  ## Examples:

      iex> ip_to_string({192, 168, 0, 1})
      "192.168.0.1"

      iex> ip_to_string({{192, 168, 0, 0}, 24})
      "192.168.0.0/24"

      iex> ip_to_string({1, 0, 0, 0, 0, 0, 0, 1})
      "1::1"

      iex> ip_to_string({{1, 0, 0, 0, 0, 0, 0, 1}, 48})
      "1::1/48"
  """
  def ip_to_string({ip, range}), do: "#{ip_to_string(ip)}/#{range}"

  def ip_to_string(ip) do
    ip
    |> :inet.ntoa()
    |> to_string()
  end
end
