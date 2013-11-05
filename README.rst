dejector
========

.. image:: https://travis-ci.org/jstasiak/dejector.png?branch=master
   :alt: Build status
   :target: https://travis-ci.org/jstasiak/dejector


This is an attempt to create a dependency injection framework for D and my way of learning the language.

Example usage
-------------

.. code-block:: d

    import std.conv : to;
    import std.stdio : writefln;

    import dejector : Dejector;

    interface Greeter {
        string greet();
    }

    class GreeterImplementation : Greeter {
        string greet() { return "Hello!"; }
    }

    void main() {
        Dejector dejector;
        dejector.bind!(Greeter, GreeterImplementation);
        Greeter greeter = dejector.get!Greeter;
        writefln(greeter.greet)
    }

Output::

    Hello!

Running tests
-------------

You need to have `dub <https://github.com/rejectedsoftware/dub>`_ installed and reacheble from your PATH.

::

    ./runtests

Copyright
---------

Copyright (C) 2013 Jakub Stasiak

This source code is licensed under MIT license, see LICENSE file for details.
