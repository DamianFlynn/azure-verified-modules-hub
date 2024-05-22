using Microsoft.Extensions.Logging;

// Damian Flynn
using CustomProvider.Authentication;


namespace damianflynn.SubscriptionHandler
{

    /// <summary>
    /// Designed to communicate with the Azure Resource Manager Graph,
    /// this class retrieves allocated IP address blocks (CIDR) and utilizes
    /// the CidrSubnetAllocator to compute the next block available for allocation
    /// </summary>
    public class AzureSubscriptionInfo
    {
        private readonly ILogger _logger;
        private readonly AzureAuthentication _azureAuthentication;

        public class SubscriptionInfo
        {
            public string SubscriptionId { get; set; }
            public string DisplayName { get; set; }
        }

        public AzureSubscriptionInfo(ILogger logger, AzureAuthentication azureAuthentication)
        {
            _logger = logger;
            _azureAuthentication = azureAuthentication;
        }

        public List<SubscriptionInfo>? GetSubscriptions()
        {
            var subscriptions = _azureAuthentication._armTenant?.GetSubscriptions().Select(x => new SubscriptionInfo
            {
                SubscriptionId = x.Data.SubscriptionId.ToString(),
                DisplayName = x.Data.DisplayName
            }).ToList();

            return subscriptions;
        }
    }
}