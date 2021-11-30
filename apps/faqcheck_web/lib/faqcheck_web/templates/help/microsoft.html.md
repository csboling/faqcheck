# Connecting FaqCheck with Microsoft SharePoint and Teams

You can allow FaqCheck to connect with your Microsoft cloud services. Depending on what you enable, FaqCheck can then read files from SharePoint (like importing data from an Excel spreadsheet) and send and receive messages with Teams (like answering questions or posting reminders in a particular channel).

## SharePoint

### App registration

The first step is to set up FaqCheck as an application that is authorized to interact with your Microsoft cloud services.

- Go to https://portal.azure.com and sign in with a Microsoft account that has read access to the resources you want to use.

- In the top bar, search for "App registrations".

- Click "New registration".

- Choose a name for the registered app (e.g. FaqCheck) and add a "Redirect URI" ending with `/microsoft-callback`. For instance, if your FaqCheck installation is accessible at `https://example.org/faqcheck`, use `https://example.org/faqcheck/microsoft-callback`.

- After confirming, you will be taken to a new app registration detail page. We need to add a permission to indicate that the FaqCheck app is authorized to read SharePoint documents. On the left sidebar, click "API permissions".

- Under "Configured permissions", click "Add a permission".

- Click "Microsoft Graph", which is a combined data endpoint for retrieving data from SharePoint, Outlook Exchange, et cetera.

- You can either give FaqCheck "Delegated permissions", which means that the FaqCheck application will need a user to log in in order for FaqCheck to access data stored in Microsoft -- generally this means data can be retrieved from Microsoft automatically, but a user will have to initiate the request manually. Or you can grant FaqCheck "Application permissions", which allows FaqCheck to access data from Microsoft whenever it needs to, allowing you to use a OneDrive spreadsheet as a "single source of truth". However, enabling "Application permissions" requires approval from an administrator of your Microsoft products, such as your organization's IT department. "Delegated permissions" can be useful for trying out the functionality FaqCheck offers before asking your admin to grant "Application permissions".

- To list and read files in Sharepoint, FaqCheck needs the "Sites.Read.All" and "Files.Read" permissions. Check the box for these permission and then click "Add permissions" at the bottom.

- FaqCheck needs to be configured with a client ID value that it will use to identify itself to Microsoft. This client ID value shows on the main "App registration" page for "FaqCheck", listed under "Essentials > Application (client) ID". Copy this value and on the server where your FaqCheck server runs, set it into an environment variable (see below). The variable should be called `FAQCHECK_MICROSOFT_CLIENTID`.

- FaqCheck will also need to configure a client secret. This is a secret value that the FaqCheck application will use like a password for signing in to access Microsoft resources. On the sidebar, under "Client secrets", click "New client secret". Add a description and click "Add". The new secret key and client ID values show up in the "Client secrets" table. You will need to copy the secret key into an environment variable called `FAQCHECK_MICROSOFT_CLIENTSECRET`. Note that it may take a few minutes after creating a new client secret for it to become usable.

- After setting the environment variables, restart the FaqCheck server.


### Setting environment variables


#### Windows 10 instructions

## Teams

You can use FaqCheck as a Microsoft Teams bot to let users interact with the FaqCheck database from Teams.

- When logged in to Teams, click "Apps" and search for "App Studio".

- In App Studio, create a new bot registration and go through the wizard.

- The "Bot endpoint address" should be the URL for your FaqCheck site followed by /microsoft/messages, like https://faqcheck.my-agency.org/microsoft/messages

- You will be prompted to generate a client ID and client secret. These should be added to the prod.secret.exs configuration file like so:

```elixir
config :faqcheck, Microsoft.BotFramework,
  client_id: "*****",
  client_secret: "*****"
```
