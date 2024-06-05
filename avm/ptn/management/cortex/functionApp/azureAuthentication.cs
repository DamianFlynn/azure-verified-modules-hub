using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.Resources;

/// <summary>
/// The CustomProvider.Authentication namespace contains classes used for handling authentication with Azure.
/// </summary>
namespace CustomProvider.Authentication
{
    /// <summary>
    /// The AzureAuthentication class is responsible for authenticating with Azure using the Azure Resource Manager (ARM) client.
    /// </summary>
    public class AzureAuthentication
    {
        private readonly ArmClient _armClient;
        public readonly TenantResource? _armTenant = null;

        
        /// <summary>
        /// Initializes a new instance of the AzureAuthentication class.
        /// </summary>
        public AzureAuthentication()
        {
            string tenantId = "c0ff482c-f0bb-426d-b91b-5fae5b5ace06";
            _armClient = new ArmClient(new DefaultAzureCredential());
            
            try{
                Console.WriteLine($"Retrieving Tenant Details");

                /// <summary>
                /// If the tenantId is null or empty, it retrieves the first tenant from the list of tenants.
                /// Otherwise, it retrieves the tenant with the specified tenantId.
                /// </summary>
                if (string.IsNullOrEmpty(tenantId))
                    _armTenant = _armClient.GetTenants().FirstOrDefault();
                else
                    _armTenant = _armClient.GetTenants().Where(x => x.Data.TenantId == new Guid(tenantId)).FirstOrDefault();
                
                Console.WriteLine($"Tenant Information: {_armTenant?.Data.DisplayName} '{_armTenant?.Data.TenantId}' ({_armTenant?.Data.DefaultDomain})");
            }
            catch (Exception ex)
            {
                // Handle exception...
                Console.WriteLine($"Error retrieving Tenant Details: {ex.Message}");
            }
        }
    }
}