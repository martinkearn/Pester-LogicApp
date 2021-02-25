# Pester-LogicApp
This is a sample showing how to use Pester and PowerShell to integration test a logic app.

The sample uses a very simple logic app that gets a weather report using the MSN Weather connector. The main purpose of the repository is to demonstrator how to use Pester and PowerShell to perform integration tests on Logic Apps.

For more detail about the principles in this sample, see this article: http://martink.me/articles/integration-testing-logic-apps

## The Logic App
The test is setup to work with this logic app.

 ![The logic app overview](https://github.com/martinkearn/Pester-LogicApp/raw/main/Logic%20App%20Template/LogicAppOverview.jpg)
 
You can deploy this on your own Azure subscription using the template in [/Logic App Template](https://github.com/martinkearn/Pester-LogicApp/tree/main/Logic%20App%20Template). For detail on how to do that, see [Deploy Azure Resource Manager templates for Azure Logic Apps](https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-deploy-azure-resource-manager-templates).

## Pester
This test is designed to use [Pester V5](https://pester.dev/). To get an overview of Pester, see these resources:
- [Pester Docs > Quick Start](https://pester.dev/docs/quick-start)
- [Integration testing with Pester and PowerShell](http://martink.me/articles/integration-testing-with-pester-and-powershell)

## Setup & Usage
To run the test
1. Clone this repository
2. Deploy the [/Logic App Template](https://github.com/martinkearn/Pester-LogicApp/tree/main/Logic%20App%20Template). For detail on how to do that, see [Deploy Azure Resource Manager templates for Azure Logic Apps](https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-deploy-azure-resource-manager-templates).
3. Make a copy of [/ps/sample.env](https://github.com/martinkearn/Pester-LogicApp/blob/main/PS/sample.env) named `.env` and fill in the values to match your deployed Logic App. Ensure this is in the same folder as your `.ps1` files.
4. Open a PowerShell console and navigate to the folder containing `/PS/LogicApp.tests.ps1`
5. Run this commmand

```PowerShell
Invoke-Pester -Output Detailed LogicApp.tests.ps1
```

6. If sucessfull, 6 tests should have passed
