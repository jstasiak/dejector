import dejector : Dejector, InstanceProvider, Module, NoScope, Singleton;

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
		class MyModule : Module {
			void configure(Dejector dejector) {
				dejector.bind!(X);
				dejector.bind!(Greeter, GreeterImplementation);
				dejector.bind!(User)(function() { return new User("root"); });
			}
		}

		auto dejector = new Dejector([new MyModule()]);

		auto greeter = dejector.get!Greeter;
		assert(greeter.greet == "Hello!");

		auto user = dejector.get!User;
		assert(user.name == "root");
	}

	/// InstanceProvider works
	unittest {
		auto dejector = new Dejector;
		dejector.bind!(User)(new InstanceProvider(new User("Jon")));
		assert(dejector.get!User.name == "Jon");
	}

	/// NoScope binding creates new object on every call
	unittest {
		auto dejector = new Dejector;
		dejector.bind!(X, NoScope);

		assert(dejector.get!X() !is dejector.get!X());
	}

	/// Singleton binding always returns the same object
	unittest {
		auto dejector = new Dejector;
		dejector.bind!(X, Singleton);

		assert(dejector.get!X is dejector.get!X);
	}
}
