Jpegtran
========

**Jpegtran** provides Ruby interface to the [`jpegtran`][1] tool. 
Some examples follow: (for details, see module documentation)

```ruby
require "jpegtran"

Jpegtran.available?    # will return true (or false)

options = { :progressive => true, :optimize => true }
Jpegtran.optimize("foo.jpg", options)

# will run 'jpegtran -progressive -optimize -outfile foo.jpg foo.jpg'
```

It can be also run asynchronously by non-blocking way (with [`eventmachine`][4]) 
simply by giving block to `#optimize`. See documentation. 
    
### Unsupported Options

The `-maxmemory N` option isn't supported.

Copyright
---------

Copyright &copy; 2011 &ndash; 2015 [Martin Poljak][3]. See `LICENSE.txt` for
further details.

[1]: http://linux.die.net/man/1/jpegtran
[2]: http://github.com/martinkozak/jpegtran/issues
[3]: http://www.martinpoljak.net/
[4]: http://rubyeventmachine.com/
