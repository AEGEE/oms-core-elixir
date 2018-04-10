defmodule OmscoreWeb.Helper do
  import Ecto.Query

  def render_assoc_one(model, view, template, assigns \\ %{}) do
    cond do
      model == nil -> nil
      !Ecto.assoc_loaded?(model) -> nil
      true -> Phoenix.View.render_one(model, view, template, assigns)
    end
  end

  def render_assoc_many(model, view, template, assigns \\ %{}) do
    cond do
      model == nil -> nil
      !Ecto.assoc_loaded?(model) -> nil
      true -> Phoenix.View.render_many(model, view, template, assigns)
    end
  end

  defp to_integer(data) when is_integer(data), do: data
  defp to_integer(data) when is_binary(data), do: String.to_integer(data)


  def paginate(query, %{"limit" => limit, "offset" => offset}) do
    query
    |> Ecto.Query.limit(^to_integer(limit))
    |> Ecto.Query.offset(^to_integer(offset))
  end
  def paginate(query, _), do: query

  # Builds a query in the
  def search(query, %{"query" => querystring}, attrs) do
    filters = attrs
    |> Enum.map(fn(x) -> {x, "%#{querystring}%"} end)

    Enum.reduce(filters, query, fn {key, value}, query ->
      from q in query, or_where: ilike(field(q, ^key), ^value)
    end)
  end
  def search(query, _params, _attrs), do: query

end
