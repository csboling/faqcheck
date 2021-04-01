# Faqcheck

An application for managing question-and-answer data and associated referrals, such as phone numbers and addresses of organizations that can be contacted for more detail.

## Developer setup

- Install Erlang OTP >= 23.3
- Install Elixir
- Install PostgreSQL >= 9.5, with the PostGIS geospatial extension
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
