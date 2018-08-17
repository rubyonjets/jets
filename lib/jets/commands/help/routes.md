## Example

    $ jets routes
    +--------+----------------+--------------------+
    |  Verb  |      Path      | Controller#action  |
    +--------+----------------+--------------------+
    | GET    | posts          | posts#index        |
    | GET    | posts/new      | posts#new          |
    | GET    | posts/:id      | posts#show         |
    | POST   | posts          | posts#create       |
    | GET    | posts/:id/edit | posts#edit         |
    | PUT    | posts/:id      | posts#update       |
    | DELETE | posts/:id      | posts#delete       |
    | GET    |                | jets/welcome#index |
    | ANY    | *catchall      | jets/public#show   |
    +--------+----------------+--------------------+
    $