# $Id: 1.t,v 1.2 2002/05/22 20:39:18 simon Exp $


use Test;

BEGIN { plan tests => 32 }

## If in @INC, should succeed
use HTML::TableContentParser;
ok(1);

## make sure we can turn on debugging..
$HTML::TableContentParser::DEBUG = 1;
ok(1);

## ..and back off.
$HTML::TableContentParser::DEBUG = 0;
ok(1);


## Test object creation

$obj = HTML::TableContentParser->new();
ok(defined $obj, 1, $@);



## Test basic functionality. Create a table, and make sure parsing it returns
## the correct values to the callback.


$table_content1 = 'This is table cell content 1';
$table_content2 = 'This is table cell content 2';
$header_text = 'Header text';

$html = qq{
<html>
<head>
</head>
<body>
Some text that should /not/ get picked up by the parser.
<TABLE id='foo' name='bar' border='0'>
<th>$header_text</th>
<tr><td>$table_content1</td></tr>
<tr><td>$table_content2</td></tr>
</table>
</body>
</html>
};





$HTML::TableContentParser::DEBUG = 0;
$tables = $obj->parse($html);
ok($tables->[0]->{rows}->[0]->{cells}->[0]->{data}, $table_content1, $@);
ok($tables->[0]->{rows}->[1]->{cells}->[0]->{data}, $table_content2, $@);




## Some more complicated tables..

my @rows = (
	['r1td1', 'r1td2', 'r1td3'],
	['r2td1', 'r2td2', 'r2td3'],
	['r3td1', 'r3td2', 'r3td3'],
);

my @hdrs = qw(h1 h2 h3);


$html = qq{
<html>
<head>
</head>
<body>
Some text that should /not/ get picked up by the parser.
<table id='fruznit' name='braknor' border='0'>
};

$html .= '<th>' . join('</th><th>', @hdrs) . "</th>\n";

for (@rows) {
	$html .= '<tr><td>' . join('</td><td>', @$_) . "</td></tr>\n";
}

$html .= qq{
</table>
Some more intermediary text which should be ignored.
<TABLE id='crumhorn' name='wallaby' border='0'>
};


$html .= '<th>' . join('</th><th>', @hdrs) . "</th>\n";

for (@rows) {
	$html .= '<tr><td>' . join('</td><td>', @$_) . "</td></tr>\n";
}


$html .= qq{
</table>
</body>
</html>
};


## Set to 1 to debug this parse.
$HTML::TableContentParser::DEBUG = 0;
$tables = $obj->parse($html);

## We should have two tables..
ok(@$tables, 2, @_);

## and three headers for each table
for $t (0..$#{@$tables}) {
	for (0..$#hdrs) {
		ok($tables->[$t]->{headers}->[$_]->{data}, $hdrs[$_], $@);
	}
}


## and three rows of three cells each, for each table.. (18 total).
for $t (0..$#{@$tables}) {
	for $r (0..$#rows) {
		for (0..2) {
			ok($tables->[$t]->{rows}->[$r]->{cells}->[$_]->{data}, $rows[$r]->[$_], $@);
		}
	}
}




## Now provide a broken table. We wrap the call to parse in an eval, since the
## parser dies if it encounters badness.

$html = qq{
<html>
<head>
</head>
<body>
Some text that should /not/ get picked up by the parser.
<table id='garbled' name='banjaxed' border='0'>
<TH>$header_text</TD>
<TR><TH><TD>$table_content1</TD></TR>
<TR><TD>$table_content2</TD></TR>
</table>
</body>
</html>
};


## Set to 1 to debug this parse.
$HTML::TableContentParser::DEBUG = 0;
eval { $tables = $obj->parse($html)};

ok($@, "text: Invalid HTML. Cannot parse.\n", $@);
