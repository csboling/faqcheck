defmodule Faqcheck.Repo do
  use Ecto.Repo,
    otp_app: :faqcheck,
    adapter: Ecto.Adapters.Postgres,
    types: Faqcheck.PostgresTypes
  use Quarto,
    limit: 10

  import Ecto.Changeset
  import PaperTrail.Serializer

  def versions(changeset, options \\ []) do
    changeset
    |> prepare_changes(fn cs ->
      case cs.action do
        :insert -> attach_versions(cs, options)
        :update -> update_versions(cs, options)
        _ -> changeset
      end
    end)
  end

  defp attach_versions(changeset, options) do
    version_id = get_sequence_id("versions") + 1
    # require IEx; IEx.pry
    changeset_data =
      # changeset.data
      changeset
      |> apply_changes()
      |> Map.merge(%{
        id: get_sequence_id(changeset) + 1,
        first_version_id: version_id,
        current_version_id: version_id
      })
    initial_version = make_version_struct %{event: "insert"},
      changeset_data, options

    changeset.repo.insert(initial_version, options)
    changeset |> change(%{
      first_version_id: version_id,
      current_version_id: version_id
    })
  end

  defp update_versions(changeset, options) do
    version_data =
      changeset.data
      |> Map.merge(%{
        current_version_id: get_sequence_id("versions")
      })
    target_changeset = changeset |> Map.merge(%{data: version_data})
    target_version = make_version_struct %{event: "update"},
      target_changeset, options

    changeset.repo.insert(target_version)
    changeset |> change(%{current_version_id: version_data.current_version_id})
  end
end
