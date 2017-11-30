##############################
# ENABLE MODULES
##############################
use LWP::UserAgent;
use HTTP::Response;
use HTML::LinkExtor;
use Getopt::Std;
use Text::ParseWords;

########################################################
# CHECK FOR SUFFICIENT NUMBER OF COMMAND LINE ARGUMENTS
########################################################
if ( !( (scalar(@ARGV) == 4) or (scalar(@ARGV) == 6) or (scalar(@ARGV) == 8) )) { die "


	+===============================================================+
	|               SharePointURLBrute - Version 1.1                |
	|           SharePoint Admin URL Brute Force Utility            |
	|                 By: Fran \"Danger\" Brown                       |
	|        Stach & Liu, LLC - http://www.stachliu.com             |
	|               Copyright 2011 Stach & Liu LLC                  |
	+===============================================================+

	Description:	Takes list of SharePoint sites to test and attempts to forceful browse to
			common administrative pages (e.g. \"Add User\" page -> \"/_layouts/aclinv.aspx\").

	Outputs: Default output files created: UrlsFound.txt, Debug.xt, and Errors.txt

	Usages: perl SharePointURLBrute.pl [-a SPSiteURL] [-e ExtUrlsList.txt] [-c \"cookievaluestring\"]
		perl SharePointURLBrute.pl [-i URLList.txt] [-e ExtUrlsList.txt] [-p \"HTTPPROXY:PORT\"]

	-a	[SharePoint_Site_URL]
		URL of SharePoint site to target. Can alternatively load file with
		list of URLs to test using the -i flag.

	-i	[SharePoint_URLList.txt]
		List of URLs to base SharePoint sites to be tested (e.g. 
		http://www.myportal.com/). One URL per line.

	-e	[ExtUrlsList.txt]
		Text file with common SharePoint extensions to append to base url 
		and attempt to forceful browse (e.g. /_layouts/viewlsts.aspx). Tool comes
		with file to be used with 89 common extensions: \"SharePoint-UrlExtensionsv1.txt\"

	-p	[HTTP_proxy]
		Optional, flag to cause scans to send all traffic through 
		HTTP proxy.  Example input is \"127.0.0.1:8080\"
	
	-c	[Cookie_string_value]
		Optional, text string cookie value to be sent with each HTTP request.
		Useful for testing URL access of user after authentication.
			

	Examples:
	perl SharePointURLBrute.pl -a \"http://myportal.com/\" -e SharePoint-UrlExtensionsv1.txt
	perl SharePointURLBrute.pl -i MySPSites.txt -e SharePoint-UrlExtensionsv1.txt -p 127.0.0.1:8080


";}


###############################
# GATHER ARGUMENTS
###############################
	$appUrl = "";
	$appList = "";
	$extList = "";
	$proxyToUse = "";
	$cookieValue = "";
	$scan_type = "";	# Either a or i, depending on using URL or URLlist.txt

	$errorCount = 0;
	$totalUrlsFound = 0;

	
	# Set UserAgent
	$userAgent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)';
	
	
	# Process input flags
	&process_cmd_line();	# Take in command arguments and initialize certain variables accordingly
	
		
####################################
# OPEN FILES FOR WRITING
####################################

$| = 1;	# Set outputs to auto-flush

open (OUTPUT, ">UrlsFound.txt") or die "Could not open output file.\n";
open (DEBUG, ">Debug.txt") or die "Could not open output file. $!\n";
open (ERRORS, ">Errors.txt") or die "Could not open output file. $!\n";



#open (CONTENT, ">content.txt") or die "Could not open output file. $!\n";

###############################
########## MAIN ###############
###############################


############################################
# Console print
print "\n\nStarting search for common SharePoint Pages\n";
$tm = localtime;
print OUTPUT "Starting SharePointURLBrute: $tm\n\n";
print "Start Time: $tm\n\n";


############################################
# Create User Agent for making HTTP GET requests
my $ua = LWP::UserAgent->new();
$ua->agent($userAgent); # Set User Agent to acceptable string for Google to avoid error.
#$ua->default_header('Referer' => 'http://www.google.com/m?source=android-home&client=ms-android-verizon');
#$ua->proxy('http', 'http://127.0.0.1:8080/'); #Definitely works
$ua->timeout(80); # Change default timeout from 180sec (3 minutes) to just 4 seconds
$ua->max_redirect(0); # stop from redirecting

# Set HTTP proxy if specified
if ( $proxyToUse ne "" ) {
	$ua->proxy('http', $proxyToUse);
}

# Set HTTP cookie Value if specified
if ( $cookieValue ne "" ) {
	$ua->default_header('Cookie' => $cookieValue);
}
	

############################################
# Try each extension against each app in -i file or against single -a URL

if ( $scan_type eq 'a' ){
	# Runs tryEachExt subroutine against single app url
	&try_each_ext(); #Try each extension appended to current URL being targeted
}elsif ( $scan_type eq 'i' ){
	foreach my $line (<URLLIST>) {
		chomp $line;	#get rid of newline character
		
		# Check for last character being a "/", and remove if so
		$lastchar = substr $line,-1,1;
		if ($lastchar =~ '/') {
			chop($line);	# Example: would turn http://whateva/ into http://whateva
		}
	
		# Set appURL to current line
		$appUrl = $line;
		
		# Call tryEachExt subroutine for current appUrl
		&try_each_ext();		
	}
} else {
	print "\n\nERROR: Something went wrong with main target URL inputs.\n";
	exit;
}



############################################
# Close out

print "\n\nSearch Complete\n";
print "Total # of SP Admin URLs Found: $totalUrlsFound\n";

$tm = localtime;
print OUTPUT "\n\nFinished SharePointURLBrute: $tm\n";
print "Finish Time: $tm\n\n";

close(OUTPUT);
close(DEBUG);
close(ERRORS);
close(EXTLIST);

if ($scan_type eq 'i') {
	close(URLLIST); # Close input URL list if one was used
}

exit;	# Finished


##############################################################################################
##################################### SUBROUTINES ############################################
##############################################################################################

sub process_cmd_line()
{
	# Grab Flags and their respective values from the command line.
	getopt('aiepc');
	
	# Ensure that either the -a or -i flag is set, but NOT both
	if ( !((defined ($opt_a)) xor (defined ($opt_i)) ) ) {
		print "\n\t\tERROR: Must specify either the -a or -i flag. Not both.\n";
		exit;
	}
	
	# The -e flag is required
	if ( !( defined $opt_e ) ) {
		print "\n\t\tERROR: Must specify the -e flag\n";
		exit;
	} else {
		open (EXTLIST, "<$opt_e") or die "Could not open input file: $opt_e. $!\n";
		@exts = <EXTLIST>;
	}
		
	# At this point we know the user has specified required inputs.
	# Now open the input file for reading:
	if (defined $opt_a){
		$scan_type = 'a';
		$appUrl = $opt_a;
		
		chomp $appUrl;	#get rid of newline character
	
		# Check for last character being a "/", and remove if so
		$lastchar = substr $appUrl,-1,1;
		if ($lastchar =~ '/') {
			chop($appUrl);	# Example: would turn http://whateva/ into http://whateva
		}		
	}elsif (defined $opt_i){
		# Input will be txt file list of URLs to test
		$scan_type = 'i';
		open (URLLIST, "<$opt_i") or die "Could not open input file: $opt_i. $!\n";
	}
	
	
	# Process optional input flags
	# HTTP Proxy set
	if ( defined $opt_p) {
		$proxyToUse = 'http://' . $opt_p . '/';
	}
	
	# HTTP request cookie txt value set
	if ( defined $opt_c) {
		$cookieValue = $opt_c;
	}
		
}

##############################################################################################
sub try_each_ext() {

	foreach my $ext (@exts) {
		
		chomp $ext;
		
		my $url = $appUrl . $ext;
		#$url = $appUrl;
		
		my $response = $ua->get($url);
		my $content = $response->content;
		my $status = $response->status_line;
		
		#Debug - print content
		#print CONTENT "$content";
		
		# DEBUG - Check HTTP Response Code
		print DEBUG "$url\t$status\n";
		
		# ERROR - Error checking, check for non 200
		if ( ($status =~ '200') && ($content !~ 'not found') && ($status !~ '302') && ($status !~ '404') && ($status !~ '400') ) {
			print OUTPUT "$url\n";
			print "FOUND: $url\n";
			$totalUrlsFound++;
		} else {
			print ERRORS "$url\t$status\n";
			$errorCount++;		
			#next; #skip to next app in list to test, this one isnt vulnerable.			
		} 
	}


}

