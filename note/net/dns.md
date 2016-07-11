DNS(Domain Name System/Service/Server)
  A network service that translates the "names" into IP address.
  2 kinds of names:Domain Names, Host Names
Domain Names: .com, yahoo and etc.
Host Names: VWP-RM2026, YahooWeb1 and etc.

Host(includes workstation, router, printer and so on) has host name and IP address.
1. Host Lookup Table(1971-2), /etc/hosts in Linux, %system%\etc\hosts in Windows.
2. 1st DNS(1985)
resolve the names by lookup the Host Lookup Table, then lookup by DNS if fail.

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

Primary Zone
Secondary Zone
Active Directory Integrated Zone
Stub Zone
Reverse Look Up Zone

## DNS Levels
Root Server, ".". there are 13 Root Servers in the world.
Top Level Domain(TLD) servers, such as ".com"
Domain Servers, such as "example"
Forwarders, such as "www"

Root Server knows the Top Level Domain Servers but no Domain Servers.

FQDN(Fully Qualified Domain Name), such as "www.example.com."


  when types `ping www.example.com` in shellor cmd, it would append a root domain name `it would append a root domain name `.` at the end of the domain name, then `www.example.com.` as the result.

ISP would give default Domain Name Servers to you.

Resolving Name Server
Root Name Server
TLD Name Server
Authoratative Name Server

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
