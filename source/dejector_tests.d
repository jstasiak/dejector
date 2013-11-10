import dejector : Dejector;

version(unittest) {
	class X {}

	class User {
		string name;
		this(string name) {
			this.name = name;
		}
	}

	interface Greeter {
		string greet();
	}

	class GreeterImplementation : Greeter {
		this(X x) {}
		string greet() { return "Hello!"; }
	}

	unittest {
		auto dejector = new Dejector;
		dejector.bind!(X);
		dejector.bind!(Greeter, GreeterImplementation);
		dejector.bind!(User)(function() { return new User("root"); });

		auto greeter = dejector.get!Greeter;
		assert(greeter.greet == "Hello!");

		auto user = dejector.get!User;
		assert(user.name == "root");
	}
}
