#!/usr/bin/env bash
# Usage: DKIM_SELECTOR=default ./dns_mail_audit.sh domains.txt > audit.csv
set -uo pipefail
FILE="${1:?usage: $0 domains.txt}"
SEL="${DKIM_SELECTOR:-default}"
DIG="dig +time=3 +tries=1"

yn() { if [[ -n "${1:-}" ]]; then echo yes; else echo no; fi; }

echo "domain,ns_count,dnssec,spf,dmarc_policy,dkim,mx,caa,mta_sts,axfr_open"

while IFS= read -r d; do
  [[ -z "$d" || "$d" == \#* ]] && continue

  ns="$($DIG +short NS "$d" | sort -u)"
  ns_count="$(grep -c . <<<"$ns" || true)"

  dnssec="$(yn "$($DIG +short DS "$d")")"
  spf="$(yn "$($DIG +short TXT "$d" | grep -i 'v=spf1')")"

  dmarc_rec="$($DIG +short TXT "_dmarc.$d" | grep -i 'v=DMARC1' || true)"
  policy="none-found"
  if [[ -n "$dmarc_rec" ]]; then
    policy="$(grep -oiE 'p=[a-z]+' <<<"$dmarc_rec" | head -1 | cut -d= -f2 | tr 'A-Z' 'a-z')"
    policy="${policy:-unknown}"
  fi

  dkim="$(yn "$($DIG +short TXT "${SEL}._domainkey.$d" | grep -iE 'v=DKIM1|p=')")"
  mx="$(yn "$($DIG +short MX "$d")")"
  caa="$(yn "$($DIG +short CAA "$d")")"
  mta="$(yn "$($DIG +short TXT "_mta-sts.$d" | grep -i 'v=STSv1')")"

  axfr="no"
  for n in $ns; do
    if [[ -n "$($DIG +noall +answer AXFR "$d" @"$n" 2>/dev/null)" ]]; then axfr="YES:$n"; break; fi
  done

  echo "$d,$ns_count,$dnssec,$spf,$policy,$dkim,$mx,$caa,$mta,$axfr"
done < "$FILE"
