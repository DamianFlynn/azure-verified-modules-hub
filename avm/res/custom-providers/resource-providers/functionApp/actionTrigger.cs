using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

// Custom Provider
using CustomProvider.Authentication;
using CustomProvider.ActionTriggerHandler; // Import the namespace that contains the ActionHandler type

namespace CustomProvider.ActionTrigger
{

    public class actionTrigger
    {
        private readonly ILogger<actionTrigger> _logger;
        private readonly AzureAuthentication _azureAuthentication;

        public actionTrigger(ILogger<actionTrigger> logger,  AzureAuthentication azureAuthentication)
        {
            _logger = logger;
            _azureAuthentication = azureAuthentication;
        }

        [Function("actionTrigger")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = "subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceproviders/{minirpname}/{action}")] HttpRequest req,
        string subscriptionId,
        string resourceGroupName,
        string miniRpName,
        string action)

        {
            var handler = new ActionHandler(_logger, _azureAuthentication, req, subscriptionId, resourceGroupName, miniRpName, action);
            return await handler.HandleAction(action);
        }
    }
}