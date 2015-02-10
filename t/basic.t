use Log::Simple;
use Test;

# Test logging using a custom appender
class ToArray does Log::Simple::Appender {
	has @.logs;

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


	method append($message) {
		@.logs.push(deformat($message));
	}
}

my $appender = ToArray.new;
Log::Simple::route('', $appender);

is $appender.logs, [];

fatal 'message 0';
info 'message 1';
warning 'message 2';
trace 'will not be logged';
debug 'will not be logged by default';
error 'message 3';
fatal 'message 4';

is +$appender.logs, 5;
is $appender.logs[0]<msg>, 'message 0';
is $appender.logs[0]<level>, 'FATAL';
is $appender.logs[1]<msg>, 'message 1';
is $appender.logs[1]<level>, 'INFO';
is $appender.logs[2]<msg>, 'message 2';
is $appender.logs[2]<level>, 'WARNING';
is $appender.logs[3]<msg>, 'message 3';
is $appender.logs[3]<level>, 'ERROR';
is $appender.logs[4]<msg>, 'message 4';
is $appender.logs[4]<level>, 'FATAL';

# change the logging level
Log::Simple::route('', Log::Simple::TRACE);

trace 'trace log';
debug 'debug log';
trace 'another trace log';

is $appender.logs[5]<msg>, 'trace log';
is $appender.logs[5]<level>, 'TRACE';
is $appender.logs[6]<msg>, 'debug log';
is $appender.logs[6]<level>, 'DEBUG';
is $appender.logs[7]<msg>, 'another trace log';
is $appender.logs[7]<level>, 'TRACE';

done;
