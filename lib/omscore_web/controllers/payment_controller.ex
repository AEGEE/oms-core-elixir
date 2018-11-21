defmodule OmscoreWeb.PaymentController do
  use OmscoreWeb, :controller

  alias Omscore.Finances
  alias Omscore.Finances.Payment
  alias Omscore.Core

  action_fallback OmscoreWeb.FallbackController

  def index(conn, params) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "payment") do
      payments = Finances.list_payments(params)
      render(conn, "index.json", payments: payments, filters: filters)
    end
  end

  def index_bound(conn, params) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "payment") do
      payments = Finances.list_bound_payments(conn.assigns.body.id, params)
      render(conn, "index.json", payments: payments, filters: filters)
    end
  end

  # If you want to show a payment which is not in the body through the bound request (where assigns.body will be set) you will get a 404
  defp check_for_body(nil, _), do: {:ok}
  defp check_for_body(body, payment) do 
    if body.id == payment.body_id do
      {:ok}
    else
      {:error, :not_found}
    end
  end

  def show(conn, %{"payment_id" => id}) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "payment"),
        payment <- Finances.get_payment!(id),
        {:ok} <- check_for_body(conn.assigns[:body], payment) do
      render(conn, "show.json", payment: payment, filters: filters)
    end
  end

  def create(conn, %{"payment" => payment_params}) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "create", "payment"),
         payment_params <- Core.apply_attribute_filters(payment_params, filters),
         member <- Omscore.Members.get_member!(payment_params["member_id"]),
         {:ok, %Payment{} = payment} <- Finances.create_payment(conn.assigns.body, member, payment_params) do
      conn
      |> put_status(:created)
      |> render("show.json", payment: payment)
    end
  end


  def update(conn, %{"payment_id" => id, "payment" => payment_params}) do
    payment = Finances.get_payment!(id)

    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "update", "payment"),
         payment_params <- Core.apply_attribute_filters(payment_params, filters),
         {:ok, %Payment{} = payment} <- Finances.update_payment(payment, payment_params) do
      render(conn, "show.json", payment: payment)
    end
  end

  def delete(conn, %{"payment_id" => id}) do
    payment = Finances.get_payment!(id)
    with {:ok, %Core.Permission{}} <- Core.search_permission_list(conn.assigns.permissions, "delete", "payment"),
         {:ok, %Payment{}} <- Finances.delete_payment(payment) do
      send_resp(conn, :no_content, "")
    end
  end
end
