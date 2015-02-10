# NAME

Log::Simple - simple configurable logger

# SYNOPSIS

```perl6

use Log::Simple;

# logging is automatically configured at info levels and above:
info "This will be logged"; # logs to $*ERR with date, filename, and line
warning "So will this";
error "This too";
fatal "And this";

# levels are: TRACE DEBUG INFO WARNING ERROR FATAL in order of severity
debug "Not this";
trace "Nor this";

# Log without the helper
Log::Simple::LOG(Log::Simple::INFO, "Long form of info level log");

# Change the default route to output TRACE and above levels
Log::Simple::route('', Log::Simple::TRACE);

# Output things to a file
Log::Simple::route('', Log::Simple::Appender::File.new(:file<my.log>));

# Special level to disable ALL logs
Log::Simple::route('', Log::Simple::OFF);
```

# DESCRIPTION

A simple yet configurable logger, with a focus on a minimal function-based
interface. The goal is to provide something that works well to get programs
started logging, without boilerplate or much configuration, and then give some
extensibility to transition into common logging cases.

This module does not provide a logger object, instead preferring to have
exported functions. The reasoning behind this stems from seeing a common pattern
of importing a logging module, getting a logger object based on the package
name, keeping it as a global, and using it everywhere. At this point, I decided
to give logging a try with just exported functions.

The default configuration of this module is to log INFO and above to STDERR. The
goal is to let people just import and start logging without needing to configure
any routes or files. The choice of level will hopefully allow people to use this
in dependencies and not flood a user's screen by default, but also show
higher priority messages via logging.

Log::Simple is intended to provide some functionality that can get you into more
common use cases, like logging to files. These appenders are implemented using
objects (and roles) to allow for more extensibility than plain subroutines.

The final goal for Log::Simple is to make it relatively easy for other logging
modules (if and when they appear) to take over the important logging details.
The goal is to allow third party modules using Log::Simple to automatically
transition into another logging framework used by an application.

If this seems a bit too simple, then I'm sure a port of Log4j or some larger
logging system will arrive in due time, which might work better for more
interesting logging scenarios.

# EXPORTED FUNCTIONS

## trace
## debug
## info
## warning
## error
## fatal

These functions are exported. These are identical to LOG below, with the level
argument set to the matching level (in fact, they're built with
`&LOG.assuming`).

# FUNCTIONS

## LOG(Level $level, $msg, Int :$backtrace-depth=1)

LOG (all caps) is the main logging function, but it's not exported. Consider
using the exported versions above.

The default format is: [LEVEL] DATETIME FILE:LINE: MESSAGE

The first argument is a Level, which determines if the message is sent to an
Appender.

$msg is the argument to log. It's stringified and formatted into a message,
which is passed to the appender.

The formatted message uses information from a Backtrace object to determine the
file and line where the message was emitted. The optional backtrace-depth
argument can be used to indicate how many frames to go up. This is useful if you
are wrapping LOG with your own function, in which case you may want to set this
to 2. We automatically skip frames from the core setting, allowing you to use
`&LOG.assuming` to make custom versions without adjusting this argument.

You cannot log at the special Level "OFF".

## route($source, Log::Simple::Appender $appender, Level $level?)
## route($source, Level $level)

API to adjust the destination of messages from a certain source, sending it to
the specified Appender if it is at or above the specified Level. (The function
without the Appender argument changes the Level but leaves the Appender intact.)

The actual source-based routing is not yet implemented. Use the empty string to
indicate that it is the fallback rule.

You can use the OFF level to quiet all logging.

# CONSTANTS

## Level

Enum of logging levels, in order: TRACE DEBUG INFO WARNING ERROR FATAL OFF

# CLASSES / ROLES

## Log::Simple::Appender

A role for appenders. Specifies two methods:

- close(), called when this appender is replaced
- append($message), called with the message text to write

close() is optional, append() is marked as a stub and must be implemented.

## Log::Simple::Appender::Handle

Append to an already-opened IO::Handle object via its say method. Does not close
the handle, so it is suitable to use this with `$*OUT` or `$*ERR` (which is what
this module does by default).

Attributes:
- $.handle - file handle to use, required

## Log::Simple::Appender::File

A trivial appender that writes to a file. No file rotation is provided. The file
is opened in append mode.

Constructor arguments:
- :$file - path for the file to use for loggin

# EXCEPTIONS

All adhoc at present.

# TODO

- More tests
- Implement routes, probably based on $?PACKAGE by default
- Configurable formatters
- Rotating logfiles?
- Concurrent logging support
- More appenders (tee, databases, syslog, Windows event log)
- Argument to LOG to allow selection of a specific package

# CAVEATS

This is pre-1.0 design. Anything could change (though the lowercase exported
logging functions themselves are probably safe).
