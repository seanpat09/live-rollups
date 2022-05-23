# Dynamic Account Rollups Prototypes

Using External Objects and the Apex Connector Framework, can we create live rollups? This is a prototype that creates dynamic rollups, allowing you to run a report such as "Find all Accounts that have donated more than $1000"

## Setup
* Deploy this code base to a scratch org
* Assign your user the `Accounts_Rollup_Summaries` permission set
* Create a report for the `AccountRollup__x` object type. Only include the Name and Donation Total fields (for some reason adding the AccountRecord field causes the report to break)
* Add filters to the Report, i.e. Donation Totals > 1000
* Run the report, each row should have a link to the Summary Record, which has a link to the Account record. The AccountRecord field is the link to the Account detail page, but for some reason that breaks in reports, but not in layouts.