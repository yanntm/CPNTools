#!/usr/bin/perl
$color_rows = 0; #set to zero to remove yellow/lightgreen highlights
$gray_out = 1;   #set to zero to remove gray "highlights"

@wiki = ` wget -o /dev/null -O - "http://wiki.daimi.au.dk:8000/cpn2000/list_of_instruments.wiki"`;
$state = 1;
$num_yes = 0;
$num_no =0;

LOOP: foreach (@wiki) {
    if ($state == 3) {
	if (m/^(<td.*Pp.*td>)$/) {
	    if ($gray_out) {
		print "<tr bgcolor=\"gray\"><!-- Postponed -->\n";
	    }
	    else {
		print "<tr><!-- Postponed -->\n";
	    }
	    $state = 4;
	}
	elsif ($color_rows and (m{<td>\s*Yes(\s*\([^\)]*\))?\s*</td>})) {
	    print "<tr bgcolor=\"lightgreen\"><!-- Done -->\n";
	    $state = 5;
	}
	elsif ($color_rows and (m{<td>\s*No(\s*\([^\)]*\))?\s*</td>})) {
	    print "<tr bgcolor=\"yellow\"><!-- Not Done -->\n";
	    $state = 5;
	}
	else {
	    print "<tr>\n";
	    $state = 5;
	}
	print "$titleline";
    }
    if ($state == 5) {
	if (m{</tr>}) {
	    print;
	    $state = 1;
	    next LOOP;
	}
	else {
	    if (s{<td>\s*No(\s*\([^\)]*\))?\s*</td>}{<td bgcolor="red">No$1 </td>}) {$num_no++;}
	    if (s{<td>\s*Yes(\s*\([^\)]*\))?\s*</td>}{<td bgcolor="green">Yes$1 </td>}) {$num_yes++;}
	    s{Yes\.}{Yes};
	    s{No\.}{No};
	    s{<td>\s*Pp\s*</td>}{<td bgcolor="gray">Pp </td>};
	    print;
	    next LOOP;
	}
    }
    if ($state == 4) {
	if (m{</tr>}) {
	    $state = 1;
	}
	s{Yes\.}{Yes};
	s{No\.}{No};
	s{<td>\s*Pp\s*</td>}{<td bgcolor="gray">Pp </td>};
	print;
	next LOOP;
    }
    if ($state == 2) {
	if (m/^(<td.*td>)$/) {
	    $titleline = "$1<!-- titleline -->\n";
	    $state = 3;
	}
	else {
	    print;
	    $state = 1;
	}
	next LOOP;
    }
    if ($state == 1) {
	if (m/<tr>/) {
	    $state = 2;
	}
	else {
	    if ($num_yes+$num_no) {
		s{ryl}{\#Yes: $num_yes};
		s{dask}{\#No: $num_no};
		$pct_yes = ($num_yes/($num_yes+$num_no))*100;
		$pct_yes =~ s{(\d+).*}{$1};
		s{pil}{sprintf("Status: $pct_yes\% yes.");}e;
	    }	    
	    print;
	}
	next LOOP;
    }
}

#print "yes: $num_yes, no: $num_no\n";

