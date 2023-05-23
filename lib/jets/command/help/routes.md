## Example

    $ jets routes
    +-------------------+--------+--------------------+--------------------+
    |    As (Prefix)    |  Verb  | Path (URI Pattern) | Controller#action  |
    +-------------------+--------+--------------------+--------------------+
    | posts             | GET    | /posts             | posts#index        |
    | posts             | POST   | /posts             | posts#create       |
    | new_post          | GET    | /posts/new         | posts#new          |
    | edit_post         | GET    | /posts/:id/edit    | posts#edit         |
    | post              | GET    | /posts/:id         | posts#show         |
    | post              | PUT    | /posts/:id         | posts#update       |
    | post              | PATCH  | /posts/:id         | posts#update       |
    | post              | DELETE | /posts/:id         | posts#destroy      |
    +-------------------+--------+--------------------+--------------------+
