using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

// Custom Provider
using CustomProvider.ResourceTriggerHandler; // Import the namespace that contains the ActionHandler type
using CustomProvider.Authentication;

namespace CustomProvider.resourceTrigger
{

    public class resourceTrigger
    {
        private readonly ILogger<resourceTrigger> _logger;
        private readonly AzureAuthentication _azureAuthentication;


        public resourceTrigger(ILogger<resourceTrigger> logger, AzureAuthentication azureAuthentication)
        {
            _logger = logger;
            _azureAuthentication = azureAuthentication;
        }

        [Function("resourceTrigger")]
        public async Task<IActionResult> Run(                                                                                               
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", "put", "delete", Route = "subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceproviders/{minirpname}/{action}/{name}")] HttpRequestData req,
            string subscriptionId,
            string resourceGroupName,
            string miniRpName,
            string action,
            string name,
            FunctionContext executionContext)

        {
            var handler = new ResourceHandler(_logger, _azureAuthentication, req, subscriptionId, resourceGroupName, miniRpName, action, name);
            return await handler.HandleAction(action);
        }
    }
}