defmodule AppWeb.ItemControllerTest do
  alias AppWeb.ItemHTML
  alias AppWeb.ItemController
  alias App.Todo
  use AppWeb.ConnCase

  import App.TodoFixtures

  @create_attrs %{person_id: 42, status: 0, text: "initial text"}
  @update_attrs %{person_id: 43, status: 43, text: "some updated text"}
  @invalid_attrs %{person_id: nil, status: nil, text: nil}

  describe "index" do
    test "lists all items", %{conn: conn} do
      conn = get(conn, ~p"/items")
      assert html_response(conn, 200) =~ "What needs to be done?"
    end
  end

  describe "new item" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/items/new")
      assert html_response(conn, 200) =~ "What needs to be done?"
    end
  end

  describe "create item" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/items", item: @create_attrs)

      assert %{} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/items"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/items", item: @invalid_attrs)
      assert html_response(conn, 200) =~ "What needs to be done?"
    end
  end

  describe "edit item" do
    setup [:create_item]

    test "renders form for editing chosen item", %{conn: conn, item: item} do
      conn = get(conn, ~p"/items/#{item}/edit")
      assert html_response(conn, 200) =~ "Click here to create a new item"
    end
  end

  describe "update item" do
    setup [:create_item]

    test "redirects when data is valid", %{conn: conn, item: item} do
      conn = put(conn, ~p"/items/#{item}", item: @update_attrs)
      assert redirected_to(conn) == ~p"/items"

      conn = get(conn, ~p"/items/#{item}")
      assert html_response(conn, 200) =~ "some updated text"
    end

    test "renders errors when data is invalid", %{conn: conn, item: item} do
      conn = put(conn, ~p"/items/#{item}", item: @invalid_attrs)
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end
  end

  describe "delete item" do
    setup [:create_item]

    test "deletes chosen item", %{conn: conn, item: item} do
      conn = delete(conn, ~p"/items/#{item}")
      assert redirected_to(conn) == ~p"/items"

      all_items_resp = get(conn, ~p"/items")
      IO.inspect(all_items_resp)
      assert html_response(all_items_resp, 200) =~ @create_attrs.text

    end
  end


  describe "remaining_items/1" do
    test "returns the correct count of items where status == 0" do
      items = [
        %{text: "Hello", status: 0},
        %{text: "Ciao", status: 0},
        %{text: "Salut", status: 1},
      ]
      assert ItemHTML.remaining_items(items) == 2
    end

    test "returns 0 with an empty list of items" do
      assert ItemHTML.remaining_items([]) == 0
    end
  end

  describe "toggle_status\1" do
    setup :create_item

    test "updates the status from 0 to 1", %{item: item} do
      assert item.status == 0
      toggled_item = %{item | status: ItemController.toggle_status(item)}
      assert toggled_item == %{item | status: 1}
      assert ItemController.toggle_status(toggled_item) == 0
    end
  end

  describe "toggle/1" do
    setup :create_item

    test "updates the status of an item and redirects to items/ page", %{conn: conn, item: i} do
      assert i.status == 0
      get(conn, ~p"/items/toggle/#{i.id}")
      toggled_item = Todo.get_item!(i.id)
      assert toggled_item.status == 1
    end
  end

  test "filter items", %{conn: conn} do
    post(conn, ~p"/items", item: @create_attrs)

    # after creating the item, check that it's in the list of active items
    active_resp = get(conn, ~p"/items/filter/active")
    assert html_response(active_resp, 200) =~ @create_attrs.text

    completed_resp = get(conn, ~p"/items/filter/completed")
    assert !html_response(completed_resp, 200) =~ @create_attrs.text

  end

  defp create_item(_) do
    item = item_fixture(@create_attrs)
    %{item: item}
  end
end
