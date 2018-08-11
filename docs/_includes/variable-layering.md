Layering is performed for the `config/variables` folder.  Let's say you have the following variables directory structure:

```yaml
config/variables
├── base.rb
├── development.rb
└── production.rb
```

In this case, you want to define your common variables used for templates in the `config/variables/base.rb`. Specific environment overrides can be defined in their respective `LONO_ENV` variables file.  For example:

`app/definitions/base.rb`:

```ruby
@min_size = 1
@max_size = 1
```

`app/definitions/production.rb`:

```ruby
@min_size = 10
@max_size = 20
```

When `lono generate` is called with `LONO_ENV=production` it will use `20` for the `@max_size` variable. For other `LONO_ENV` values, the `@max_size` variable will be set to `1`.

Depending on how you use variables with layering, you can dramatically simpify your template definitions and param files.  Most of the time, you can get the template definition to a single line and use a single `config/params/base` file for the template.
