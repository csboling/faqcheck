# Faqcheck

## Developer setup

- Install Erlang OTP >= 23.3
- Install Elixir
- Set up postgres password in `config/dev.exs`
- `mix ecto create`
- `cd apps/faqcheck_web/assets`, then `npm install`
- `mix phx.server`


## Accessibility

- Javascript should not be required for any functionality
- all pages should work well with a screen reader
- all controls should have ARIA annotations

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
