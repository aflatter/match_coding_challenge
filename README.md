# Match Coding Challenge

This is my take on the [Match](https://mvpmatch.co/) [coding challenge](https://mvpmatch.notion.site/Full-stack-ac8a8b07bee84937968377c840b6fa29).

I'm usually not fond of these types of exercises but gave it a go because I was in a mood to build something using Elixir. It also presented an opportunity to play around with `phx.gen.auth` in a scenario where API authentication is required.

I've explored the idea of modeling deposits and orders as transactions in a double-entry accounting ledger using TigerBeetleDb but unfortunately there's no client for Elixir yet. This keeps bugging me so I might start working on one.

## Notes

- I ripped out all of the email-related functionality from `phx.gen.auth` and replaced that with usernames as specified by the challenge. This hadhad the nice side-effect of reducing the amount of code.
- The specs suggest to design a RESTful API and specify RPC-style `/buy` and `/deposit` routes at the same time. I decided to go with REST and implemented `POST /api/orders` and `POST /api/deposits`.
- As the smallest coin that the vending machine returns is 5, you possibly don't get all your money back: If you put 50 cents in but your product only costs 48, the machine won't be able to give you 2 cents back.

## Open tasks

There's a bunch of open tasks that I didn't get to do yet.

- [ ] Make a postman collection
- [ ] Create web interface for interaction with the API, design choices are left to you
- [ ] Implement `/reset` endpoint so users with a “buyer” role can reset their deposit back to 0
- [ ] Bonus: If somebody is already logged in with the same credentials, the user should be given a message "There is already an active session using your account". In this case the user should be able to terminate all the active sessions on their account via an endpoint i.e. `/logout/all`
