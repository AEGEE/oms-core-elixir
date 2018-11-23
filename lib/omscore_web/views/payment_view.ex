defmodule OmscoreWeb.PaymentView do
  use OmscoreWeb, :view
  alias OmscoreWeb.PaymentView
  alias OmscoreWeb.Helper


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
      inserted_at: payment.inserted_at,
      body_id: payment.body_id,
      member_id: payment.member_id,
      body: Helper.render_assoc_one(payment.body, OmscoreWeb.BodyView, "body.json"),
      member: Helper.render_assoc_one(payment.member, OmscoreWeb.MemberView, "member.json")
    }
  end
end
