# Bark

[![Build Status](https://secure.travis-ci.org/maxpow4h/bark.png?branch=master)](http://travis-ci.org/maxpow4h/bark)

Bark is an open source group management web app.
Currently it is dependent on [CSEnatra](https://github.com/maxpow4h/csenatra)
for looking up contact information. Also a client is available for the API
at [bark_client](https://github.com/maxpow4h/bark_client).

Only an account with the role "admin" will be able to access the API.

## Setup

Dependencies:

- memcached

Local Machine

    bundle install --without production
    bundle exec padrino rake dm:auto:upgrade
    RACK_ENV=test bundle exec padrino rake dm:auto:upgrade
    bundle exec padrino rake spec # Run the spec
    bundle exec padrino server    # Run the web server

Heroku

    heroku create maxs-bark --stack cedar
    heroku addons:add shared-database
    heroku addons:add memcache:5mb
    heroku addons:add pgbackups:auto-month
    heroku config:add RACK_ENV=production
    
    git push heroku master
    
    heroku run padrino rake dm:auto:upgrade
    heroku run padrino rake seed

Environment Variables

    # To use CSEnatra you need to set the following
    CSENATRA_USERNAME # username
    CSENATRA_PASSWORD # password
    CSENATRA_URL      # url e.g. "/~username/api/remote"
    CSENATRA_ON       # If it should run set to 'yes'

## Contributing

1. Fork the project
2. Add feature or bug fix
3. Add tests so the feature isn't broken in the future
4. Send a pull request on Github

## Copyright

    Bark, a web app for group management.
    Copyright (C) 2012 Maxwell Swadling

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
