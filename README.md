# Firefly Art Grant Core Website [![CircleCI](https://circleci.com/gh/FireflyArtsCollective/ffagc.svg?style=svg)](https://circleci.com/gh/FireflyArtsCollective/ffagc)

## Initial Environment Setup

Set up the project with:

```sh
  bundle install
  bin/rails db:migrate RAILS_ENV=development
  bin/rails server
```

If you are running this project in production you'll need to set environment variables for secrets that include `ENV` in `config/secrets.yml`.  To generate new "secret" hex values, use `bundle exec rake secret`.  Be careful not to push changes to this file to publicly-accessible repositories!

## Email Setup

If you're using SMTP to send emails, create a hidden file `.env` (it is already ignored by git) that overrides the values you want to set. See `.env.sample` for an example.

## Event-Specific Setup (do this every year)

There are a few changes to make every year:

* Set the year of the event (e.g., "Apply for Firefly 2027!") in config/application.rb.

* Check the grant contract templates in app/assets/contract_templates.  Each template filename
must match the corresponding grant name, so if a grant changes name the template filename must
also be changed.

* Update the template constants (install dates and deadlines) in config/template_values.yml.

* Reset the database with `bundle exec rake db:reset`. THIS WILL DELETE ALL DATA, so you may want to make a backup of the existing db first.

## Run Tests

```sh
  bundle exec rspec
```

## Launch the server

Run the server, which runs on the default port 3000:

```sh
  bundle exec rails s
```

You should create an admin right away by going to the admins page.

# Troubleshooting

I had problems with bundle install not working, and I had to do:

```sh
  bundle install --deployment
```

# Static assets look wrong or are missing

You may need to precompile them for some production environments:

```sh
RAILS_ENV=production bundle exec rake assets:precompile
```

# The site isn't updating?

You may need to tell apache to reload

```sh
sudo service apache2 reload
```
