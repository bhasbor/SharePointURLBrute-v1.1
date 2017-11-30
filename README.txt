SharePointURLBrute - Version 1.1
===============
Authors: Fran Brown
Copyright © 2011 Stach & Liu LLC
http://www.stachliu.com
Release Date: 7/5/2011


LICENSE
===============
Copyright (C) 2011, Stach & Liu, LLC
All rights reserved.

Redistribution and use in binary form, with or without modification,
is permitted provided that the following conditions are met:

    * Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.

    * Neither the name of Stach & Liu, LLC nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

================================================================================

SharePointURLBrute is provided under the license above.

The copyright on this package is held by Stach & Liu, LLC.


USAGE
===============


        +===============================================================+
        |               SharePointURLBrute - Version 1.1                |
        |           SharePoint Admin URL Brute Force Utility            |
        |                 By: Fran "Danger" Brown                       |
        |        Stach & Liu, LLC - http://www.stachliu.com             |
        |               Copyright 2011 Stach & Liu LLC                  |
        +===============================================================+

        Description:    Takes list of SharePoint sites to test and attempts to forceful browse to
                        common administrative pages (e.g. "Add User" page -> "/_layouts/aclinv.aspx").

        Outputs: Default output files created: UrlsFound.txt, Debug.xt, and Errors.txt

        Usages: perl SharePointURLBrute.pl [-a SPSiteURL] [-e ExtUrlsList.txt] [-c "cookievaluestring"]
                perl SharePointURLBrute.pl [-i URLList.txt] [-e ExtUrlsList.txt] [-p "HTTPPROXY:PORT"]

        -a      [SharePoint_Site_URL]
                URL of SharePoint site to target. Can alternatively load file with
                list of URLs to test using the -i flag.

        -i      [SharePoint_URLList.txt]
                List of URLs to base SharePoint sites to be tested (e.g.
                http://www.myportal.com/). One URL per line.

        -e      [ExtUrlsList.txt]
                Text file with common SharePoint extensions to append to base url
                and attempt to forceful browse (e.g. /_layouts/viewlsts.aspx). Tool comes
                with file to be used with 89 common extensions: "SharePoint-UrlExtensionsv1.txt"

        -p      [HTTP_proxy]
                Optional, flag to cause scans to send all traffic through
                HTTP proxy.  Example input is "127.0.0.1:8080"

        -c      [Cookie_string_value]
                Optional, text string cookie value to be sent with each HTTP request.
                Useful for testing URL access of user after authentication.


        Examples:
        perl SharePointURLBrute.pl -a "http://myportal.com/" -e SharePoint-UrlExtensionsv1.txt
        perl SharePointURLBrute.pl -i MySPSites.txt -e SharePoint-UrlExtensionsv1.txt -p 127.0.0.1:8080



FEEDBACK
=================
Questions and suggestions can be sent to:	diggity@stachliu.com


PLANNED FEATURES
=================
- 


MORE INFO
=================
For more info, please visit:
- http://www.stachliu.com
- http://www.stachliu.com/index.php/resources/tools/sharepoint-hacking-diggity-project/
- http://www.stachliu.com/index.php/resources/tools/google-hacking-diggity-project/


CHANGELOG
=================
Version 1.1		[2011-07-05]

- Fixed "User-Agent" issue.