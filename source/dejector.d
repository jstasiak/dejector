import std.conv : to;
import std.stdio : writefln;
import std.string : chomp;
import std.traits : fullyQualifiedName, hasMember, ParameterTypeTuple;


extern (C) Object _d_newclass(const TypeInfo_Class ci);

immutable argumentSeparator = ", ";

string generateGet(T)() {
	immutable nameOfT = fullyQualifiedName!T;
	auto code = "
		Object get() {
			auto instance = cast(T) _d_newclass(T.classinfo);";

	static if (hasMember!(T, "__ctor")) {
		code ~= "instance.__ctor(";
		foreach (type; ParameterTypeTuple!(T.__ctor)) {
			code ~= "this.dej.get!(" ~ fullyQualifiedName!type ~ ")" ~
				argumentSeparator;
		}
		code = chomp(code, argumentSeparator) ~ ");";
	}
	code ~= "return instance; }";
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

	void bind(Class)() {
		this.bind!(Class, Class);
	}

	void bind(Interface, Class)() {
		this.bind!Interface(new ClassProvider!Class(this));
	}

	Interface get(Interface)() {
		auto provider = this.bindingMap[fullyQualifiedName!Interface];
		return cast(Interface) provider.get;
	}
}


class X {}

unittest {

	interface Greeter {
		string greet();
	}

	class GreeterImplementation : Greeter {
		this(X x) {}
		string greet() { return "Hello!"; }
	}

	auto dejector = new Dejector;
	dejector.bind!(X);
	dejector.bind!(Greeter, GreeterImplementation);

	auto greeter = dejector.get!Greeter;
	assert(greeter.greet == "Hello!");
}
