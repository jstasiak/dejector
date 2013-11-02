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

    class A {}

    class B {
        A a;
        this(A a) {
            this.a = a;
        }
    }

    class C {
        B b;
        this(B b) {
            this.b = b;
        }
    }

    void main() {
        Dejector dejector;
        auto c = dejector.get!C;
        writefln(to!string(c));
        writefln(to!string(c.b));
        writefln(to!string(c.b.a));
    }

Output::

    app.C
    app.B
    app.A

Running tests
-------------

You need to have `dub <https://github.com/rejectedsoftware/dub>`_ installed.

::

    dub --build=unittest --config=unittest

Copyright
---------

Copyright (C) 2013 Jakub Stasiak

This source code is licensed under MIT license, see LICENSE file for details.
