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

  def to_integer(data) when is_integer(data), do: data
  def to_integer(data) when is_binary(data), do: String.to_integer(data)


  def paginate(query, %{"limit" => limit, "offset" => offset}) do
    query
    |> Ecto.Query.limit(^to_integer(limit))
    |> Ecto.Query.offset(^to_integer(offset))
  end
  def paginate(query, _), do: query

  # Builds a query where the querystring is compared in ilike-fashion to each of the fields passed in attrs
  # These where statements are joined together by ORs to return any result that somewhat matches the query
  # TODO Somehow join where queries in brackets...
  def search(query, %{"query" => querystring}, attrs) when length(attrs) != 0 do
    # Construct a where clause to match each of the given fields ORed together
    # We will also end up with an OR false in it but that shouldn't do any harm
    where_query = Enum.reduce(attrs, false, fn (key, where_query) -> 
      dynamic([q], ilike(field(q, ^key), ^"%#{querystring}%") or ^where_query)
    end)

    from q in query, where: ^where_query
  end
  def search(query, _params, _attrs), do: query

end
