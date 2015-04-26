#!/usr/bin/perl

# smsparser.pl, Copyright (c) 2010, Jussi-Pekka Erkkila <juerkkil@iki.fi>
#
# Reads SMS messages from sim card ands saves those in filesystem.
# SMS messages will be deleted from SIM card after reading and saving.
# Uses freesmartphone.org API and assumes that GSM resource is enabled and 
# SIM card is accessible.
# Usage:
# perl smsparser.pl type
# where type is 'unread', 'read', 'sent', or 'all'

use Digest::MD5  qw(md5 md5_hex md5_base64);

my $type = $ARGV[0];

use strict;
use warnings;
system("dbus-send --system --print-reply --dest=org.freesmartphone.ogsmd /org/freesmartphone/GSM/Device org.freesmartphone.GSM.SIM.RetrieveMessagebook 'string:$type' > /tmp/arrived_msgs");

open my $msgs, "/tmp/arrived_msgs" or die("fail!");
my $state = 0;
my $hash;
my $newmsg;
my $number ="";
my $msg ="";
my $msgnum = 0;
my $timestamp = "unknown";
for(<$msgs>) {
  if($_ =~ m/struct \{/) {
    $state = 1;
  }
  if($state == 1) {
    if($_ =~ m/int32 ([0-9]+)/) {
      system("dbus-send --system --dest=org.freesmartphone.ogsmd /org/freesmartphone/GSM/Device org.freesmartphone.GSM.SIM.DeleteMessage 'string:".$1."'"); # keep sim card empty of messages   
      $state = 2;
    }
  }
  if($state == 2) {
    if($_ =~ m/string \"(read|unread|sent)\"/) {
      $state = 3;
      next;
    }
  }
  if($state == 3) {
    if($_ =~ m/string \"(\+[0-9]{9,})\"/) {
      $number = $1;
      $state = 4;
      next;
    }
  }
  if($state == 4) {
    if($_ =~ m/string \"(.*)\"/) {
       $msg = $1;
       $state = 5;
    }
  }
  if($state == 5) {
    if($_ =~ m/string \"timestamp\"/) {
      $state = 6; 
      next;
    }
  }
  if($state == 6) {
    if($_ =~ m/variant[^s\n]+string \"(.*)\"/) {
      $timestamp = convert_time($1);
      $state = 7;
    }
  }
  if($state == 7) {
    $newmsg = $number."\n".$timestamp."\n".$msg."\n";
    $hash = md5_hex($newmsg);
    open my $newfile, '>', "<destination_directory>/".$hash.".msg" or die("failed to write message");
    print $newfile $newmsg;
    close $newfile;
    $newmsg = "";
    $state = 0;
  }
}
 
      
# system("rm /tmp/arrived_msgs");

sub convert_time {
  my $date1 = shift;
  my @arr = split(/ /, $date1);
  my $m = month2num($arr[1]);
  my $d = $arr[2];
  my $time; my $y;
  if($d eq "" ) {
    $d = $arr[3];
    $time = $arr[4];
    $y = $arr[5];
  } else {
    $time = $arr[3];
    $y = $arr[4];
  }
  if(length($d) == 1) {
	  $d = "0".$d;
  }
  return  $y."-".$m."-".$d." ".$time;
}


sub month2num {
  my $a = shift;
  if($a eq "Jan") { return "01"; }
  if($a eq "Feb") { return "02"; }
  if($a eq "Mar") { return "03"; }
  if($a eq "Apr") { return "04"; }
  if($a eq "May") { return "05"; }
  if($a eq "Jun") { return "06"; }
  if($a eq "Jul") { return "07"; }
  if($a eq "Aug") { return "08"; }
  if($a eq "Sep") { return "09"; }
  if($a eq "Oct") { return "10"; }
  if($a eq "Nov") { return "11"; }
  if($a eq "Dec") { return "12"; }
  return -1;
}

