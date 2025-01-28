# Renaming your Azure domain
## Index
* [Overview](#overview)
* [Important to note](#important-to-note)
* [Adding a custom domain](#1-add-the-custom-domain-name)
* [Add DNS information](#2-add-the-dns-information-to-the-domain-registrar)
* [Verify your domain](#3-verify-your-custom-domain-name)
* [Common verification issues](#common-verification-issues)

## Overview
When creating your Azure tenant, a default domain will be created in the format of *contoso.onmicrosoft.com* which is your initial domain.

Unfortunately it is not possible to change or delete the initial .onmicrosoft.com domain created for the tenant. However, it is possible to add custom domains, and even set this as the primary or default domain!

## Important to note!
Before you can add a custom domain name, you should create a domain name with a domain registrar. For an accrediterd domain registrar, see [this list](https://www.icann.org/registrar-reports/accredited-list.html).

You can add up to 5000 managed domain names. If you're configuring all your domains for federation with on-premises Active Directory, you can add up to 2,500 domain names in each organization.

If you want to add a subdomain name such as ‘europe.contoso.com’ to your organization, you should first add and verify the root domain, such as contoso.com. Microsoft Entra ID automatically verifies the subdomain. To see that the subdomain you added is verified, refresh the domain list in the browser.

If you have already added a contoso.com domain to one Microsoft Entra organization, you can also verify the subdomain europe.contoso.com in a different Microsoft Entra organization. When adding the subdomain, you are prompted to add a TXT record in the Domain Name Server (DNS) hosting provider.

##  1. Add the custom domain name
1. Sign in to the Microsoft Entra admin center as at least a Domain Name Administrator.
2. Browse to **Identity** > **Settings** > **Domain names** > **Add custom domain**.
3. In **Custom domain name**, enter your organization's domain, f.e. contoso.com. Select **Add domain**. (Note that you must include your top level extension for this to work!)
4. The unverified domain is added. The contoso.com page appears showing the DNS information needed to validate your domain ownership. Save this information.

## 2. Add the dns information to the domain registrar
1. After you add your custom domain name, you must return to your domain registrar and add the DNS information from your copied from the previous step. Creating this TXT or MX record for your domain verifies ownership of your domain name.
2. Go back to your domain registrar and create a new TXT or MX record for your domain based on your copied DNS information. Set the time to live (TTL) to 3600 seconds (60 minutes), and then save the record.

## 3. Verify your custom domain name
1. Sign in to the Microsoft Entra admin center as at least a Domain Name Administrator.
2. Browse to **Identity** > **Settings** > **Domain names**.
3. In **Custom domain names**, select the custom domain name. f.e. select contoso.com.
4. On the **contoso.com** page, select **Verify** to make sure your custom domain is properly registered and is valid.

## Common verification issues
If you can't verify a custom domain name, try the following suggestions:

1. **Wait at least an hour and try again**. DNS records must propagate before you can verify the domain. This process can take an hour or more.
2. **Make sure the DNS record is correct**. Go back to the domain name registrar site. Make sure the entry is there, and that it matches the DNS entry information provided in the Microsoft Entra admin center.
 * If you can't update the record on the registrar site, share the entry with someone who has permissions to add the entry and verify it's correct.
3. **Make sure the domain name isn't already in use in another directory**. A domain name can only be verified in one directory. If your domain name is currently verified in another directory, it can't also be verified in the new directory. To fix this duplication problem, you must delete the domain name from the old directory. For more information about deleting domain names, see Manage custom domain names.
4. **Make sure you don't have any unmanaged Power BI tenants**. If your users have activated Power BI through self-service sign-up and created an unmanaged tenant for your organization, you must take over management as an internal or external admin, using PowerShell. For more information, see Take over an unmanaged directory.

## 4. Change the Entra AD primary domain
1. Sign in to the Azure portal with an account that's a Global Administrator for the organization.
2. Select **Microsoft Entra ID**.
3. Select **Custom domain names**.
4. Select the name of the domain that you want to be the primary domain.
5. Select the **Make primary** command. Confirm your choice when prompted.

You can change the primary domain name for your organization to be any verified custom domain that isn't federated. Changing the primary domain for your organization doesn't change the user name for any existing users.