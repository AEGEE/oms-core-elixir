defmodule OmscoreWeb.PaymentView do
  use OmscoreWeb, :view
  alias OmscoreWeb.PaymentView

  def render("index.json", %{payments: payments, filters: filters}) do
    data = payments
    |> render_many(PaymentView, "payment.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end

  def render("show.json", %{payment: payment, filters: filters}) do
    data = payment
    |> render_one(PaymentView, "payment.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("show.json", %{payment: payment}), do: render("show.json", %{payment: payment, filters: []})

  def render("payment.json", %{payment: payment}) do
    %{id: payment.id,
      amount: payment.amount,
      currency: payment.currency,
      expires: payment.expires,
      invoice_name: payment.invoice_name,
      invoice_address: payment.invoice_address,
      comment: payment.comment,
      inserted_at: payment.inserted_at
    }
  end
end
