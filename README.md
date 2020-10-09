# RenderJsonRails

RenderJsonRails pozwala w łatwy sposób dodać możliwość renderowania JSON z ActiveRecord-ów z zależnościami (has_many itp).
Dzięki temu łatwo jest stworzyć backend Json API np. do pracy z Reactem lub Vue.js

## Przykład

```ruby

class Team < ActiveRecord::Base
  has_many :users
  
  include RenderJsonRails::Concern
  
  render_json_config name: :team,
                     includes: {
                       users: User
                     }
end

class User < ActiveRecord::Base
  belongs_to :team
  
  include RenderJsonRails::Concern
  
  render_json_config name: :user,
                     includes: {
                       team: Team
                     }
end
```

Dodajemy też w kontrolerze ```teams_controller.rb```

```ruby
  include RenderJsonRails::Helper
  
  def index
    @team = Team.all
    respond_to do |format|
      format.html
      format.json { render_json @team }
    end
  end
```  
  
i możemy już otrzymać JSON team-u wraz z userami

```html
http://example.test/teams/1.json?include=users
```

możemy też określić jakie pola mają być w json

```html
http://example.test/teams/1.json?fields[team]=name,description
```

i możemy łączyć to z include

```html
http://example.text/teams/1.json?fields[team]=name,description&fields[user]=email,name&include=users
```

## Pełny opis ```render_json_config```

```ruby
render_json_config name: :team, 
  except: [:account_id, :config], # tych pól nie będzie w json-ie
  methods: [:image], # te metody zostaną dołączone 
  allowed_methods: [:members], # te metody mogą być dodane przez parametr fileds np: fields[team]=id,members
  includes: { # to mozna dołączać za pomoca parametru include np include=users,category
   users: Users,
   category: Category
  }
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'render_json_rails'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install render_json_rails

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/intum/render_json_rails.

