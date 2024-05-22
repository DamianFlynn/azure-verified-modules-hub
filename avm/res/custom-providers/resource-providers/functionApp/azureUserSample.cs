using Microsoft.Extensions.Logging;


namespace damianflynn.UserHandler
{

    /// <summary>
    /// Designed to communicate with the Azure Resource Manager Graph,
    /// this class retrieves allocated IP address blocks (CIDR) and utilizes
    /// the CidrSubnetAllocator to compute the next block available for allocation
    /// </summary>
    public class AzureUserSample
    {
        private readonly ILogger _logger;

        private static string separator = ":::";

        public class UserResource
        {
            public string name { get; set; }
            public string type { get; set; }
            public string id { get; set; }
            public User properties { get; set; }
        }

        public class User
        {
            public string FullName { get; set; }
            public string Location { get; set; }
        }

        public AzureUserSample(ILogger logger)
        {
            _logger = logger;
        }


        private static Dictionary<string, UserResource> GetUserDictionaryFromFile(string storageBlob, ILogger logger)
        {
            var dictionary = new Dictionary<string, UserResource>();

            if (string.IsNullOrEmpty(storageBlob)) return dictionary;

            var users = storageBlob.Split(new[] { separator }, System.StringSplitOptions.RemoveEmptyEntries);
            foreach (var user in users)
            {
                var data = user.Split(',');
                if (data.Length == 5)
                {
                    dictionary.Add(data[2], new UserResource
                    {
                        name = data[0],
                        type = data[1],
                        id = data[2],
                        properties = new User { FullName = data[3], Location = data[4] }
                    });
                }
            }

            return dictionary;
        }
    }
}