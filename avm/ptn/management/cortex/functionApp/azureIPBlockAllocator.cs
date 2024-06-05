using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

// Azure
using Azure.ResourceManager.ResourceGraph.Models;

// Damian Flynn
using damianflynn.network.utility;
using CustomProvider.Authentication;


namespace damianflynn.IPAMHandler
{

    /// <summary>
    /// Designed to communicate with the Azure Resource Manager Graph,
    /// this class retrieves allocated IP address blocks (CIDR) and utilizes
    /// the CidrSubnetAllocator to compute the next block available for allocation
    /// </summary>
    public class AzureIPBlockAllocator
    {
        private readonly ILogger _logger;
        private readonly AzureAuthentication _azureAuthentication;
        private readonly string _requestBody;
        private ipamRequest _ipamRequest;
        public readonly string hubAddressSpace;
        public readonly int cidrSize;


        public class ipamRequest
        {
            public string Location { get; set; }
            public Dictionary<string, string> Tags { get; set; }
            public Properties Properties { get; set; }
        }

        public class Properties
        {
            public string TenantId { get; set; }
            public string HubAddressSpace { get; set; }
            public int CidrSize { get; set; }
        }

        // public class ipamRequest
        // {
        //     public string? TenantId { get; set; } = null;
        //     public string HubAddressSpace { get; private set; }
        //     public int CidrSize { get; set; } = 25;

        //     public ipamRequest(string hubAddressSpace)
        //     {
        //         HubAddressSpace = hubAddressSpace;
        //     }
        // }

        public class IPAMRecord
        {
            [JsonPropertyName("cidr")]
            public string? cidr { get; set; } = null;
        }


        public AzureIPBlockAllocator(ILogger logger, AzureAuthentication azureAuthentication, string requestBody)
        {
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true,
                DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
            };

            _logger = logger;
            _azureAuthentication = azureAuthentication;
            _requestBody = requestBody;
            _ipamRequest = JsonSerializer.Deserialize<ipamRequest>(_requestBody, options);


            hubAddressSpace = _ipamRequest.Properties.HubAddressSpace;
            cidrSize = _ipamRequest.Properties.CidrSize;
        }

        private async Task<(ResourceQueryResult? result, Exception? exception)> GetExistingAddressSpaces(string tenantId)
        {
            string argQuery = "resources | where type =~ 'microsoft.network/virtualnetworks'";
            argQuery += "| mv-expand addressPrefix = properties.addressSpace.addressPrefixes";
            argQuery += "| project cidr = tostring(addressPrefix)";
            argQuery += "| union (Resources | where type =~ 'microsoft.network/virtualhubs' | project cidr = tostring(properties.addressPrefix))";
            argQuery += "| order by cidr desc";

            var resourceGraphQuery = new damianflynn.resourcegraph.ResourceGraphQuery(_logger, _azureAuthentication);
            
            // If the QueryResourceGraph fails, it will return null, and we must handle in the reply.
            var (result, exception) = await resourceGraphQuery.QueryResourceGraph(argQuery);
            if (exception != null)
            {
                // Handle the exception
                Console.WriteLine($"An error occurred: {exception.Message}");
                return (null, exception);
            }
            else
                return (result, null);
        }


        private List<string> GetAllocatedNetworks(ResourceQueryResult existingAddressSpaces)
        {
            var resultRecords = existingAddressSpaces.Data.ToObjectFromJson<List<IPAMRecord>>();
            var allocatedNetworks = new List<string>();
            if (resultRecords.Count == 0)
            {
                _logger.LogInformation("No IP Blocks are currently utilized.");
                return allocatedNetworks;
            }
            else
            {
                _logger.LogInformation($"The following {resultRecords.Count} IP Blocks are currently utilized:");
                foreach (var record in resultRecords)
                {
                    _logger.LogInformation($"--> {record.cidr}");
                    allocatedNetworks.Add(record.cidr);
                }

                return allocatedNetworks;
            }
        }

        private string GetNextAvailableAddress(List<string> allocatedNetworks)
        {
            var cidrAllocator = new CidrSubnetAllocator(_logger);
            return cidrAllocator.GetFirstAvailableIPBlock(cidrAllocator.GetAvailableIPBlocks(allocatedNetworks, _ipamRequest.Properties.HubAddressSpace, _ipamRequest.Properties.CidrSize));
        }


        public async Task<(String? ipPool, Exception? ex)> GetNextIPPoolAvailable()
        {
            var (existingAddressSpaces, exception) = await GetExistingAddressSpaces(_ipamRequest.Properties.TenantId);
            if (exception != null)
            {
                // Handle the exception
                Console.WriteLine($"An error occurred: {exception.Message}");
                return (null, exception);
            }
            else
            {
                var allocatedNetworks = GetAllocatedNetworks(existingAddressSpaces);
                var result = GetNextAvailableAddress(allocatedNetworks);
                return (result, null);
            }
        }

    }


}