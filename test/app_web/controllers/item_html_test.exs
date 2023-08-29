defmodule AppWeb.ItemHtmlTest do
  use AppWeb.ConnCase, async: true
  alias AppWeb.ItemHTML

  test ~s'completed/1 returns true if item.status == 1' do
    assert ItemHTML.completed(%{status: 1}) == true # just for visibility
  end

  test "completed/1 returns an empty string if item.status == 0" do
    assert ItemHTML.completed(%{status: 0}) == false # just for visibility
  end


end
