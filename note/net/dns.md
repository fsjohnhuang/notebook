DNS(Domain Name System)
  A network service that translates the "names" into IP address.
  2 kinds of names:Domain Names, Host Names
Domain Names: .com, yahoo and etc.
Host Names: VWP-RM2026, YahooWeb1 and etc.

Host(includes workstation, router, printer and so on) has host name and IP address.
1. Host Lookup Table(1971-2), /etc/hosts in Linux, %system%\etc\hosts in Windows.
2. 1st DNS(1985)
resolve the names by lookup the Host Lookup Table, then lookup by DNS if fail.

## DNS Zones
1. Portion of the DNS name space
2. Contains DNS records

Master/Primary Zone
stored in text file
1. contains read/write zone data
2. primary zone(text) stored on one DNS server only
3. changes can only be made on the primary zone

Slave/Secondary Zone
1. Read only copy of zone data
2. sync the copy of zone data from master zone
2. change requests passed on to primary zone
3. does not require DNS Server to be under the Domain Controller
4. Supported on non-Microsoft DNS
5. Keeps complete copy of another zone

Active Directory Integrated Zone
A primary zone stored in Active Directory
1. uses same replication system as Active Directory
2. change can be made on multiple servers
3. DNS must be installed on a Domain Controller
4. Allows secure dynamic updates

Stub Zone
1. sync the NS type records from master zone
   only records to find an authoritative server

Reverse Look Up Zone
1. contains IP address to host mapping

Hint




Zone Files
  when receive a "Name Resolution" request, the DNS server consults it's zone files for IP Address.
  DNS is a distrubute database which is made of Zone Files.
  Zone File consisted of records.

  mapping domain name "example.com" to a zone file which's name is example.com.zone or other else. and there is a record like below
the name of record is "www", the type is "A", then the IP Address is 10.12.1.253 or something like this. then the FQDN(fully qualified domain name) of this record is "www.example.com.". and the resolution of "www.example.com." would hit that record.

  the kinds of record:
    SOA(Start of Authority),
    NS(Name Server), Authoritive DNS Server
    A(A Record), Name to IP Address
    MX(Mail Exchange),
    CNAME(Canonical Name), Name to another name
    SRV(Service Record)
    PTR


## DNS Levels/Name Space
Root Domain, ".". there are 13 Root Servers in the world.
Top Level Domain(TLD), such as ".com", ".net", ".au" etc.
Second Level Domain, such as "example"
Forwarders(Third/Fourth Level Domain), such as "www"

Root Server knows the Top Level Domain Servers but no Domain Servers.

FQDN(Fully Qualified Domain Name), such as "www.example.com."

  when types `ping www.example.com` in shellor cmd, it would append a root domain name `it would append a root domain name `.` at the end of the domain name, then `www.example.com.` as the result.

### The Process of Resolving FQDN
1. type `ping fsjohnhuang.com` in shell or cmd;
2. ask the default DNS Server for IP Address mapping to `fsjohnhuang.cnblogs.com`;
3. the default DNS Server search the record from it's cache, if hit go to step 7, otherwise go to step 4;
4. the default DNS Server contacts the Root Hint Servers, then the Root Hint Server return the IP Address of `.com` DNS Servers;(the default DNS Server has default configured Root Hints which is configurable)
5. the default DNS Server contacts the `.com` DNS Servers to get the IP Address of `fsjohnhuang` DNS Servers;
6. the default DNS Server contacts the `fsjohnhuang` DNS Servers to get the IP Address of the `fsjohnhuang.com` server, and put them into cache;
7. return the IP Address to the client.

ISP would config default DNS Servers for you. So the most efficent way is to forward DNS reqest to ISP.
if the default DNS Server know the IP Address of another DNS Server(e.g. .com DNS Server), it don't need to ask the Root Hint Server.

### DNS Recursive and Iterative Queries


Resolving Name Server
Root Name Server
TLD Name Server
Authoritative Name Server

the length of each level domain is limited in 63 characters, and the total is no greater than 253 characters.the characters is in the subset of ASCII, but IDNA system converts the Unicode characters to ASCII by punycode encoding.
the deep of domain is no greater than 5. and case insensitive.


DNS is base on TCP and UDP with port 53

find the owner of domain by WHOIS

top-level domain(TLD), the first-level domain includs generic top-level domains(gTLDs) and country code top-level domains(ccTLDs)
  gTLDs, e.g. com,org,gov,edu,mil,net
  owner is ICANN
  ccTLDs, e.g. hk,cn,uk,jp
base domain, the second-level domain
superdomain
  midea.com is the superdomain of www.midea.com.
subdomain
  www.midea.com is the subdomain of midea.com.
domain name is consist of labels and dots.(e.g. midea.com is consist of labels midea and com)

hostname, is a domain name that has at least one IP address.
n-level domain(e.g. first-level or second-level domain) refers the specific label of domain name.
the second-level domain of www.midea.com is midea, but the third-level domain is www.

DNS(Domain Name System) record, tells you how to use the domain name.
Kinds of DNS records
  A-record, is used when accesses website.
  MX record, is used when delivers mail.
  TXT record, is used to verify domain name ownership.

## REF
(Understanding DNS Part1)[https://www.youtube.com/watch?v=Hk0FjTIxSrI]
(DNS Zones)[https://www.youtube.com/watch?v=833Qnc-7-ug]
(DNS zone)[https://en.wikipedia.org/wiki/DNS_zone]
(DNS Namespace)[https://www.youtube.com/watch?v=7fJwSLo65wo&index=5&list=PL1l78n6W8zypWeqTvo2tKxFSzIQQVtTyq]
