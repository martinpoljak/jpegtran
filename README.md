Jpegtran
========

**Jpegtran** provides Ruby interface to the [`jpegtran`][1] tool. 
Some examples follow: (for details, see module documentation)

    require "jpegtran"
    
    Jpegtran.available?    # will return true (or false)
    
    Jpegtran.optimize("foo.jpg", { :progressive => true, :optimize => true })
    # will run 'jpegtran -progressive -optimize -outfile foo.jpg foo.jpg'
    
It can be also run asynchronously by non-blocking way (with [`eventmachine`][4]) 
simply by giving block to `#optimize`. See documentation. 
    
### Unsupported Options

The `-maxmemory N` option isn't supported.


    
    
Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b 20101220-my-change`).
3. Commit your changes (`git commit -am "Added something"`).
4. Push to the branch (`git push origin 20101220-my-change`).
5. Create an [Issue][2] with a link to your branch.
6. Enjoy a refreshing Diet Coke and wait.

Copyright
---------

Copyright &copy; 2011 [Martin Kozák][3]. See `LICENSE.txt` for
further details.

[1]: http://linux.die.net/man/1/jpegtran
[2]: http://github.com/martinkozak/jpegtran/issues
[3]: http://www.martinkozak.net/
[4]: http://rubyeventmachine.com/
