defmodule NervesHub.Firmwares.Firmware do
  use Ecto.Schema

  import Ecto.Changeset

  alias NervesHub.Accounts.Tenant
  alias NervesHub.Deployments.Deployment
  alias __MODULE__

  @type t :: %__MODULE__{}
  @optional_params [
    :author,
    :description,
    :misc,
    :product,
    :tenant_key_id,
    :uuid,
    :vcs_identifier
  ]
  @required_params [
    :architecture,
    :platform,
    :signed,
    :tenant_id,
    :upload_metadata,
    :version
  ]

  schema "firmwares" do
    belongs_to(:tenant, Tenant)
    has_many(:deployment, Deployment)

    field(:architecture, :string)
    field(:author, :string)
    field(:description, :string)
    field(:misc, :string)
    field(:platform, :string)
    field(:product, :string)
    field(:signed, :boolean)
    field(:tenant_key_id, :integer)
    field(:upload_metadata, :map)
    field(:uuid, :string)
    field(:vcs_identifier, :string)
    field(:version, :string)

    timestamps()
  end

  def changeset(%Firmware{} = firmware, params) do
    firmware
    |> cast(params, @required_params ++ @optional_params)
    |> validate_required(@required_params)
  end

  @spec fetch_metadata_item(String.t(), String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def fetch_metadata_item(metadata, key) when is_binary(key) do
    {:ok, regex} = "#{key}=\"(?<item>[^\n]+)\"" |> Regex.compile()

    case Regex.named_captures(regex, metadata) do
      %{"item" => item} -> {:ok, item}
      _ -> {:error, :not_found}
    end
  end

  @spec get_metadata_item(String.t(), String.t(), any()) :: String.t() | nil
  def get_metadata_item(metadata, key, default \\ nil) when is_binary(key) do
    case fetch_metadata_item(metadata, key) do
      {:ok, metadata_item} -> metadata_item
      {:error, :not_found} -> default
    end
  end
end
