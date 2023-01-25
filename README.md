# Match

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Notes

- Passwords are not encrypted in the users table. Not a good practice obviously.
- There's no nice error message when creating an user and the username's already taken.

## Todos

- [ ] Implement basic auth so that permissions can be verified.
- [ ] `/api/products`: Only allow `POST`, `PUT` and `DELETE` if the requesting user is a seller and owns the product.
- [ ] Implement `/deposit` endpoint so users with a `buyer` role can deposit only 5, 10, 20, 50 and 100 cent coins into their vending machine account
- [ ] Implement `/buy` endpoint (accepts productId, amount of products) so users with a “buyer” role can buy products with the money they’ve deposited. API should return total they’ve spent, products they’ve purchased and their change if there’s any (in an array of 5, 10, 20, 50 and 100 cent coins)
- [ ] Implement `/reset` endpoint so users with a “buyer” role can reset their deposit back to 0



|> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))