// System
using System.Net;
using System.Numerics;

// Logging
using Microsoft.Extensions.Logging;

namespace damianflynn.network.utility
{
    public class CidrSubnetAllocator
    {

        private readonly ILogger _logger;

        public CidrSubnetAllocator(ILogger logger)
        {
            _logger = logger;
        }


        /// <summary>
        /// Calculates the next subnet based on the current network and CIDR values.
        /// </summary>
        /// <param name="currentNetwork">The current network IP address.</param>
        /// <param name="currentCidr">The current CIDR value.</param>
        /// <param name="requestedCidrSize">The requested CIDR size for the next subnet.</param>
        /// <returns>The next subnet as an IPNetwork2 object.</returns>
        private IPNetwork2 GetNextSubnet(IPAddress currentNetwork, int currentCidr, int requestedCidrSize)
        {
            // Log the calculation process
            _logger.LogInformation($"Calculating the next '/{requestedCidrSize}' IP Block following {currentNetwork}/{currentCidr}");

            // Create a new IP network with the current network and CIDR
            IPNetwork2 currentIpBlock = new IPNetwork2(currentNetwork, (byte)currentCidr);

            // Calculate the netmask for the requested CIDR size
            var netmask = System.Net.IPNetwork2.ToNetmask((byte)requestedCidrSize, currentIpBlock.AddressFamily);

            // Calculate the next address by adding 1 to the broadcast address of the current network
            BigInteger nextAddr = System.Net.IPNetwork2.ToBigInteger(currentIpBlock.Broadcast) + 1;

            // Apply the netmask to the next address
            BigInteger mask = System.Net.IPNetwork2.ToBigInteger(netmask);
            BigInteger masked = nextAddr & mask;

            // Determine the next address based on whether the masked address equals the next address
            BigInteger next;
            if (masked == nextAddr)
            {
                next = masked;
            }
            else
            {
                next = masked + BigInteger.Pow(2, 32 - requestedCidrSize);
            }

            // Convert the next address to an IP address
            var nextNetwork = System.Net.IPNetwork2.ToIPAddress(next, System.Net.Sockets.AddressFamily.InterNetwork);

            // Parse the next network and netmask into an IPNetwork2 object
            var nextSubnet = System.Net.IPNetwork2.Parse(nextNetwork, netmask);

            // Log the result
            _logger.LogInformation($" to be {nextSubnet}");

            // Return the next subnet
            return nextSubnet;
        }


        public List<IPNetwork> GetAvailableIPBlocks(List<string> networks, string superNet, int cidr)
        {
            _logger.LogInformation($"Looking for a '/{cidr}' IP block from {superNet}. Ignoring allocated networks {networks.ToString}");
            IPNetwork2 superNetwork = IPNetwork2.Parse(superNet);

            List<IPNetwork> reservedBlocks = new List<IPNetwork>();
            List<IPNetwork> availableBlocks = new List<IPNetwork>();


            // Checks if the networks list is empty or contains a single whitespace string. If it does, it creates a new NetworkInfo object with the base network and the CIDR value, marks it as free, and adds it to the reservedBlocks list.
            // If the networks list is not empty, it iterates over each item in the list, parses the IP address from the item, and checks if it is contained within the base network. If it is, it creates a new NetworkInfo object with the network from the item, marks it as not free, and adds it to the reservedBlocks list.
            // Finally, it sorts the reservedBlocks list by the first usable IP address in each network.

            if (networks.Count == 0 || (networks.Count == 1 && string.IsNullOrWhiteSpace(networks[0])))
            {
                reservedBlocks.Add(IPNetwork.Parse($"{superNetwork.Network}/{cidr}"));
            }
            else
            {
                foreach (var item in networks)
                {
                    var ipAddress = IPAddress.Parse(item.Split('/')[0]);
                    if (superNetwork.Contains(ipAddress))
                    {
                        reservedBlocks.Add(IPNetwork.Parse(item));
                    }
                }
                reservedBlocks.Sort((x, y) => System.Collections.StructuralComparisons.StructuralComparer.Compare(x.BaseAddress.GetAddressBytes(), y.BaseAddress.GetAddressBytes()));
            }



            // Lets look at the first address in the base network and the first address in the first allocated network block
            // If this are available IP addresses between these, figure out how many
            BigInteger firstFree = IPNetwork2.ToBigInteger(superNetwork.FirstUsable);
            BigInteger lastFree = reservedBlocks.Count > 0 ? IPNetwork2.ToBigInteger(new IPNetwork2(reservedBlocks[0].BaseAddress, (byte)reservedBlocks[0].PrefixLength).FirstUsable) : firstFree;
            if ((lastFree - firstFree) >= BigInteger.Pow(2, 32 - cidr))
            {
                _logger.LogInformation($"The Base Network has enough space before the first allocated block.");
                IPNetwork newNetwork = new IPNetwork(superNetwork.Network, cidr);
                if (!availableBlocks.Any(ip => ip.Equals(newNetwork)))
                {
                    availableBlocks.Add(newNetwork);
                }
            }

            // Search for free ranges in between the items of the 'used' nets list and after the last one
            // Iterates over the reservedBlocks list,

            for (int i = 0; i <= reservedBlocks.Count - 1; i++)
            {

                var ipRange = reservedBlocks[i];
                IPNetwork2 subnet = GetNextSubnet(ipRange.BaseAddress, ipRange.PrefixLength, cidr); // You need to implement this method

                // Test if 'next subnet' is a part of a base range
                if (!superNetwork.Contains(subnet))
                {
                    _logger.LogInformation($"Allocated subnet is: {ipRange}; Next subnet would be: {subnet}, but it is not in {superNet}");
                    continue;
                }
                else
                {
                    _logger.LogInformation($"Allocated subnet is: {ipRange}; Next subnet would be: {subnet} and it is in {superNet}");
                }

                // Test if 'next subnet' overlaps any of the existing below it in a sorted list
                bool isOverlap = false;
                for (int k = i; k < reservedBlocks.Count; k++)
                {
                    if (subnet.Overlap(new IPNetwork2(reservedBlocks[k].BaseAddress, (byte)reservedBlocks[k].PrefixLength)))
                    {
                        _logger.LogInformation($"{subnet} overlaps {reservedBlocks[k]}");
                        isOverlap = true;
                        break;
                    }
                    else
                    {
                        _logger.LogInformation($"{subnet} does not overlap {reservedBlocks[k]}");
                    }
                }

                // If it does not overlap, add it to the availableBlocks list
                if (!isOverlap)
                {
                    _logger.LogInformation($"{subnet} did not overlap");
                    IPNetwork newNetwork = new IPNetwork(subnet.Network, subnet.Cidr);
                    if (!availableBlocks.Any(ip => ip.Equals(newNetwork)))
                    {
                        availableBlocks.Add(newNetwork);
                    }
                }
            }


            if (availableBlocks.Count > 0)
            {
                _logger.LogInformation($"IP ranges we've got: {string.Join(", ", availableBlocks)}");
            }
            else
            {
                _logger.LogInformation("We did not get any IP ranges");
            }

            return availableBlocks;
        }

        public string? GetFirstAvailableIPBlock(List<IPNetwork> availableBlocks)
        {
            _logger.LogInformation($"Get First Available IP Block");
            if (availableBlocks.Count > 0)
            {
                _logger.LogInformation($"Returning IP Block: {availableBlocks[0].BaseAddress}");
                return availableBlocks[0].BaseAddress.ToString();
            }
            else
            {
                _logger.LogInformation("No IP Blocks available");
                return null;
            }
        }

    }
}