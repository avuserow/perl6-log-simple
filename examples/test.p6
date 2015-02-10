use lib <lib>;

use Log::Simple;

Log::Simple::route('', Log::Simple::Appender::File.new(:file<foo.log>), Log::Simple::TRACE);

trace "foo";

Log::Simple::LOG(Log::Simple::TRACE, "foo");

sub bar {
    trace "in bar";
}

bar;
