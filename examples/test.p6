use lib <lib>;

use Log::Simple;

# Log::Simple::route('', Log::Simple::Appender::File.new(:file<foo.log>), Log::Simple::TRACE);

info "info";

trace "foo";

Log::Simple::LOG(Log::Simple::TRACE, "foo");
Log::Simple::LOG(Log::Simple::INFO, "info");

sub bar {
    trace "in bar";
    info "info in bar";
}

bar;
