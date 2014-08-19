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

while(<STDIN>) {
    if($_ =~ /^(\d+):(\d+) \[([0-9a-f]+)\] (.*)/) {
        my ($secs, $msecs, $code, $symb)=($1, $2, $3, $4);
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
        $mon = sprintf("%02d", $mon+1);
        $mday = sprintf("%02d", $mday);

        $hours{"$year-$mon-$mday $hour:00"}++;
        $minutes{"$year-$mon-$mday $hour:$min"}++;

        $dayhour{"$hour:00"}++;
        $dayminute{"$hour:$min"}++;
    }
}

my $totalhours = ($last - $first)/3600;
my $totalminutes = ($last - $first)/60;
my $totaldays = $totalhours / 24;
printf "A total of $presses keypresses, %d unique keys over %d hours (%0.1f days)\n", scalar(keys %codes), $totalhours, $totaldays;

printf "Average %d keypresses/day\n", $presses/$totaldays;

my $ahours=scalar(keys %hours);
my $aminutes=scalar(keys %minutes);
printf "%d active hours, %d active minutes\n", $ahours, $aminutes;

printf "%d key presses/active hour (%d%% active hours)\n%d key presses/active minute (%d%% active minutes)\n",
    $presses/$ahours, $ahours*100/$totalhours,
    $presses/$aminutes, $aminutes*100/$totalminutes;

my @top = sort { $hours{$b} <=> $hours{$a} } keys %hours;
printf "Most key presses during a single hour: %d (%s)\n", $hours{$top[0]}, $top[0];

my @top = sort { $minutes{$b} <=> $minutes{$a} } keys %minutes;
printf "Most key presses during a single minute: %d (%s)\n", $minutes{$top[0]}, $top[0];

my @top = sort { $dayhour{$b} <=> $dayhour{$a} } keys %dayhour;
printf "The most active hour each day: %d (%s)\n", $dayhour{$top[0]}, $top[0];

my @top = sort { $dayminute{$b} <=> $dayminute{$a} } keys %dayminute;
printf "The most active minute each day: %d (%s)\n", $dayminute{$top[0]}, $top[0];

print "\nKeypress frequency (scan code, number of presses, symbol, share)\n";

for my $c (sort { $codes{$b} <=> $codes{$a} } keys %codes) {
    printf "%s: %d ('%s') %0.1f%%\n", $c, $codes{$c}, $keymap{$c},
    ($codes{$c}*100)/$presses;
}
