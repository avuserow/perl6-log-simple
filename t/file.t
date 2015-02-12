use Log::Simple;
use Test;

constant LOGFILE = "$*TMPDIR/perl6-log-simple--test.log";

# Truncate the logfile used
open(LOGFILE, :w).close();

sub deformat(Str $str) {
	$str ~~ /
		\[$<level>=\w+\]
		\s+
		$<date>=\S+
		\s+
		$<file>=\S+?
		\:$<line>=\d+\:
		\s+
		$<msg>=.+
	/;
	return $/;
}

sub loglines {
	my @lines = map *.&deformat, lines(LOGFILE.IO.slurp);
}

my $appender = Log::Simple::Appender::File.new(:file(LOGFILE));
Log::Simple::route('', $appender);

fatal 'message 0';
info 'message 1';
warning 'message 2';
trace 'will not be logged';
debug 'will not be logged by default';
error 'message 3';
fatal 'message 4';

my @logs = loglines();
is +@logs, 5;
is @logs[0]<msg>, 'message 0';
is @logs[0]<level>, 'FATAL';
is @logs[1]<msg>, 'message 1';
is @logs[1]<level>, 'INFO';
is @logs[2]<msg>, 'message 2';
is @logs[2]<level>, 'WARNING';
is @logs[3]<msg>, 'message 3';
is @logs[3]<level>, 'ERROR';
is @logs[4]<msg>, 'message 4';
is @logs[4]<level>, 'FATAL';

done;
