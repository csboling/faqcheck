# Faqcheck

An application for managing question-and-answer data and associated referrals, such as phone numbers and addresses of organizations that can be contacted for more detail.

## Developer setup

- Install Elixir + Erlang OTP >= 23.3, for example:
  ```bash
  sudo pacman -Syu elixir
  ```
- Install and set up postgres, with the PostGIS spatial extensions. For example:
  ```bash
  sudo pacman -Syu postgresql postgis
  sudo -iu postgres
  initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data
  exit
  systemctl start postgresql.service
  systemctl enable postgresql.service
  sudo -iu postgres
  createdb faqcheck_dev
  ```
- Set up postgres password in `config/dev.exs`
- `mix deps get`
- `mix ecto create`
- `cd apps/faqcheck_web/assets`, then `npm install`
- `mix phx.server`

## Accessibility

- Javascript should not be required for any functionality
- all pages should work well with a screen reader
- all controls should have HTML5 accessibility annotations

## Translating content

Faqcheck uses [GNU gettext](https://www.gnu.org/software/gettext/) and
its [elixir package](https://hexdocs.pm/gettext) for managing
translations of its interaction pages. Text displayed to the user
should always be read from the `gettext` database, e.g.

```html
<p><%= gettext "Upload a spreadsheet" %></p>
```

To extract gettext keys from the templates and generate localization
.po files for a particular language, run for instance:

```bash
mix gettext.extract --merge es_ES
```
