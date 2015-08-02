# BreadcrumbsOnRailsToGretel

This gem is a simple and smart way to change all breadcrumbs of your project from [breadcrumb_on_rails](https://github.com/weppos/breadcrumbs_on_rails) to [gretel](https://github.com/lassebunk/gretel).

**Gem is not ready for prodution yet ; )**


breadcrumb_on_rails is a really simple tool for managing breadcrumbs, but writing breadcrumbs´s logic inside the controllers seem awful for me and should be in the view, I was having a lot of problems managing the visibility of breadcrumbs for specific users, when I realize the breadcrumb_on_rails was not a good choice it was too late, there is a lot breadcrumbs in my applications and I need a kind of tool to make a fully conversion of breadcrumb manager, the main problem is breadcrumb_on_rails and gretel is very different, gretel organize breadcrumbs inside a config folder and breadcrumb_on_rails inside the controller.

**Sorry for the bad English : )**


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'breadcrumbs_on_rails_to_gretel'
```

**Dont forget to add this gem to development group**


And then execute:

    $ bundle


## Requirements

- Rails 3.x or Rails 4.x

- Ruby >= 1.9.3

Please note 

- Rails 4 and 2 was not tested


## Usage

Simple run the rake task:

```ruby
	rake breadcrumbs_on_rails_to_gretel:convert
```

This task will seach for add_breadcrumb in all controllers, it also add the gretel´s breadcrumb in your views, and organize all breadcrumbs for you.

## Contributing

1. Fork it ( https://github.com/victor95pc/breadcrumbs_on_rails_to_gretel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Report issues or feature requests to [GitHub Issues](https://github.com/victor95pc/breadcrumbs_on_rails_to_gretel/issues).

## License

<tt>BreadcrumbsOnRailsToGretel</tt> is Copyright (c) 2015 Victor Palomo de Castro. This is Free Software distributed under the MIT license.
