# RenderJsonRails

RenderJsonRails pozwala w łatwy sposób dodać możliwość renderowania JSON z ActiveRecord-ów z zależnościami (has_many itp).
Dzięki temu łatwo jest stworzyć backend Json API np. do pracy z Reactem lub Vue.js

Przykład

```ruby

class Team < ActiveRecord::Base
  has_many :users
  
  include RenderJsonRails::Concern
  
  render_json_config name: :team,
                     except: [:account_id, :secret_field]
                     methods: [:get_full_name],
                     includes: {
                       users: User,
                     }
end
```

Dodajemy też w kontrolerze ```teams_controller.rb```

```ruby
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
http://example.text/team/1.json?include=users
```

możemy też określić jakie pola mają być w json

```html
http://example.text/team/1.json?fields[team]=name,description
```

i możemy łączyć to z include

```html
http://example.text/team/1.json?fields[team]=name,description&fields[user]=email,name&include=users
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'render_json_rails', git: 'https://github.com/intum/render_json_rails'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install render_json_rails

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/intum/render_json_rails.


## TMP

Tworzenie gema

```
gem build render_json_rails.gemspec

gem push --key github --host https://rubygems.pkg.github.com/intum render_json_rails-0.1.XXX.gem
```

