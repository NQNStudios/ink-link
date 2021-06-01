package;

import inkjs.engine.story.Story;
import js.node.ChildProcess;
import sys.io.File;

using StringTools;

class Main {
	static function main() {
		var args = Sys.args();

		var syncCommand = [];
		var inkFile = "";
		while (args.length > 0) {
			switch (args.shift()) {
				case "--sync":
					if (args.length > 0) {
						syncCommand = args;
						break;
					} else {
						throw 'error: ink-link backend requires a command after --sync';
					}
				case value:
					if (inkFile.length > 0) {
						throw 'error: ink-link backend was passed $value when story file $inkFile was already given';
					}
					inkFile = value;
			}
		}
		if (inkFile.length == 0) {
			throw 'error: ink-link backend was not passed an ink file path';
		}

		// Run inklecate.exe on the file
		ChildProcess.spawnSync("./inklecate.exe", [inkFile]);

		var json = File.getContent('${inkFile}.json');
		// Strip the UTF-8 Byte-Order-Mark
		var jsonTrimmed = json.substr(1);

		// Create a story
		var story = new Story(jsonTrimmed);

		if (syncCommand.length > 0) {} else {}

		story.Continue();
		trace(story.currentText);
	}
}
