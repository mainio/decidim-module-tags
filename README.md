# Decidim::Tags

[![Build Status](https://github.com/mainio/decidim-module-tags/actions/workflows/ci_tags.yml/badge.svg)](https://github.com/mainio/decidim-module-tags/actions)
[![codecov](https://codecov.io/gh/mainio/decidim-module-tags/branch/main/graph/badge.svg)](https://codecov.io/gh/mainio/decidim-module-tags)

The gem has been developed by [Mainio Tech](https://www.mainiotech.fi/).

A [Decidim](https://github.com/decidim/decidim) module that provides the
possibility to add tags to any records, e.g. proposals, users, results, etc.

This is a technical module that adds this ability to Decidim but the tags
functionality needs to be manually added to the individual models, the
tags input needs to be added to the editing views and the tags display needs to
be added to the record views. This module provides you all the tools to add
these elements to the user interface.

Development of this gem has been sponsored by the
[City of Helsinki](https://www.hel.fi/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-tags"
```

And then execute:

```bash
$ bundle
$ bundle exec rails decidim_tags:install:migrations
```

## Usage

Add this to your `decidim.scss` file:

```scss
// AFTER THE LINE THAT SAYS:
// @import "decidim/application";
// ADD THIS:
@import "decidim/tags/tagging-input";
```

Add this to the model you want to make taggable:

```ruby
class YourModel < ApplicationRecord
  include Decidim::Tags::Taggable
  # ...
end
```

Add this to the form classes in which you want to allow adding tags to the
records:

```ruby
class YourModelForm < Decidim::Form
  include Decidim::Tags::TaggableForm
end
```

Include the following cell to display the tags in the record pages:

```erb
<%== cell("decidim/tags/tags", model) %>
```

Include this cell inside the record's editing form:

```erb
<%= decidim_form_for(@model_form) do |form| %>
  <% # ... other form fields ... %>
  <%== cell("decidim/tags/form", form, label: t("activemodel.attributes.taggings.tags")) %>
  <% # ... other form fields ... %>
<% end %>
```

And finally, inside the commands that create and update the records, include the
following:

```ruby
class YourUpdateCommand < Rectify::Command
  # Add this concern to the command
  include Decidim::Tags::TaggingsCommand

  def initialize(form, model)
    @form = form
    @model = model
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    # Here you would normally update the record
    @model.update!(foo: form.foo, bar: form.bar)

    # AFTER the record has been updated, call the update_taggings method with
    # the model and the form objects. The form object needs to have the
    # Decidim::Tags::TaggableForm concern included as explained above.
    update_taggings(@model, @form)

    broadcast(:ok, @model)
  end
end
```

### Examples

#### Proposals

An example for how to use this module with proposals, see
[docs/examples/proposals.md](docs/examples/proposals.md).

## Contributing

See [Decidim](https://github.com/decidim/decidim).

### Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby and PostgreSQL)
- Clone this repository

Decidim's main repository also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

Then to test how the module works in Decidim, start the development server:

```bash
$ cd development_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rails s
```

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

#### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

[Rubocop](https://rubocop.readthedocs.io/) linter is used for the Ruby language.

You can run the code styling checks by running the following commands from the
console:

```
$ bundle exec rubocop
```

To ease up following the style guide, you should install the plugin to your
favorite editor, such as:

- Atom - [linter-rubocop](https://atom.io/packages/linter-rubocop)
- Sublime Text - [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
- Visual Studio Code - [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)

### Testing

To run the tests run the following in the gem development path:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

### Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
$ SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/project/decidim-access-requests

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
