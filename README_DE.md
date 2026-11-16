# DNS- & Mail-Sicherheitsaudit

**Sprachversionen:** [English](README.md)

Massenprüfung vieler Domains mit CSV-Ausgabe. Entstanden beim Betrieb von DNS für 240+ Domains auf [isol.cz](https://www.isol.cz).

## Prüfungen pro Domain
- Anzahl der NS-Einträge
- DNSSEC (DS-Eintrag bei der Parent-Zone)
- SPF (`v=spf1`), DMARC (`_dmarc`, Policy `p=`), DKIM (ein Selector, Standard `default`)
- MX vorhanden, CAA vorhanden, MTA-STS-Eintrag vorhanden
- **Offener Zonentransfer (AXFR)** gegen jeden autoritativen NS

## Verwendung
```bash
sudo apt install bind9-dnsutils
printf 'example.com\nexample.org\n' > domains.txt
DKIM_SELECTOR=default ./scripts/dns_mail_audit.sh domains.txt > audit.csv
./scripts/summarize_audit.sh audit.csv     # aggregate coverage, no domain names
```
Nur Domains testen, die Ihnen gehören oder für die Sie autorisiert sind. Die AXFR-Prüfung sendet eine Transferanfrage an die Nameserver der Domain.

## Grenzen
Prüft einen DKIM-Selector pro Lauf, validiert weder SPF-Lookup-Limits noch die DNSSEC-Kette (dafür `delv` / dnsviz.net) und prüft kein DANE/TLSA.
