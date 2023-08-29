defmodule AppWeb.ItemHTML do
  use AppWeb, :html

  embed_templates "item_html/*"

  @doc """
  Renders a item form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def item_form(assigns)

  def completed(item), do: item.status == 1

  def remaining_items([]), do: 0
  def remaining_items(items) do
    items
    |> Enum.count(fn i -> i.status == 0 end)
  end
end
