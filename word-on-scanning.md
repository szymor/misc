# A word on port scanning

Port scanning is the process of collecting data about service availability on hosts connected to networks, including the Internet.

## Why?

It seems obvious - if something is available, you can use it. How would you browse websites without knowing where they are hosted? How would you transfer files between hosts if you were not aware they support FTP transfers? How would you chat with others if you did not know where an IRC service is hosted?

Of course, there are multiple ways to get this kind of information, and port scanning is one of them. You might say, "I do not need that, I can use [Google](https://www.google.com/), [Bing](https://www.bing.com/), or [Yandex](https://yandex.ru/)." You can, but you will be limited to information published on websites, and in some cases, it is really limiting. Not to mention, using an Internet search engine to traverse hosts in your local network is pointless.

## Why not?

Mental slaves and shady salarymen working with search engines might tell you that port scanning is illegal. I am not a lawyer, but I can assure you it is not. Scanning is not a malicious activity unless you cause service degradation (not to mention denial of service). In fact, the major working principle of some search engines is port scanning. Classic web scraping, used by popular web search engines, is also not so different from port scanning in principle.

However, using services that are not willingly published by host owners is actually illegal in many jurisdictions. It does not matter whether you acquire knowledge about those services via port scanning or Google dorking. Just do not be evil.

You may not want to scan ports for another reason - somebody else has already done that and distributes scan results freely or for a small fee. Examples?

- [Shodan](https://www.shodan.io/),
- [Censys](https://search.censys.io/),
- [ZoomEye](https://www.zoomeye.hk/).

You can also find specialized search engines for specific services (like [Mamont](https://www.mmnt.ru/) for FTP).

## How?

### Basics

Launch your favorite Linux distribution and type:
```
nmap 192.168.0.1
```

If you are in a network where a host with IP 192.168.0.1 exists, you will see the scan result of 1,000 TCP ports from the selected host. It takes some time, and you probably are interested in a single service, so let's scan a single port instead:
```
nmap -p22 192.168.0.1
```

How does such a scan work? It consists of four stages:

1. DNS query, only if you provide a domain name instead of an IP address.
2. Host discovery, nmap sends two SYN packets to ports 80 and 443.
3. rDNS query, i.e., a PTR record query to map an IP address to a domain name.
4. An actual port scan by sending a SYN packet to a chosen port (22 in this example), retransmissions are possible.

Please note that if you run the above command as root, host discovery will be a bit more complex, as it will consist of an ICMP echo request, a TCP SYN packet to port 443, a TCP ACK packet to port 80, and an ICMP timestamp request.

Can you omit superfluous stages? Yes. The `-Pn` option skips host discovery, and the `-n` option avoids DNS resolutions - if you use domain names as a target specifier, then you cannot avoid them completely, though. The final command looks like this:
```
nmap -p22 -Pn -n 192.168.0.1
```

Please note that an ARP scan will be performed for unknown hosts in local networks, regardless of the `-Pn` option, as it is faster than a blind port scan.

If you want to scan more devices in the network, you can specify a range of hosts:
```
nmap -p22 -Pn -n 192.168.1-254
```

Scanning a randomly chosen public subnet of 256 hosts took ~3.1 seconds with nmap on my Internet connection (uplink 30 Mb/s). It seems fast, but what if you wanted to scan the entire Internet? Simple math shows it would take more than 1.5 years to cover the whole possible IPv4 address space. Can you do it faster? You could tweak nmap using various command-line options (see `-T` in the manual), but there are better tools for this task:

- [ZMap](https://zmap.io/) - according to the manual, ZMap is capable of scanning the entire Internet in around 45 minutes on a gigabit network connection, reaching ~98% theoretical line speed,
- [masscan](https://github.com/robertdavidgraham/masscan) - the manual claims that masscan provides a scanning rate sufficient to scan the Internet in 3 minutes for one port.

It does not really matter which one I choose, as my Internet connection is quite slow. Let's do some tests with ZMap:
```
sudo zmap -p 22 -X 203.0.113.0/24
```
Two things need clarification. I use `-X` with ZMap to send IP layer packets instead of Ethernet ones because I'm using a Wi-Fi connection. You can expect a speed boost after switching to an Ethernet connection. The second thing is the IP address range used above. It is an IP range reserved in RFC 5737 for documentation purposes, so no worries you will see anything there. If you wonder about the syntax used to define this range, it is called "CIDR representation form" defined in RFC 1878.

Ok, but what is the scan speed of ZMap? Sending SYN packets to all 256 hosts took less than 0.02 seconds, excluding cooldown time, during which ZMap waits for late responses. Impressive. That means the whole IPv4 address range could be scanned in less than 3.5 days. In fact, Internet scanning will be done faster, as only a part of the address space is accessible publicly. ZMap will omit inaccessible subnets by default, but let's list them for the sake of clarity:

| Address Block | Name | RFC
| ------------- | ---- | ---
| 0.0.0.0/8 | This network | 791
| 0.0.0.0/32 | This host on this network | 1122
| 10.0.0.0/8 | Private-Use | 1918
| 100.64.0.0/10 | Shared Address Space | 6598
| 127.0.0.0/8 | Loopback | 1122
| 169.254.0.0/16 | Link Local | 3927
| 172.16.0.0/12 | Private-Use | 1918
| 192.0.0.0/24 | IETF Protocol Assignments | 6890
| 192.0.0.0/29 | IPv4 Service Continuity Prefix | 7335
| 192.0.0.8/32 | IPv4 dummy address | 7600
| 192.0.0.9/32 | Port Control Protocol Anycast | 7723
| 192.0.0.10/32 | Traversal Using Relays around NAT Anycast | 8155
| 192.0.0.170/32, 192.0.0.171/32 | NAT64/DNS64 Discovery | 8880, 7050
| 192.0.2.0/24 | Documentation (TEST-NET-1) | 5737
| 192.88.99.0/24 | Deprecated (6to4 Relay Anycast), termination date: 2015-03 | 7526
| 192.168.0.0/16 | Private-Use | 1918
| 198.18.0.0/15 | Benchmarking | 2544
| 198.51.100.0/24 | Documentation (TEST-NET-2) | 5737
| 203.0.113.0/24 | Documentation (TEST-NET-3) | 5737
| 224.0.0.0/4 | Multicast/Reserved | 5771
| 240.0.0.0/4 | Reserved | 1112
| 255.255.255.255/32 | Limited Broadcast | 919

You can find the above in `/etc/zmap/blocklist.conf`. Note that some address blocks are subsets of the others.

The address blocks below are part of the IANA IPv4 Special-Purpose Address Registry, but for some reason, they are not blocked against scanning by ZMap by default. I do not expect to find any service useful for a regular user there, so you can blacklist them:

| Address Block | Name | RFC
| ------------- | ---- | ---
| 192.31.196.0/24 | AS112-v4 | 7535
| 192.52.193.0/24 | AMT | 7450
| 192.175.48.0/24 | Direct Delegation AS112 Service | 7534

The address blocks below provide poor scanning results from my experience, so you may want to avoid them:

| Address Block | Company |
| ------------- | ---- |
| 6.0.0.0 | DoD Network Information Center
| 7.0.0.0 | DoD Network Information Center (DoD NIC)
| 9.0.0.0 | IBM, RIPE NCC, Quad9
| 11.0.0.0 | DoD Network Information Center (DoD NIC)
| 17.0.0.0 | Apple Inc.
| 19.0.0.0 | Ford Motor Company
| 21.0.0.0 | DoD Network Information Center (DoD NIC)
| 22.0.0.0 | DoD Network Information Center (DoD NIC)
| 25.0.0.0 | RIPE Network Coordination Centre
| 26.0.0.0 | DoD Network Information Center (DoD NIC)
| 28.0.0.0 | DoD Network Information Center (DoD NIC)
| 29.0.0.0 | DoD Network Information Center (DoD NIC)
| 30.0.0.0 | DoD Network Information Center (DoD NIC)
| 33.0.0.0 | DoD Network Information Center (DoD NIC)
| 48.0.0.0 | The Prudential Insurance Company of America, RIPE NCC
| 53.0.0.0 | RIPE Network Coordination Centre
| 55.0.0.0 | DoD Network Information Center
| 56.0.0.0 | United States Postal Service, Amazon.com
| 214.0.0.0 | DoD Network Information Center (DoD NIC)
| 215.0.0.0 | DoD Network Information Center (DoD NIC)

In fact, it is a good idea to find all the address blocks reserved by DoD NIC (there are many more than listed here!) and blacklist them.

### Service availability

Let's assume some ports are open. Does it mean that they provide services as specified in the [Service Name and Transport Protocol Port Number Registry](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml)? Of course not. Even if you are lucky, you would rather want to know more details about the service, like the supported protocol version.

The easiest way to verify scanned ports is to try to connect to them using a known protocol. You can do that using dedicated software or custom scripts (Python, Perl, bash, etc.). If you aim for speed, you can use specialized tools:

- masscan with the `--banners` option,
- [ZGrab](https://github.com/zmap/zgrab2), built to work with ZMap (ZMap identifies L4 responsive hosts, ZGrab performs in-depth, follow-up L7 handshakes).

Read their documentation, as I will not cover them in detail here.

### Issues

There are a few things you need to take into consideration to get satisfactory results from your scans.

#### Host availability

Some devices on the Internet may be accessible publicly only for a fraction of a day, like personal computers or laptops. Is it a big issue? Well, I do not think so. Who connects their user equipment directly to a modem? Usually, you want to use multiple devices at home or in the office, possibly over Wi-Fi as well, so a router connected to a modem (or a router with built-in modem functionality) is a must. It is convenient to leave a router enabled all the time, so you can assume this issue relates to a minority of hosts.

#### Dynamic public/external IPs of scanned hosts

My observations show that it is much easier to be provided with a dynamic IP from your Internet Service Provider rather than a static one. On the other hand, most users do not host their own services. The actual dynamic-to-static ratio is hard to determine, so do not linger over the analysis of your freshly acquired data. Keep in mind that some ISPs rotate dynamic IPs every 24 hours, whereas in other cases, they change them less frequently than once a fortnight.

#### Port scan detection and prevention

Port scan detection and prevention are common functionalities of any firewall. Where can you find firewalls? There are two obvious places:

- the gateway of a host you want to scan,
- the gateway of your own home network.

You do not have much influence on the protection measures of your target, but you can minimize the chance of detection. Here are your possibilities:

- Do not scan multiple ports of a single host at once - if you want to cover a range of hosts, focus on a single service.
- Do not scan hosts sequentially according to their IP address; shuffle a pool of IP addresses before scanning - fortunately, this is done by ZMap and masscan. IP addresses ordered sequentially often belong to the same subnetwork, which means they have a common firewall.
- Do not hurry; do it slowly. I found a few articles claiming that scan speed does not influence the quality of results, but my experience is different. I get ~40x more results when scanning with 1 kp/s rather than 60 kp/s (p/s - packets per second).

By the way, there is a special case of targets I want to mention here—paranoid hosts. In some situations, you will want to scan specific IPs, e.g., because they show up in access logs of your HTTP or FTP services. As soon as you start scanning them, you will be banned from accessing any of their ports. Suddenly, without any warning. If you want to scan suspicious machines (like malware sowers), keep that in mind.

On the other hand, you are the master of your home network. Check your router. Double-check if it is from your ISP. Can you disable port scan detection, which is often enabled by default? If you are using an ISP router, there is a chance that the configuration interface is fake, and your choices don't matter much. The solution is to use a bare modem or to configure the ISP router to work in bridge mode. Ask your ISP for details. If everything is set up properly, you can finally connect your hardware (i.e., a computer or an off-the-shelf router) without an intermediary. You might be wondering if it is really worth the effort. A little comparison from my own experience, the same IP range, the same scan settings (i.e., maximum possible scan speed):

- an ISP router in a default configuration - 94,775 open ports detected for a single service,
- an ISP router in a bridge mode + MikroTik hAP ac lite router - 271,480 open ports detected for the same service as above.

"Only" 3x difference? No, in the first case, adjusting scan speed had no visible effect on results. In the latter case... well, read a few sentences back.

If you wonder how firewalls detect port scanning, read about Snort's Port Scan Inspector or MikroTik's firewall PSD (port scan detection) option.

#### Router CPU utilization

For some reason, handling traffic consisting of a massive amount of SYN packets is much more CPU intensive than regular traffic. My MikroTik hAP ac lite is able to handle ~5.5 Mbit upload at 100% CPU utilization, whereas my ISP upload limit is 30 Mbit. The possible explanation is that FastTrack hardware acceleration for packet traffic control cannot be used in such a scenario. Whatever the reason is, keep this limitation in mind. If you want to scan even faster, consider connecting your PC directly to a modem or buying a high-end router.

#### Port scanning over mobile networks

Cellular networks are useless in this use case, as port scanning is aggressively blocked by many mobile network operators. Example for a specific IP range:

- port scan over an [HFC](https://en.wikipedia.org/wiki/Hybrid_fiber-coaxial) network using an ISP router in a default configuration (far from ideal) - ~3,000 open ports detected for a single service,
- port scan over a mobile network using my phone's hotspot - 80 open ports detected for the same service as above.

If you still insist on port scanning that way, there are more issues, like relatively low speed, false positives (e.g., on ports 1720 or 5060), or filtered responses from hosts. Just do not do it, seriously.

-- vamastah
