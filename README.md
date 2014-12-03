# Forkr
Forkr is a preforking worker host, shamelessly inspired by unicorn.

It exists to easily fork and scale ruby programs which aren't rack-based.

## What Forkr does for you
Forker provides a master management process which oversees and restarts your workers for you.

The Forkr master will respond to the TTIN and TTOU signals and automatically add or remove workers.

The Forkr master also responds to the standard unix TERM, QUIT, and INT signals, forwarding those to your workers.

## What you must provide
You need to provide a single object, called a Forklet.  This object must respond to a single, parameterless method called run.

Your run method will be invoked after forking - this is the time to close or reopen any file descriptors or the like.

In your run method, you will need to:

* Block the current thread - make sure to do this or Forkr will get confused and continue restarting your workers.  It thinks they have died.
* Respond properly to the TERM, QUIT, and INT signals

## How to use it
Provided you already have a forklet and a number of workers you want to run (let's say 3) you can start the master simply with:

```ruby
    Forkr.new(forklet, 3).run  
```
