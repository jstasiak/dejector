import std.conv : to;
import std.stdio : writefln;
import std.string : chomp;
import std.traits : fullyQualifiedName, hasMember, ParameterTypeTuple;

immutable argumentSeparator = ", ";

string generateGet(T)() {
	immutable nameOfT = fullyQualifiedName!T;
	auto code = "Object get() { return new " ~ nameOfT ~ "(";
	static if (hasMember!(T, "__ctor")) {
		foreach (type; ParameterTypeTuple!(mixin(nameOfT ~ ".__ctor"))) {
			code ~= "this.dej.get!(" ~ fullyQualifiedName!type ~ ")" ~
				argumentSeparator;
		}
	}
	code = chomp(code, argumentSeparator) ~ "); }";
	return code;
}


interface Provider {
	Object get();
}

class ClassProvider(T) : Provider {
	private Dejector dej;
	this(Dejector dejector) {
		this.dej = dejector;
	}
	mixin(generateGet!T);
}

class Dejector {
	private Provider[string] bindingMap;

	void bind(Interface)(Provider provider) {
		this.bindingMap[fullyQualifiedName!Interface] = provider;
	}

	void bind(Interface, Class)() {
		this.bind!Interface(new ClassProvider!Class(this));
	}

	Interface get(Interface)() {
		auto provider = this.bindingMap[fullyQualifiedName!Interface];
		return cast(Interface) provider.get;
	}
}

interface Greeter {
	string greet();
}

class GreeterImplementation : Greeter {
	string greet() { return "Hello!"; }
}

unittest {
	auto dejector = new Dejector;
	dejector.bind!(Greeter, GreeterImplementation);

	auto greeter = dejector.get!Greeter;
	assert(greeter.greet == "Hello!");
}
