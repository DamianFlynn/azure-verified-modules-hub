using Microsoft.Extensions.Logging;

// Azure
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.ResourceGraph;
using Azure.ResourceManager.ResourceGraph.Models;
using Azure.ResourceManager.Resources;
using CustomProvider.Authentication;

namespace damianflynn.resourcegraph
{
    public class ResourceGraphQuery
    {
        private readonly ILogger _logger;
        private readonly AzureAuthentication _azureAuthentication;

        public ResourceGraphQuery(ILogger logger, AzureAuthentication azureAuthentication)
        {
            _logger = logger;
            _azureAuthentication = azureAuthentication;
            _logger.LogInformation($"Tenant Information: {_azureAuthentication._armTenant?.Data.DisplayName} '{_azureAuthentication._armTenant?.Data.TenantId}' ({_azureAuthentication._armTenant?.Data.DefaultDomain})");
        }


        public async Task<(ResourceQueryResult? result, Exception? exception)> QueryResourceGraph(string azureResourceGraphQuery)
        {
            try
            {
                _logger.LogInformation($"Querying Resource Graph");
                ResourceQueryContent content = new ResourceQueryContent(azureResourceGraphQuery) { };
                ResourceQueryResult result = await _azureAuthentication._armTenant.GetResourcesAsync(content);
                _logger.LogInformation($"Resource Graph Query Result: {result.Data}");

                return (result, null);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error querying Resource Graph: {ex.Message}");
                return (null, ex);
            }

        }
    }
}