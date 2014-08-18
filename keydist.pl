#!/usr/bin/perl

my %codes;
my %symbols;
my %keymap; # hex to symbol

while(<STDIN>) {
    if($_ =~ /^(\d+):(\d+) \[([0-9a-f]+)\] (.*)/) {
        my ($secs, $msecs, $code, $symb)=($1, $2, $3, $4);
        $codes{$code}++;
        $keymap{$code}=$symb;
        $symbols{$symb}++;
    }
}

for my $c (sort { $codes{$b} <=> $codes{$a} } keys %codes) {
    printf "%s: %d ('%s')\n", $c, $codes{$c}, $keymap{$c};
}
