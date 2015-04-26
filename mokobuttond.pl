#!/usr/bin/perl

# mokobuttond.pl - perl daemon for handling openmoko gta02 button events
# (c) 2009-2010, Jussi-Pekka Erkkila

use Time::HiRes qw(usleep nanosleep time);
use threads;
use threads::shared;

BEGIN {
 my $pidFile = '/var/run/mokobuttondcustom.pid';
 my $pid = fork;
 if ($pid) # parent: save PID
 {
  open PIDFILE, ">$pidFile" or die "can't open $pidFile: $!\n";
  print PIDFILE $pid;
  close PIDFILE;
  exit 0;
 }
}


my $idletime : shared = time();

my $thr_power = threads->create('listenaux', '/dev/input/event0');
my $thr_aux = threads->create('listenaux', '/dev/input/event4');

$thr_power->join();
$thr_aux->join();
threads->exit();

sub listenaux {
  my($device) = shift;
  open FILE, $device;
  binmode FILE;
   
  while( read(FILE, $buf, 16)) {
    ($ab, $c, $d, $e, $value) = unpack("iisss", $buf);
    if($d == 0 && $e == 0) {
      next;
    }

    if($d == 5 && $e == 2) {
      if($value == 1) { 
        # headphones plugged in
      }
      if($value == 0) {
 	# headphones plugged out
      }
    }
    
    if($d == 1 && $e == 169) {
      if($value == 1) {
        $hold_time = time;
        # aux pressed
      }
      if($value == 0) { 
        aux_released(time - $hold_time);
        # aux released
      }
    }
    if($d == 1 && $e == 116) {
      if($value == 1) {
        $hold_time = time;
        # power pressed
      } 
      if( $value == 0) { 
        power_released(time - $hold_time);
        # power released
      }
    } 
  }
}

sub aux_pressed {
#  print "aux pressed";
}
sub power_pressed {
#  print "power pressed";
}

# variable $tim tells the "hold-down" time in seconds, 
# configure here the events you wanna launch

sub aux_released {
  $tim = shift;
  if($tim < 0.3) {
    # aux short tap click
  } 
  if($tim > 0.3) {
    # aux hold-click
  }
}

sub power_released {
  $tim = shift;
  if($tim < 0.5) {
    # short click
    `launch-some-app >/dev/null 2>/dev/null`;
  }
  if($tim > 1 && $tim < 2) {
    # hold click
  }
  if($tim > 6) {
     # hold power more than 6 seconds -> shutdown the phone
    `poweroff`;
  }
}

