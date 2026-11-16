# DNS & Mail Security Audit

**Language versions:** [Deutsch](README_DE.md)

Bulk check of many domains, CSV output. Born from running DNS for ~250 domains on [isol.cz](https://www.isol.cz).

## Checks per domain
- Number of NS records
- DNSSEC (DS record at the parent)
- SPF (`v=spf1`), DMARC (`_dmarc`, policy `p=`), DKIM (one selector, default `default`)
- MX present, CAA present, MTA-STS record present
- **Open zone transfer (AXFR)** against each authoritative NS

## Usage
```bash
sudo apt install bind9-dnsutils
printf 'example.com\nexample.org\n' > domains.txt
DKIM_SELECTOR=default ./scripts/dns_mail_audit.sh domains.txt > audit.csv
./scripts/summarize_audit.sh audit.csv     # aggregate coverage, no domain names
```
Only test domains you own or are authorised to test. The AXFR check sends a transfer request to the domain's name servers.

## Limits
Checks one DKIM selector per run, does not validate SPF lookup limits or DNSSEC chain correctness (use `delv` / dnsviz.net for that), and does not check DANE/TLSA.
