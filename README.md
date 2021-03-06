# Faqcheck

An application for managing referrals and question-and-answer data, such as phone numbers and addresses of local organizations. This is intended to help organizations connect people with other resources that can assist them.

One goal is for the application to be able to intake data in whatever format your organization currently stores it, like being able to read an Excel spreadsheet directly from Microsoft SharePoint using Microsoft's web APIs. Rather than requiring you to restructure your spreadsheets into the format expected by FaqCheck, you can write and install an "import strategy", which is an [Elixir](https://elixir-lang.org) module explaining how to extract information from your data source. Once this is working, you can import new records from your data source in the future as long as the formatting remains the same.

Faqcheck provides a web interface for searching saved contacts and leaving simple feedback, such as "this resource helped me" or "this phone number was wrong". You can also interact with Faqcheck using a chatbot interface, for example you can invite Faqcheck to Microsoft Teams chat channels and search its database by sending it Teams messages.

Faqcheck is released under the CC0 "no rights reserved" license. You may use and modify it for any purpose, including relicensing derivative work, with or without attribution.

## Developer setup

These instructions are for Arch Linux, though other POSIX operating systems have similar ways of installing Elixir, Postgres, and Node. For Windows you should just need to run the installers for Elixir, Node, and Postgres, some Windows distributions of Postgres include the PostGIS extensions as a component option in the installer.

- Install Elixir + Erlang OTP >= 23.3:
  ```bash
  sudo pacman -Syu elixir
  ```
- Install and set up postgres, with the PostGIS spatial extensions.
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
- Install NodeJS, specifically the v14 LTS was used at the time of this writing.
  ```bash
  sudo pacman -Syu nodejs-lts-fermium
  ```
- Install `inotify-tools` (for monitoring the filesystem for changed source code, not used on Windows):
  ```bash
  sudo pacman -Syu inotify-tools
  ```
- Set up postgres password in `config/dev.exs`
- `mix deps.get && mix deps.compile` to install Elixir dependencies
- `mix ecto.create && mix ecto.migrate` to set up the database
- `cd apps/faqcheck_web/assets`, then `npm install` to set up Javascript components
- `mix phx.server` will then run the server, watching the filesystem to automatically recompile when the code changes.

## Production setup

### On fly.io

https://fly.io is a pay-as-you-go cloud hosting service with a nice [setup guide for Elixir](https://fly.io/docs/getting-started/elixir/). To deploy to your fly account (after logging in) you need to

- set up the secrets needed for the app to run securely
  ```bash
  mix phx.gen.secret  # to generate a secret <GENERATED>
  fly secrets set SECRET_KEY_BASE=<GENERATED>
  ```

  Several more secrets and not-so-secret values need to be made available to the app for it to integrate
  with external services like Microsoft. For detailed setup instructions see:
  apps/faqcheck_web/lib/faqcheck_web/templates/help/microsoft.html.md
  ```bash
  fly secrets set MICROSOFT_BOT_ID=<Teams app id>
  fly secrets set MICROSOFT_BOT_PASSWORD=<Teams app secret>
  fly secrets set MICROSOFT_API_TENANT_ID=<Azure tenant id>
  fly secrets set MICROSOFT_API_CLIENT_ID=<Azure client id for the app>
  fly secrets set MICROSOFT_API_PASSWORD=<Azure client secret for the app>
  ```

- create the postgres database with
  ```bash
  fly postgres create
  ```
  Copy down the password generated by this step in a secure location, it will not be available again. *.secret files are `.gitignore`d, so you can put this in `postgres.secret` in your source checkout of Faqcheck. Then the database can be attached to the app with:

  ```bash
  fly postgres attach --postgres-app faqcheck-db
  ```

- Finally, you can deploy the site to fly.io with
  ```bash
  fly deploy
  ```


## Accessibility

These are aspirational goals and currently are not well exemplified by the code.

- Javascript should not be required. Currently most things are pretty reliant on Phoenix LiveView. Part of the idea with LiveView is that it should be able to fall back to completely server-side rendered pages when Javascript is not available, but this will require some work.
- Pages should work well with a screen reader.
- Controls should have HTML5 accessibility annotations.

## Translating content into other languages

Translation assistance is greatly appreciated, for UI phrases as well as in-app documentation. TODO: add more detailed information on how to contribute and examine translations.

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
