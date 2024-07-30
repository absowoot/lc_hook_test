defmodule LcHookTestWeb.UserLive.FormComponent do
  use LcHookTestWeb, :live_component

  alias LcHookTest.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div id="add-user" phx-hook="AddUser">
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>


      <a href="#" phx-click={JS.dispatch("check-instance")}>Check Instance</a>
      <p class="mt-8">Instance: <%= @instance %></p>

      <.simple_form
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:age]} type="number" label="Age" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(instance: nil)
     |> assign_new(:form, fn ->
       to_form(Accounts.change_user(user))
     end)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user(socket.assigns.user, user_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  def handle_event("instance", %{"instance" => instance}, socket) do
    {:noreply, assign(socket, instance: instance)}
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
