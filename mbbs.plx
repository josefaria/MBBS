#!/usr/bin/perl
## -----------------------------------------------------------------------------------------
##
## MBBS - Multi Backup Batch System
##
##  purpose: Make multiples backups and send an email with the results.
##           Only uses backups through tar and mysql
##           To configure fill an array with all targets to backup.
##           Each instruction is separated by ";"
## 
##           each line of this array is composed by:
##           <dir or files to backup>;
##           <middle name of the backup file>;
##           <type of backup: zip, tar, tar.bz2 or tar.gz>;
##           <target dir>: where to put the backup file;
##           <email to send the report>: <email_to>,<email_to>,...;<email_cc>,<email_cc>,...
##           <number of last logs to preserve>: ##
##           
##  using perl+sendmail/postfix+tar
##
##  version: 0.1 (2014)
##
##  Jose Luis Faria, jose@di.uminho.pt,joseluisfaria@gmail.com
##  Universidade do Minho, Braga, Portugal
##
##
## -----------------------------------------------------------------------------------------
use strict;
use warnings;
use Net::Domain qw(hostname hostfqdn hostdomain);
use File::Basename;


## -----------------------------------------------------------------------------------------
##
##  definitions all here!
##
## -----------------------------------------------------------------------------------------
my $email_from = "jose\@di.uminho.pt";
my $email_to = "jose\@di.uminho.pt";
my $email_cc = "";
my $mydir= dirname($0);

## list of files/dir to backup and for each source is composed by some elements:
my $file_of_sources = $mydir . "/list_of_backups.tsv";

# =0 do the work
# =1 print messages
# 
my $debuging=0;







## -----------------------------------------------------------------------------------------
##
##                      stop your definitions here !
##
## -----------------------------------------------------------------------------------------

my $version='0.1';
my $copyright1='Universidade do Minho - Braga';
my $copyright2='Portugal';
my @list_of_sources=();
my $i=0;
my $line='';
my $tool='';
my $parameters='';
my $source='';
my $prefix='';
my $type='';
my $target='';
my $email='';
my $number_backups='';
my @record=();
my @parcels=();
my @list_of_commands=();
my $command='';
my $command_tmp='';
my $ext='';
my $ext_tmp='';
my @result=();
my @files=();
my $last=0;
my $flag=0;
my $last_email_to ='';
my $last_email_cc ='';
my $error_message='';
my $hostfqdn = hostfqdn();
my $hostname = hostname();
my $message_contents = '';
my @month=qw.January February March April May June July August September October November December.;
my @dayofweek=qw.Sun Mon Tue Wed Thu Fri Sat Sun.;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
$year += 1900;
$min =sprintf("%02d",$min);
$hour =sprintf("%02d",$hour);
$mday =sprintf("%02d",$mday);
$mon =sprintf("%02d",$mon);



## -----------------------------------------------------------------------------------------
##
##
##   subroutines 
##
##
## 
## -----------------------------------------------------------------------------------------


sub send_email_report{
	my $from=$_[0];
	my $to=$_[1];
	my $cc=$_[2];
	my $message_contents=$_[3];

	# there is nothing to send
	if ($message_contents eq '') {
		return(0);
	}

	#
	# prepare report to send by email
	#
	# ---------------------------------------------------------------------------------------------------
	my @parcels=();
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
	$year += 1900;
	$min =sprintf("%02d",$min);
	$hour =sprintf("%02d",$hour);
	$mday =sprintf("%02d",$mday);
	$mon =sprintf("%02d",$mon);


	my $subject="Multi Backup Batch Report on ($dayofweek[$wday]) $month[$mon] $mday, $year at $hour:$min";

	open(MAIL,"|/usr/sbin/sendmail -t");

	## Mail Header
	print MAIL "From: $from\n";
	@parcels=split/,/, $to;
	foreach (@parcels) {
		print MAIL "To: $_\n";
	}
	@parcels=split/,/, $cc;
	foreach (@parcels) {
		print MAIL "Cc: $_\n";
	}
	print MAIL "Subject: $subject\n";
	print MAIL "Content-Type: text/html; charset=ISO-utf8\n\n";
	## Mail Body
	print MAIL "<html><head>\n";
	print MAIL "<style>\n";
	print MAIL "table.report {\n";
	print MAIL "  border: 1px solid #999999;\n";
	print MAIL "  border-collapse: collapse;\n";
	print MAIL "  font-family: verdana, courier;\n";
	print MAIL "  line-height: 12pt;\n";
	print MAIL "  font-size: 0.9em;\n";
	print MAIL "  font-weight: normal;\n";
	print MAIL "}\n";
	print MAIL "table.report th {\n";
	print MAIL "  border: 1px solid #000066;\n";
	print MAIL "  border: 1px solid #000066;\n";
	print MAIL "  text-align: center;\n";
	print MAIL "  background-color: #0d88bb;\n";
	print MAIL "  color: #ffffff;\n";
	print MAIL "  padding: 3px 5px 3px 3px;\n";
	print MAIL "  font-family: verdana, courier;\n";
	print MAIL "  font-size: 1.1em;\n";
	print MAIL "  font-weight: normal;\n";
	print MAIL "}\n";
	print MAIL "table.report th.minor {\n";
	print MAIL "  border: 1px solid #000066;\n";
	print MAIL "  text-align: center;\n";
	print MAIL "  background-color: #f0f1f2;\n";
	print MAIL "  color: #000000;\n";
	print MAIL "  font-size: 1.0em;\n";
	print MAIL "  font-weight: normal;\n";	
	print MAIL "}\n";	
	print MAIL "table.report td {\n";
	print MAIL "  border: 1px solid #000066;\n";
	print MAIL "  background-color: #ffffcc;\n";
	print MAIL "  vertical-align: top;\n";
	print MAIL "  font-family: courier, verdana;\n";
	print MAIL "}\n";
	print MAIL "table.report td.alarm {\n";
	print MAIL "	color: #FFFFFF;\n";
	print MAIL "}\n";
	print MAIL "table.report tr.alarm {\n";
	print MAIL "  background-color: #F88017;\n";
	print MAIL "}\n";
	print MAIL "</style>\n\n";
	print MAIL "</head><body>\n";

	# message
	print MAIL "<h3>host: $hostfqdn</h3>";
	print MAIL "<hr>";
	# corpo da mensagem
	print MAIL $message_contents;

	# message foot
	print MAIL "<br><br><br>\n";
	print MAIL "<hr>\n";
	print MAIL "mbbs-Multi Backup Batch System v. $version<br>\n";
	print MAIL "&copy; $copyright1<br>\n";
	print MAIL "$copyright2<br>\n";
	print MAIL "\n</body>\n</html>\n";
	close(MAIL);
}











## -----------------------------------------------------------------------------------------
##
##  let's do the work - work in progress
##
## -----------------------------------------------------------------------------------------

## ------------------------------------------------------------
##
## load the list of work to do
##
## ------------------------------------------------------------
if (-e $file_of_sources) {
	open(SOURCES,"<" . $file_of_sources);	
 } else {
	if ($email_to ne '') {
		$message_contents="I can't open the file [<b>$file_of_sources</b>]";
		send_email_report($email_from,$email_to,'','',$message_contents);
		exit(0);
	} else {
		die ("\n\nI can not open the file [$file_of_sources]\n\n");
	}
}

while (<SOURCES>) {
	if (! /^#/) {
		push(@list_of_sources,$_);
	}
}
if ($debuging==1) {
	foreach (@list_of_sources) {
		print $_ . "\n";
	}
}


foreach (@list_of_sources) {
	@list_of_commands=();
	$flag=0;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
	$year += 1900;
	$min =sprintf("%02d",$min);
	$hour =sprintf("%02d",$hour);
	$mday =sprintf("%02d",$mday);
	$mon =sprintf("%02d",$mon);

	$line = $_;
	@record=split /	/, $line;
	if (scalar(@record)==8) {
		$tool = $record[0];
		$parameters = $record[1];
		$source = $record[2];
		$prefix = $record[3];
		$type = $record[4];
		$target = $record[5];
		$email = $record[6];
		@parcels=split /;/, $email;
		if (@parcels>0) {
			$email_to=$parcels[0];
		}
		if (@parcels>1) {
			$email_cc=$parcels[1];
		}
		$number_backups = $record[7];
		if ($tool eq 'zip') {
			$command = "zip -r";
		} elsif ($tool eq 'tar') {
			$command = "tar";
		} elsif ($tool eq 'mysql') {
			$command = "mysql";
		} elsif ($tool eq 'mysqldump') {
			$command = "mysqldump";
		} else {
			$flag=1;
			$error_message = "tool not recognized!";
			$command='';
		}
		if ($type eq 'zip') {
			$parameters = "-r" . $parameters;
			$ext="zip";
		} elsif ($type eq 'tar') {
			$parameters = "-c" . $parameters . "f";
			$ext="tar";
		} elsif ($type eq 'tar.bz2') {
			$parameters = "-cj" . $parameters . "f";
			$ext="tar.bz2";
		} elsif ($type eq 'tar.gz') {
			$parameters = "-cz" . $parameters . "f";			
			$ext="tar.gz";
		} elsif ($type eq 'gz') {
			$parameters = "" . $parameters;			
			$ext="gz";			
		} elsif ($type eq 'sql') {
			$parameters = "" . $parameters;			
			$ext="sql";						
		} else {
			$flag=1;
			$error_message = "extension not identified.";			
			$command='';
			$ext="";
			$parameters = '';
		}
		if ((($tool eq 'mysql')||($tool eq 'mysqldump'))&&($ext eq 'gz')) {
			$ext_tmp = "sql";
			push(@list_of_commands,$command . " " . $parameters . " > " . $target . "/$year" ."$mon"."$mday"."_" . "$hour" . "h" . "$min" . "m" . "_$hostname" . "_$prefix" . ".$ext_tmp");
			push(@list_of_commands,"gzip -f " . $target . "/$year" ."$mon"."$mday"."_" . "$hour" . "h" . "$min" . "m" . "_$hostname" . "_$prefix" . ".$ext_tmp");
			$ext = "$ext_tmp.$ext";
		} else {
			push(@list_of_commands, $command . " " . $parameters . " " . $target . "/$year" ."$mon"."$mday"."_" . "$hour" . "h" . "$min" . "m" . "_$hostname" . "_$prefix" . ".$ext" . " " . $source);
		}
		$message_contents .= "<table class=\"report\">\n";
		$message_contents .= "<tr><th>source</th><th>target</th><th>executed</th><th>messages</th></tr>\n";
		foreach (@list_of_commands) {
			$message_contents .= "<tr><td>$source</td><td>$target</td>";
			$command = $_;
			#print $command . "\n";
			@result = `$command 2>&1`;	
			$command_tmp = $command;
			$command_tmp=~ s/--password=(.*) /--password=XXXXXXXX /g;
			$message_contents .= "<td>$command_tmp</td>";	
			$message_contents .= "<td>";
			foreach (@result) {
				$message_contents .= "$_<br>";
			}
			$message_contents .= "</td></tr>\n";
		}		
		# -------------------------
		#delete old files preserve only the last <number_of_files>
		# -------------------------
		if ($number_backups>0) {
			@files = glob($target . "/*_$hostname" . "_$prefix.$ext");
			#sort @files;
			$last=@files;
			if ($last>$number_backups) {
				$message_contents .= "<tr><th colspan=\"2\" class=\"minor\">deleted files</th><th colspan=\"2\" class=\"minor\">preserved files</th></tr>\n";
				$message_contents .= "<tr><td colspan=\"2\">";
				if (($last-$number_backups)>=0) {
					for($i=0;$i<($last-$number_backups);$i++) {
						$command = "rm -f " . $files[$i];
						@result=`$command`;
						$files[$i] =~ s/$target\///g;
						$message_contents .= $files[$i] . "(";
						foreach (@result) {
							$message_contents .= "$_<br>";
						}
						if (scalar(@result)==0) {
							$message_contents .= "<i>ok</i>";	
						}
						$message_contents .= ")<br>";
					}
				}
				$message_contents .= "</td>";
				$message_contents .= "<td colspan=\"2\">";
				if (($last-$number_backups)<$last) {
					for($i=($last-$number_backups);$i<$last;$i++) {
						$files[$i] =~ s/$target\///g;
						$message_contents .= $files[$i] . "<br>";
					}	
				}
				$message_contents .= "</td></tr>\n";
			} else {
				$message_contents .= "<tr><td colspan=\"4\"></td></tr>\n";		
			}
		} else {
			$message_contents .= "<tr><td colspan=\"4\"></td></tr>\n";
		}
		$message_contents .= "</tr>\n";
		$message_contents .= "</table>\n";
		$message_contents .= "<br>\n";
	} else {
		$flag=1;
		$error_message = "I need at least 8 parameters in this line";
		$email_to='';
		if ($email_to ne '') {
			$message_contents .= "<table class=\"report\">\n";
			$message_contents .= "<tr><th>line of backup</th><th>error message</th></tr>\n";
			$message_contents .= "<tr>$line<td>$error_message</td></tr>\n";
			$message_contents .= "</table>\n";
		} else {
			print "\nline->$line\n$error_message\n";
		}
	}
	if (($email_to ne $last_email_to)||($last_email_cc ne $last_email_cc)) {
		send_email_report($email_from,$email_to,$email_cc,$message_contents);
		$message_contents='';
		$last_email_to=$email_to;
		$last_email_cc=$email_cc;
	}
}


## ------------------------------------------------------------
##
##  send the report 
##
##
## ------------------------------------------------------------

if (($email_to ne '')||($email_cc ne '')) {
		send_email_report($email_from,$email_to,$email_cc,$message_contents);
} elsif ($message_contents ne '') {
	print "\n\n$message_contents\n\n";
}


## ------------------------------------------------------------
##
##       the end
##
## ------------------------------------------------------------

