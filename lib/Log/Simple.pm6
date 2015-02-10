module Log::Simple;

role Log::Simple::Appender {
	method append($message) {...}
	method close() {}
}

class Log::Simple::Appender::Handle does Log::Simple::Appender {
	has IO::Handle $.handle = !!! "handle is required";

	method append($message) {
		$.handle.say($message);
	}

	method close() {
		$.handle.flush;
	}
}

class Log::Simple::Appender::File does Log::Simple::Appender {
	has IO::Handle $!fh;

	submethod BUILD(:$file!) {
		$!fh = open($file, :a);
	}

	method append($message) {
		$!fh.say($message);
	}

	method close() {
		$!fh.close();
	}
}

enum Level <TRACE DEBUG INFO WARNING ERROR FATAL OFF>;

# Set up a default route for log messages, where everything goes to the screen
# TODO: add route configurability based on package or similar
# TODO: add multiple route support
my $route = {
	:level(INFO),
	:appender(Log::Simple::Appender::Handle.new(:handle($*ERR)))
};

our sub LOG(Level $level, $msg) {
	return if $level < $route<level>;
	die "You cannot log at the OFF level" if $level == OFF;
	my $caller = grep(!*.is-setting, Backtrace.new)[1];
	my $date = DateTime.now;
	$route<appender>.append("[$level] $date $caller.file():$caller.line(): $msg");
}

our &trace is export = &LOG.assuming(TRACE);
our &debug is export = &LOG.assuming(DEBUG);
our &info is export = &LOG.assuming(INFO);
our &warning is export = &LOG.assuming(WARNING);
our &error is export = &LOG.assuming(ERROR);
our &fatal is export = &LOG.assuming(FATAL);

our sub route(Log::Simple::Appender $appender?, Level $min-level?) {
	if $appender {
		$route<appender>.close();
		$route<appender> = $appender;
	}
	if $min-level {
		$route<level> = $min-level;
	}
}
