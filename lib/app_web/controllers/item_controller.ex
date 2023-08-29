defmodule AppWeb.ItemController do
  use AppWeb, :controller

  alias App.Todo
  alias App.Todo.Item

  def index(conn, params) do
    item =
      if not is_nil(params) && Map.has_key?(params, "id") do
        Todo.get_item!(params["id"])
      else
        %Item{}
      end

    items = Todo.list_items()
    changeset = Todo.change_item(item)
    active_count = items |> Enum.count(fn i -> i.status == 0 end)
    completed_count = items |> Enum.count(fn i -> i.status == 1 end)
    show_clear_completed = completed_count > 0
    filter_info = [
      filter: nil,
      active_count: active_count,
      highlight_toggle: active_count > 0,
      completed_count: completed_count,
      show_clear_completed: show_clear_completed
    ]

    render(
      conn,
      :index,
      items: items,
      changeset: changeset,
      editing: item,
      filter_info: filter_info,
      total_items: length(items)
    )
  end

  def new(conn, _params) do
    changeset = Todo.change_item(%Item{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    case Todo.create_item(item_params) do
      {:ok, _item} ->
        conn
        # |> put_flash(:info, "Item created successfully.")
        |> redirect(to: ~p"/items")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Todo.get_item!(id)
    render(conn, :show, item: item)
  end

  def edit(conn, params) do
    # item = Todo.get_item!(id)
    # changeset = Todo.change_item(item)
    # render(conn, :edit, item: item, changeset: changeset)
    index(conn, params)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Todo.get_item!(id)

    case Todo.update_item(item, item_params) do
      {:ok, _item} ->
        conn
        # |> put_flash(:info, "Item updated successfully.")
        |> redirect(to: ~p"/items")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, item: item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Todo.get_item!(id)
    {:ok, _item} = Todo.delete_item(item)

    conn
    # |> put_(:inflashfo, "Item deleted successfully.")
    |> redirect(to: ~p"/items")
  end

  def toggle(conn, %{"id" => id}) do
    item = Todo.get_item!(id)
    Todo.update_item(item, %{status: toggle_status(item)})

    conn
    # |> put_flash(:info, "Item status updated")
    |> redirect(to: ~p"/items")
  end


  def toggle_all(conn, _params) do
    items = Todo.list_items()
    active_count = items |> Enum.count(fn i -> i.status == 0 end)

    if active_count == 0 do
      Todo.update_all_status(0)
    else
      Todo.update_all_status(1)
    end


    conn
    # |> put_flash(:info, "Item status updated")
    |> redirect(to: ~p"/items")
  end



  # def toggle_status(%{status: 0}), do: 1
  # def toggle_status(%{status: 1}), do: 0
  def toggle_status(item), do: if(item.status == 0, do: 1, else: 0)

  def filter(conn, %{"filter" => filter}) do
    status =
      case filter do
        "completed" -> 1
        "active" -> 0
        _ -> nil
      end

    changeset = Todo.change_item(%Item{})
    items = Todo.list_items()

    active_count = items |> Enum.count(fn i -> i.status == 0 end)
    completed_count = items |> Enum.count(fn i -> i.status == 1 end)
    show_clear_completed = completed_count > 0
    filter_info = [
      filter: filter,
      active_count: active_count,
      highlight_toggle: active_count > 0,
      completed_count: completed_count,
      show_clear_completed: show_clear_completed
    ]

    filtered_items = items |> Enum.filter(fn i -> i.status == status end)

    render(
      conn,
      :index,
      %{
        total_items: length(items),
        items: filtered_items,
        changeset: changeset,
        editing: %Item{},
        filter_info: filter_info
      }
    )
  end

  def clear_completed(conn, _params) do

    Todo.delete_completed()

    conn
    # |> put_flash(:info, "Item status updated")
    |> redirect(to: ~p"/items")

  end
end
