Documentation for Changing Domain name for DAL
==============================================

This document is about how to change the domain name for DAL from example.com in RedHat 7 based distribution. It is based on work required to change DAL URL from kddart.example.com to kd.production-example.com.

Step-by-step Instructions
-------------------------

1. Change kddart.example.com to kd.production-example.com in /etc/hosts

2. Rename directory kddart.example.com in /var/www/vhosts to kd.production-example.com

3. Rename DAL apache configuration file in /etc/httpd/conf.d from http-kddart.example.com.conf to http-kd.production-example.com.conf

4. Edit /etc/httpd/conf.d/http-kd.production-example.com.conf by:

   * Replacing kddart.example.com with kd.production-example.com. There are 8 matches.

   * Changing ServerAdmin apache configuration directive from webmaster@example.com to the correct webmaster email address.

   * Changing line 59 from "PerlSetVar KDDArTDomain .example.com" to "PerlSetVar KDDArTDomain .production-example.com"

   * Changing line 86 from "SetEnvIf Origin ^(https?://.+\.example.com(?::\d{1,5})?)$ CORS_ALLOW_ORIGIN=$1" to "SetEnvIf Origin ^(https?://.+\.production-example.com(?::\d{1,5})?)$ CORS_ALLOW_ORIGIN=$1"

5. Edit /var/www/secure/kddart_dal.cfg by:

   * Replacing kddart.example.com with kd.production-example.com

   * Replacing ".example.com" in line 2 with ".production-example.com"

6. As root, run command "crontab -e", replace kddart.example.com with kd.production-example.com and save the change.

7. Restart httpd service.
