defmodule LcHookTestWeb.Router do
  use LcHookTestWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {LcHookTestWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", LcHookTestWeb do
    pipe_through(:browser)

    get("/", PageController, :home)

    live("/users", UserLive.Index, :index)
    live("/users/new", UserLive.Index, :new)
    live("/users/:id/edit", UserLive.Index, :edit)

    live("/users/:id", UserLive.Show, :show)
    live("/users/:id/show/edit", UserLive.Show, :edit)
  end
end
