#!/usr/bin/env bash
# Aggregate coverage from dns_mail_audit.sh output (no domain names in the result).
# Usage: ./summarize_audit.sh audit.csv
set -euo pipefail
f="${1:?usage: $0 audit.csv}"
awk -F, '
NR>1 && $1!="" {
  n++
  if ($3=="yes") dnssec++
  if ($4=="yes") spf++
  if ($5!="none-found") dmarc++
  if ($5=="quarantine" || $5=="reject") enforced++
  if ($6=="yes") dkim++
  if ($7=="yes") mx++
  if ($8=="yes") caa++
  if ($9=="yes") mta++
  if ($10 ~ /^YES/) axfr++
}
function line(name, v) { printf "%-34s %5d  (%3.0f%%)\n", name, v, 100*v/n }
END {
  if (n==0) { print "no data"; exit 1 }
  printf "%-34s %5d\n", "domains checked", n
  line("DNSSEC (DS at parent)", dnssec)
  line("SPF", spf)
  line("DKIM (selected selector)", dkim)
  line("DMARC present", dmarc)
  line("DMARC enforced", enforced)
  line("MX present", mx)
  line("CAA", caa)
  line("MTA-STS", mta)
  line("open AXFR", axfr)
}' "$f"
