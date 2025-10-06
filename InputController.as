
package {
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.EventDispatcher;

	public class InputController {
		private var buffer:Array;
		private var stage:Stage;

		public function InputController(stageRef:Stage) {
			buffer = [];
			stage = stageRef;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		private function onKeyDown(e:KeyboardEvent):void {
			if (buffer.indexOf(e.keyCode) == -1) {
				buffer.push(e.keyCode);
				InputEventsManager.dispatcher.dispatchEvent(new InputEvents(InputEvents.KEY_DOWN, {keyCode: e.keyCode}));
			}
		}

		private function onKeyUp(e:KeyboardEvent):void {
			var idx:int = buffer.indexOf(e.keyCode);
			if (idx != -1) {
				buffer.splice(idx, 1);
			}
		}

		public function getBuffer():Array {
			return buffer.concat();
		}
	}
}
