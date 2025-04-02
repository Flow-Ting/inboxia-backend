#!/usr/bin/env node

const dns = require('dns').promises;

async function checkSPF(domain) {
  try {
    const records = await dns.resolveTxt(domain);
    const flattened = records.map(r => r.join(''));
    const spfRecord = flattened.find(r => r.toLowerCase().startsWith("v=spf1"));
    if (spfRecord) {
      console.log(`SPF record for ${domain}: ${spfRecord}`);
    } else {
      console.log(`No SPF record found for ${domain}`);
    }
  } catch (error) {
    console.error(`Error fetching SPF record for ${domain}: ${error.message}`);
  }
}

async function checkDMARC(domain) {
  try {
    const dmarcDomain = `_dmarc.${domain}`;
    const records = await dns.resolveTxt(dmarcDomain);
    const flattened = records.map(r => r.join(''));
    const dmarcRecord = flattened.find(r => r.toLowerCase().startsWith("v=dmarc1"));
    if (dmarcRecord) {
      console.log(`DMARC record for ${domain}: ${dmarcRecord}`);
    } else {
      console.log(`No DMARC record found for ${domain}`);
    }
  } catch (error) {
    console.error(`Error fetching DMARC record for ${domain}: ${error.message}`);
  }
}

async function checkDKIM(domain, selector = "default") {
  try {
    const dkimDomain = `${selector}._domainkey.${domain}`;
    const records = await dns.resolveTxt(dkimDomain);
    const flattened = records.map(r => r.join(''));
    if (flattened.length > 0) {
      console.log(`DKIM record for ${dkimDomain}: ${flattened.join("; ")}`);
    } else {
      console.log(`No DKIM record found for ${dkimDomain}`);
    }
  } catch (error) {
    console.error(`Error fetching DKIM record for ${domain} with selector '${selector}': ${error.message}`);
  }
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length < 1) {
    console.error("Usage: domain_verification.js <domain> [selector]");
    process.exit(1);
  }
  const domain = args[0];
  const selector = args[1] || "default";

  console.log(`\nChecking DNS records for domain: ${domain}`);
  await checkSPF(domain);
  await checkDMARC(domain);
  await checkDKIM(domain, selector);
}

main();

