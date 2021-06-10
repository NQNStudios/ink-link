package;

import inkjs.engine.story.Story;

@:build(StoryCommands.build())
class CommandLineStory {
	var story:Story;

	public function new(inkJson:String) {
		story = new Story(inkJson);
	}
}
