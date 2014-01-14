import std.conv : to;
import std.functional : toDelegate;
import std.stdio : writefln;
import std.string : chomp;
import std.traits : fullyQualifiedName, hasMember, moduleName, ParameterTypeTuple;


extern (C) Object _d_newclass(const TypeInfo_Class ci);

private immutable argumentSeparator = ", ";

private string generateGet(T)() {
	immutable nameOfT = fullyQualifiedName!T;
	auto code = "
		Object get() {
			auto instance = cast(T) _d_newclass(T.classinfo);";


	static if (hasMember!(T, "__ctor")) {
		foreach (type; ParameterTypeTuple!(T.__ctor)) {
			code ~= "import " ~ moduleName!type ~ ";";
		}

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


class FunctionProvider : Provider {
	private Object delegate() provide;

	this(Object delegate() provide) {
		this.provide = provide;
	}

	Object get() {
		return this.provide();
	}
}


class InstanceProvider : Provider {
	private Object instance;

	this(Object instance) {
		this.instance = instance;
	}

	Object get() {
		return this.instance;
	}
}


private struct Binding {
	string key;
	Provider provider;
	Scope scope_;
}


interface Scope {
	Object get(string key, Provider provider);
}


class NoScope : Scope {
	Object get(string key, Provider provider) {
		return provider.get;
	}
}

class Singleton : Scope {
	private Object[string] instances;

	Object get(string key, Provider provider) {
		if(key !in this.instances) {
			this.instances[key] = provider.get;
		}
		return this.instances[key];
	}
}


interface Module {
	void configure(Dejector dejector);
}


class Dejector {
	private Binding[string] bindings;
	private Scope[string] scopes;

	this(Module[] modules) {
		this.bindScope!NoScope;
		this.bindScope!Singleton;

		foreach(module_; modules) {
			module_.configure(this);
		}
	}

	this() {
		this([]);
	}

	void bindScope(Class)() {
		immutable key = fullyQualifiedName!Class;
		if(key in this.scopes) {
			throw new Exception("Scope already bound");
		}
		this.scopes[key] = new Class();
	}

	void bind(Class, ScopeClass:Scope = NoScope)() {
		this.bind!(Class, Class, ScopeClass);
	}

	void bind(Interface, Class, ScopeClass:Scope = NoScope)() {
		this.bind!(Interface, ScopeClass)(new ClassProvider!Class(this));
	}

	void bind(Interface, ScopeClass:Scope = NoScope)(Provider provider) {
		immutable key = fullyQualifiedName!Interface;
		if(key in this.bindings) {
			throw new Exception("Interface already bound");
		}
		auto scope_ = this.scopes[fullyQualifiedName!ScopeClass];
		this.bindings[key] = Binding(key, provider, scope_);
	}

	void bind(Interface, ScopeClass:Scope = NoScope)(Object delegate() provide) {
		this.bind!(Interface, ScopeClass)(new FunctionProvider(provide));
	}

	void bind(Interface, ScopeClass:Scope = NoScope)(Object function() provide) {
		this.bind!(Interface, ScopeClass)(toDelegate(provide));
	}

	Interface get(Interface)() {
		auto binding = this.bindings[fullyQualifiedName!Interface];
		immutable key = fullyQualifiedName!Interface;
		return cast(Interface) binding.scope_.get(key, binding.provider);
	}
}
