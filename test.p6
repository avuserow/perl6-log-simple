use lib <lib>;

use Log::Simple;

trace "foo";

Log::Simple::LOG(Log::Simple::TRACE, "foo");

sub bar {
    trace "in bar";
}

bar;
