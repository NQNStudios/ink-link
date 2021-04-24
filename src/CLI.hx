package;

import sys.io.Process;
import sys.io.File;
import sys.thread.Deque;
import sys.thread.Thread;

using haxe.EnumTools;

enum Command {
	// Lower-case names because these are also CLI commands
	start(inkFile:String);
	nextFrame;
	choose(index:String);
	undo;
}

class CLI {
	static var stdoutDeque:Deque<String>;

	static var firstReadline = true;

	static function readLineWithTimeout(timeout:Float = 0.1, checks:Int = 3) {
		if (firstReadline) {
			timeout *= 5;
			firstReadline = false;
		}
		for (i in 0...checks) {
			var nextLine = stdoutDeque.pop(false);
			if (nextLine == null) {
				Sys.sleep(timeout / checks);
			} else {
				return nextLine;
			}
		}
		return null;
	}

	public static function main() {
		var args = Sys.args();

		var commands = Command.getConstructors();
		var usageMessage = 'Use one of these commands: $commands';
		if (args.length == 0) {
			Sys.println(usageMessage);
			Sys.exit(1);
		}

		var commandName = args[0];
		if (commands.indexOf(commandName) < 0) {
			Sys.println(usageMessage);
			Sys.exit(1);
		}

		var command = Command.createByName(commandName, args.slice(1));

		var inkFile = "";
		var pastChoices:Array<String> = [];
		var saveFile = "save.txt";
		switch (command) {
			case start(file):
				inkFile = file;
				File.saveContent(saveFile, inkFile);
			default:
				var savedStuff = File.getContent(saveFile).split("\n");
				inkFile = savedStuff[0];
				pastChoices = savedStuff.slice(1);
				switch (command) {
					case nextFrame:
					case choose(index):
						pastChoices.push(index);
					case undo:
						pastChoices.pop();
					default: throw 'impossible';
				}
		}

		var process = new Process("src/inklecate.exe", ["-p", inkFile]);
		var stdout = process.stdout;
		var stdin = process.stdin;
		var stderr = process.stderr;
		stdoutDeque = new Deque();
		var stdoutThread = Thread.create(() -> {
			try {
				while (true) {
					var nextLine = stdout.readLine();
					stdoutDeque.add(nextLine);
				}
			} catch (e) {
				// Eof
			}
		});

		// var exitCode = process.exitCode(true);
		trace(readLineWithTimeout());
		trace(readLineWithTimeout());
		trace(readLineWithTimeout());
		trace(readLineWithTimeout());
		// No more lines after the two choices
		trace(readLineWithTimeout(5, 5));
		stdin.writeString("1\r\n");
		// CAn it recover from EOF?
		trace(readLineWithTimeout(100, 100));
		trace(readLineWithTimeout());
	}
}
