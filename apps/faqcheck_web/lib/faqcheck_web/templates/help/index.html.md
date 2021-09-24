# Purpose

FaqCheck is a web application intended to allow people to easily find and contribute information about resources in their community. Contributors can import contact information from spreadsheets and databases already used within their organizations to help build a list of resources. Anyone can then search this list to find resources they need, and leave anonymous feedback about the listing.

# Searching

You can search for facilities or agencies that are stored in the application by using the search form at the top of the [facilities page](/live/facilities). Put information in one or more boxes to filter which facilities will be shown, then click "Search" to show the filtered list of results. Click "Reset search filters" at any time to show the whole list of results. Filters that are currently active should appear in the input boxes where you typed them in or selected them.

# Adding new data

To add new data to the system, you need to log in. Depending on how FaqCheck is deployed, login may be available to users with an existing account with some provider. For instance an organization that uses Office 365 for email and document sharing can configure FaqCheck to let users log in with their Microsoft accounts. Once logged in, the appearance of the facilities page will change to include "Edit" buttons for each item. You can also click "Import Facilities" at the top or bottom of the page to load data from an external source like a spreadsheet.

The "Import Facilites" page will let you import and review data from an external data source. Pick the data source you want to use from the drop down. Some data sources, like Microsoft SharePoint, may need to to also find the right file -- a list of folders will be presented, and the files and subfolders in each folder will be listed when you click the name of the folder. Click the name of the folder again to hide this subtree. Once you've found the right file, click the "Import" button next to it. This will take you to a page similar to the facilities page which allows you to review and save each item from the imported spreadsheet.

FaqCheck tries to take data from external sources and extract information like street addresses and business hours. Items where some inputs could not be understood will have a red warning label and will not allow you to save them. Items where the database already contains an item with the same name will have a yellow warning label -- saving the imported values will overwrite the existing entry. However, FaqCheck keeps track of each item's edit history, so older values should be possible to recover. If the spreadsheet has multiple pages, they will appear as several links towards the top of this import review page.

# Technical details

More technical information and source code can be found on the [Github page](https://github.com/csboling/faqcheck).
