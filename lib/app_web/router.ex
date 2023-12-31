defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :browser

    get "/version", PageController, :home
    get "/toggle", ItemController, :toggle_all
    get "/clear", ItemController, :clear_completed
    get "/toggle/:id", ItemController, :toggle
    get "/filter/:filter", ItemController, :filter
    resources "/", ItemController, except: [:show]

  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end
end
