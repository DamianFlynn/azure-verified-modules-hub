using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

// Damian Flynn
using damianflynn.SubscriptionHandler;
using CustomProvider.Authentication;


namespace CustomProvider.ActionTriggerHandler
{
    public class ActionHandler
    {
        private readonly ILogger _logger;
        private readonly AzureAuthentication _azureAuthentication;
        private readonly HttpRequest _req;
        private readonly string _requestBody;

        public ActionHandler(ILogger logger, AzureAuthentication azureAuthentication, HttpRequest req, string subscriptionId, string resourceGroupName, string minirpname, string action)
        {
            _logger = logger;
            _req = req;
            _requestBody = new StreamReader(req.Body).ReadToEndAsync().Result;
            _azureAuthentication = azureAuthentication;
            _logger.LogInformation($"Custom Provider Action Triggered: '{action}' with request method '{req.Method}'. " +
                          $"Details: subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceproviders/{minirpname}/{action}'" +
                          $"Payload: '{_requestBody}'");
        }

        public async Task<IActionResult> HandleAction(string action)
        {
            switch (action)
            {
                case "ping":
                    return await HandlePingAction();
                case "listMyCustomAction":
                    return await HandleListMyCustomAction();
                case "listSubscriptions":
                    return await HandleListSubscriptions();
                // Add other cases here...
                default:
                    return new StatusCodeResult(StatusCodes.Status204NoContent);
            }
        }

        private Task<IActionResult> HandlePingAction()
        {
            return HandlePostAction(async () =>
            {
                var host = GetHost();
                var content = $"{{ 'pingcontent' : {{ 'source' : '{host}' }} , 'message' : 'hello {host}'}}";
                return new OkObjectResult(content);
            });
        }


        private Task<IActionResult> HandleListMyCustomAction()
        {
            return HandlePostAction(async () =>
            {
                var host = GetHost();
                var resultObject = new
                {
                    listMyActionResult = new
                    {
                        source = host,
                        timestamp = DateTime.UtcNow,
                        randomString = Guid.NewGuid().ToString(),
                        body = _requestBody
                    },
                    message = $"see this? {host}"
                };
                return new OkObjectResult(resultObject);
            });
        }


        private Task<IActionResult> HandleListSubscriptions()
        {

            return HandlePostAction(async () =>
            {
                var tenantId = _azureAuthentication._armTenant?.Data.TenantId.ToString();

                var subscriptionInfo = new AzureSubscriptionInfo(_logger, _azureAuthentication);

                var resultObject = new
                {
                    tenantId = tenantId,
                    subscriptions = subscriptionInfo.GetSubscriptions()
                };
                return new OkObjectResult(resultObject);
            });
        }

        private Task<IActionResult> HandlePostAction(Func<Task<IActionResult>> action)
        {
            _logger.LogInformation($"Starting '{action.Method.Name}' action process for method: '{_req.Method}'");
            if (_req.Method != HttpMethod.Post.Method)
            {
                return Task.FromResult<IActionResult>(new StatusCodeResult(StatusCodes.Status405MethodNotAllowed));
            }
            else
            {
                return action();
            }
        }

        private string GetHost()
        {
            var host = _req.Headers["Host"].FirstOrDefault() ?? "anonymous";
            _logger.LogInformation($"The host was: '{host}'");
            return host;
        }
    }

}



