defmodule OmscoreWeb.Helper do
  require Ecto.Query

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

  defp paginate_limit(query, limit) do
    if limit do
      query
      |> Ecto.Query.limit(^String.to_integer(limit))
    else
      query
    end
  end

  defp paginate_offset(query, offset) do
    if offset do
      query
      |> Ecto.Query.offset(^String.to_integer(offset))
    else
      query
    end
  end

  def paginate(query, params) do
    query
    |> paginate_limit(params["limit"])
    |> paginate_offset(params["offset"])
  end

  def search(query, params) do
    querystring = params["query"]
    if querystring do
      query
      |> Ecto.Query.where([p], ilike(p.name, ^"%#{querystring}%"))
    else
      query
    end
  end
end
