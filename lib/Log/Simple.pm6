module Log::Simple;

enum Level <TRACE DEBUG INFO WARNING ERROR FATAL OFF>;

role Log::Simple::Appender {
	has Level $.level;

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

# Set up a default route for log messages, where everything goes to the screen
# TODO: add route configurability based on package or similar
# TODO: add multiple route support
my $routes = {};
$routes<default> = Log::Simple::Appender::Handle.new(:level(INFO), :handle($*ERR));

my $logstream = Supply.new;
$logstream.act(-> $msg {
	$routes<default>.append($msg);
});

our sub LOG(Level $level, $msg, Int :$backtrace-depth=1) {
	return if $level < $routes<default>.level;
	die "You cannot log at the OFF level" if $level == OFF;
	# XXX: replace me with caller() or similar when it works
	my $caller = grep(!*.is-setting, Backtrace.new)[$backtrace-depth];
	my $date = DateTime.now;
	my $text = "[$level] $date $caller.file():$caller.line(): $msg";
	$logstream.emit($text);
}

our &trace is export = &LOG.assuming(TRACE);
our &debug is export = &LOG.assuming(DEBUG);
our &info is export = &LOG.assuming(INFO);
our &warning is export = &LOG.assuming(WARNING);
our &error is export = &LOG.assuming(ERROR);
our &fatal is export = &LOG.assuming(FATAL);

our proto route($source, |) {*}

our multi route($source, Log::Simple::Appender $appender) {
	warn 'WARNING: Non-fallback route NYI!' if $source;
	$routes<default><appender>.close();
	$routes<default><appender> = $appender;
}
