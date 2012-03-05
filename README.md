# Bark

Bark is an open source group management web app.
Currently it is dependent on [CSEnatra](https://github.com/maxpow4h/csenatra)
for looking up contact information.

Only an account with the role "admin" will be able to access the API.

## Setup

Local Machine

    bundle install
    bundle exec padrino rake dm:auto:upgrade
    # Then to test
    bundle exec padrino rake

Heroku

    heroku run bundle exec padrino rake dm:auto:migrate

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
