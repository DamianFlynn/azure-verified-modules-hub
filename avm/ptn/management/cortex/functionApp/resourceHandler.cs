using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

// Damian Flynn
using damianflynn.IPAMHandler;
using CustomProvider.Authentication;


namespace CustomProvider.ResourceTriggerHandler
{
    public class ResourceHandler
    {
        private readonly ILogger _logger;
        private readonly AzureAuthentication _azureAuthentication;

        private readonly Microsoft.Azure.Functions.Worker.Http.HttpRequestData _req;
        private readonly string _requestBody;
        private readonly string _id;
        private readonly string _miniRpName;
        private readonly string _action;
        private readonly string _name;

        public ResourceHandler(ILogger logger, AzureAuthentication azureAuthentication, HttpRequestData req, string subscriptionId, string resourceGroupName, string miniRpName, string action, string name)
        {
            _logger = logger;
            _req = req;
            _miniRpName = miniRpName;
            _action = action;
            _name = name;
            _id = $"/subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/{miniRpName}/{action}/{name}".ToLower();
            _requestBody = new StreamReader(req.Body).ReadToEndAsync().Result;
            _azureAuthentication = azureAuthentication;
            _logger.LogInformation($"Custom Provider Resource Triggered: '{action}' with request method '{req.Method}'. \n" +
                          $"Details: '{_id}' \n" +
                          $"Payload: '{_requestBody}'\n");
        }

        public async Task<IActionResult> HandleAction(string action)
        {
            switch (action)
            {
                case "NextAvailableNetwork":
                    return await HandleListNextAvailableNetwork();
                // Add other cases here...
                default:
                    return new StatusCodeResult(StatusCodes.Status204NoContent);
            }
        }


        private Task<IActionResult> HandleListNextAvailableNetwork()
        {
            return HandleAction(async () =>
            {
                if (_requestBody == "")
                {
                    _logger.LogInformation("No request body properties was provided.");
                    return new StatusCodeResult(StatusCodes.Status204NoContent);
                }
                else
                {
                    AzureIPBlockAllocator ipam = new AzureIPBlockAllocator(_logger, _azureAuthentication, _requestBody);
                    var (nextAddress, exception) = await ipam.GetNextIPPoolAvailable();

                    if (exception != null)
                    {
                        // Handle the exception
                        Console.WriteLine($"An error occurred: {exception.Message}");
                        return new StatusCodeResult(StatusCodes.Status500InternalServerError);
                    }
                    else
                    {
                        if (nextAddress == null)
                        {
                            _logger.LogInformation($"No Address blocks available in the Hub CIDR Block '{ipam.hubAddressSpace}'.");
                            return new StatusCodeResult(StatusCodes.Status204NoContent);
                        }
                        else
                        {
                            _logger.LogInformation($"Offering address block: '{nextAddress}/{ipam.cidrSize}'");
                            var resultObject = new
                            {
                                id = _id,
                                name = _name,
                                type = $"Microsoft.CustomProviders/resourceproviders/{_action}",
                                properties = new
                                {
                                    addressPrefix = $"{nextAddress}/{ipam.cidrSize}",
                                    SubnetIP = nextAddress,
                                    CIDR = ipam.cidrSize
                                },
                            };
                            return new OkObjectResult(resultObject);
                        }
                    }
                }
            });

        }



        private Task<IActionResult> HandleAction(Func<Task<IActionResult>> action)
        {
            _logger.LogInformation($"Starting '{action.Method.Name}' action process for method: '{_req.Method}'");
            if (_req.Method != HttpMethod.Get.Method && _req.Method != HttpMethod.Post.Method && _req.Method != HttpMethod.Put.Method && _req.Method != HttpMethod.Delete.Method)
            {
                return Task.FromResult<IActionResult>(new StatusCodeResult(StatusCodes.Status405MethodNotAllowed));
            }
            else
            {
                return action();
            }
        }

        private string? GetHost()
        {
            if (_req.Headers.Any(h => h.Key == "Host"))
            {
                var hostValues = _req.Headers.First(h => h.Key == "Host").Value;
                string host = hostValues != null && hostValues.Any() ? hostValues.First() : "anonymous";
                _logger.LogInformation($"The host was: '{host}'");
                return host;
            }
            else
            {
                _logger.LogInformation("The host header was not found.");
                return "anonymous";
            }
        }
    }

}



