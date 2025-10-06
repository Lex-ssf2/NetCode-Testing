package  {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class Main extends MovieClip {
		
		private const MAX_INPUT_BUFFER:int = 10;

		private var input:InputController;
		private var character:CharacterController;

		private var currentInputs:TextField;

		public function Main() {
			input = new InputController(stage);
			addEventListener("enterFrame", onEnterFrame);
			character = new CharacterController(input);
			addChild(character);
			currentInputs = new TextField();
			currentInputs.width = 400;
			currentInputs.height = 300;
			currentInputs.border = true;
			currentInputs.multiline = true;
			currentInputs.wordWrap = true;
			addChild(currentInputs);
		}

		private function onEnterFrame(e:*):void {
			character.PERFORMALL();
			var inputMaximum:int = character.InputBuffer.length < MAX_INPUT_BUFFER ? character.InputBuffer.length : MAX_INPUT_BUFFER;
			var output:String = "Input Buffer: ";
			for (var i:int = 0; i < inputMaximum; i++) {
				output += character.InputBuffer[i] + (i < inputMaximum - 1 ? ", " : "");
			}
			currentInputs.text = output;
		}
	}
	
}
