#!/usr/bin/perl
for(0..9x3){@c=@{([2,1],[0,0],[0,3])[rand 3]};$c[$i=rand 2]&&++$t&&$c[!$i]&&$j++}die$j/$t*1e2
