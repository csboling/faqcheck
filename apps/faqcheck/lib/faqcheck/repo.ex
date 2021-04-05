defmodule Faqcheck.Repo do
  use Ecto.Repo,
    otp_app: :faqcheck,
    adapter: Ecto.Adapters.Postgres,
    types: Faqcheck.PostgresTypes

  import Ecto.Changeset
  import PaperTrail.Serializer

  def attach_versions(
        changeset,
        options \\ [
          origin: nil,
          meta: nil,
          originator: nil,
          prefix: nil,
          ecto_options: []
        ]
      ) do
    ecto_options = options[:ecto_options] || []

    prepare_changes(
      changeset,
      fn cs ->
        version_id = get_sequence_id("versions") + 1

        changeset_data =
          Map.get(cs, :data, cs)
          |> Map.merge(%{
            id: get_sequence_id(cs) + 1,
            first_version_id: version_id,
            current_version_id: version_id
          })

        initial_version = make_version_struct(%{event: "insert"}, changeset_data, options)
        cs.repo.insert(initial_version, ecto_options)

        ret = change(
          cs,
          %{
            first_version_id: version_id,
            current_version_id: version_id
          })

        ret
      end)
  end
end
