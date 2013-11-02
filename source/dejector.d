import std.conv : to;
import std.stdio : writefln;
import std.string : chomp;
import std.traits : fullyQualifiedName, hasMember, ParameterTypeTuple;

immutable argumentSeparator = ", ";

string generateGet(T)() {
	immutable nameOfT = fullyQualifiedName!T;
	auto code = "new " ~ nameOfT ~ "(";
	static if (hasMember!(T, "__ctor")) {
		foreach (type; ParameterTypeTuple!(mixin(nameOfT ~ ".__ctor"))) {
			code ~= "get!(" ~ fullyQualifiedName!type ~ ")" ~ argumentSeparator;
		}
	}
	code = chomp(code, argumentSeparator) ~ ")";
	return code;
}

class Dejector {
	T get(T)() {
		return mixin(generateGet!T);
	}
}

class B {}

class A {
	this(B b) {}
}

class X {
	A a;

	this(A a) {
		this.a = a;
	}
}

unittest {
	auto dejector = new Dejector;
	auto a = dejector.get!A;
	assert(a.classinfo == A.classinfo);
	auto x = dejector.get!X;
	assert(x.classinfo == X.classinfo);
	assert(x.a.classinfo == A.classinfo);
	writefln(to!string(x));
}
