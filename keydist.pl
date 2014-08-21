#!/usr/bin/perl

my %codes;
my %symbols;
my %keymap; # hex to symbol
my $presses;
my $first;
my $last;

my %hours;
my %minutes;
my %dayhour;
my %dayminute;

my @daynames=("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
              "Saturday");

# set up the hash table with 24 entries
for(0 .. 23) {
    my $h = sprintf("%02d", $_);
    $dayhour{"$h"}=0;
}

while(<STDIN>) {
    if($_ =~ /^(\d+):(\d+) \[([0-9a-f]+)\] (.*)/) {
        my ($secs, $msecs, $code, $symb)=($1, $2, $3, $4);

        if($symb eq " ") {
            $symb = "<Space>";
        }

        $codes{$code}++;
        $keymap{$code}=$symb;
        $symbols{$symb}++;
        $presses++;

        if(!$first) {
            $first = $secs;
        }
        $last = $secs;

        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
            localtime($secs);
        $year += 1900;
        $min = sprintf("%02d", $min);
        $hour = sprintf("%02d", $hour);
        $mon = sprintf("%02d", $mon+1);
        $mday = sprintf("%02d", $mday);
        $wday = sprintf("%02d", $wday);

        $hours{"$year-$mon-$mday $hour:00"}++;
        $minutes{"$year-$mon-$mday $hour:$min"}++;

        $weekday{$wday}++;
        $dayhour{"$hour"}++;
        $dayminute{"$hour:$min"}++;

        $us = ($secs - $first)*1000000 + $msecs;

        if($symb eq "<BckSp>") {

            if(($us - $ous) < 300000) {
                # store symbol before backspace if within .3 second
                $beforebcksp{$nonbcksp}++;
            }
            if(scalar(@nonbcksp) > $bestnonbcksp) {
                $bestnonbcksp = scalar(@nonbcksp);
                @bestnonbcksp = @nonbcksp;
            }
            undef @nonbcksp;
        }
        else {
            $nonbcksp = $symb;
            push @nonbcksp, $symb;
        }
        
        $ocode = $code;
        $osymb = $symb;
        $ous = $us;
        $osecs = $secs;
        $omsecs = $msecs;
    }
}

my $totalhours = ($last - $first)/3600;
my $totalminutes = ($last - $first)/60;
my $totaldays = $totalhours / 24;
printf "A total of $presses keys, %d unique keys over %d hours (%0.1f days)\n", scalar(keys %codes), $totalhours, $totaldays;

printf "Average %d keys/day\n", $presses/$totaldays;

my $ahours=scalar(keys %hours);
my $aminutes=scalar(keys %minutes);
printf "%d active hours, %d active minutes\n", $ahours, $aminutes;

printf "%d keys/active hour (%d%% active hours)\n%d keys/active minute (%d%% active minutes)\n",
    $presses/$ahours, $ahours*100/$totalhours,
    $presses/$aminutes, $aminutes*100/$totalminutes;

my @top = sort { $hours{$b} <=> $hours{$a} } keys %hours;
printf "Most keys during a single hour: %d (%s)\n", $hours{$top[0]}, $top[0];

my @top = sort { $minutes{$b} <=> $minutes{$a} } keys %minutes;
printf "Most keys during a single minute: %d (%s)\n", $minutes{$top[0]}, $top[0];

my @htop = sort { $dayhour{$b} <=> $dayhour{$a} } keys %dayhour;
printf "The most active hour each day: %d (%s)\n", $dayhour{$htop[0]}, $htop[0];

my @top = sort { $dayminute{$b} <=> $dayminute{$a} } keys %dayminute;
printf "The most active minute each day: %d (%s)\n", $dayminute{$top[0]}, $top[0];

my @wtop = sort { $weekday{$b} <=> $weekday{$a} } keys %weekday;
printf "The most active day of the week: %d keys (%s)\n", $weekday{$wtop[0]},
    $daynames[$wtop[0]];

printf "Longest key sequence without backspace: %d\n", $bestnonbcksp;


my @top = sort { $dayhour{$a} <=> $dayhour{$b} } keys %dayhour;

for my $t (@top) {
    if($dayhour{$t} < 1) {
        push @idle, $t;
        next;
    }
    last;
}

my $silent;
if($idle[0]) {
    $silent=join(", ", sort @idle);
}
else {
    $silent = "NONE";
}
printf "Inactive hours: %s\n", $silent;

print "\nThe 5 most active hours:\n";
$i=1;
for my $h (@htop) {
    printf "  $i: %02d-%02d %d keys (%0.1f%%)\n", $h, $h+1, $dayhour{$h},
    $dayhour{$h}*100/$presses;
    $i++;
    if($i > 5) {
        last;
    }
}

print "\nWeek day frequency distribution:\n";
$i=1;
for my $w (@wtop) {
    printf("  $i: %s %d keys (%0.1f%%)\n", $daynames[$w], $weekday{$w},
           $weekday{$w}*100/$presses);
    $i++;
}

my @top = sort { $beforebcksp{$b} <=> $beforebcksp{$a} } keys %beforebcksp;

print "\nThe 10 most backspaced symbols (within 0.3 seconds and just before):\n";
$i=1;
for my $h (@top) {
    printf "  $i: %s %d times (%0.1f%%)\n", $h, $beforebcksp{$h},
    $beforebcksp{$h}*100/$symbols{'<BckSp>'};
    $i++;
    if($i > 10) {
        last;
    }
}

print "\nKey frequency (scan code, number of presses, symbol, share)\n";

$i=1;
for my $c (sort { $codes{$b} <=> $codes{$a} } keys %codes) {
    printf ("  $i: %s: %d ('%s') %0.1f%%\n", $c, $codes{$c}, $keymap{$c},
            ($codes{$c}*100)/$presses);
    $i++;
}
