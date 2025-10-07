package  {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	
	public class Main extends MovieClip {
		
		private const MAX_INPUT_BUFFER:int = 10;
		private const MAX_INPUT_WAIT:int = 3;

		private var input:InputController;
		private var currentInputs:TextField;

		private var hostIP:TextField;
		private var joinButton:MovieClip;
		private var createButton:MovieClip;

		private var isHost:Boolean = false;
		private var hostServer:HostServer;
		private var currentClient:Client;

		private var frameTimer:int = 0;
		private var delayedInputs:Array = [];

		public var inputTextFieldVector:Vector.<TextField> = new Vector.<TextField>();

		public var allCharacters:Vector.<CharacterController> = new Vector.<CharacterController>();

		public function Main() {
			addChild(hostIP = new TextField());
			hostIP.width = 200;
			hostIP.height = 30;
			hostIP.border = true;
			hostIP.text = "localhost";
			hostIP.x = 10;
			hostIP.y = 10;
			hostIP.type = "input";
			addChild(joinButton = new MovieClip());
			addChild(createButton = new MovieClip());
			createButtons();
			InputEventsManager.dispatcher.addEventListener(InputEvents.JOINED, onJoined);
			InputEventsManager.dispatcher.addEventListener(InputEvents.OTHER_USER_CONNECTED, onOtherUserConnected);
			InputEventsManager.dispatcher.addEventListener(InputEvents.HAS_SPAWNED, onHasSpawned);
		}

		private function onHasSpawned(e:*):void {
			trace("A character has spawned!" + currentClient.ClientID);
			frameTimer = 0;
			for (var i:int = 0; i < currentClient.ClientID; i++) {
				spawnCharacter();
			}
		}

		private function onOtherUserConnected(e:*):void {
			trace("Another user connected!");
			frameTimer = 0;
			spawnCharacter();
		}

		private function createButtons():void {
			joinButton.graphics.beginFill(0x00FF00);
			joinButton.graphics.drawRect(0, 0, 80, 30);
			joinButton.graphics.endFill();
			joinButton.x = 220;
			joinButton.y = 10;
			joinButton.buttonMode = true;
			joinButton.mouseChildren = false;
			joinButton.addChild(new TextField());
			(joinButton.getChildAt(0) as TextField).width = 80;
			(joinButton.getChildAt(0) as TextField).height = 30;
			(joinButton.getChildAt(0) as TextField).text = "Join";
			(joinButton.getChildAt(0) as TextField).selectable = false;
			createButton.graphics.beginFill(0x0000FF);
			createButton.graphics.drawRect(0, 0, 80, 30);
			createButton.graphics.endFill();
			createButton.x = 310;
			createButton.y = 10;
			createButton.buttonMode = true;
			createButton.mouseChildren = false;
			createButton.addChild(new TextField());
			(createButton.getChildAt(0) as TextField).width = 80;
			(createButton.getChildAt(0) as TextField).height = 30;
			(createButton.getChildAt(0) as TextField).text = "Create";
			(createButton.getChildAt(0) as TextField).selectable = false;
			joinButton.addEventListener("click", joinRoom);
			createButton.addEventListener("click", createRoom);
		}

		private function removeButtons():void {
			removeChild(joinButton);
			removeChild(createButton);
			removeChild(hostIP);
			joinButton = null;
			createButton = null;
			hostIP = null;
		}

		private function createRoom(e:MouseEvent):void {
			hostServer = new HostServer();
			isHost = true;
			currentClient = new Client("127.0.0.1", 1337, this);

		}

		private function joinRoom(e:MouseEvent):void {
			currentClient = new Client(hostIP.text, 1337, this);
		}

		private function onJoined(e:*):void {
			trace("Joined the server!");
			removeButtons();
			input = new InputController(stage);
			addEventListener("enterFrame", onEnterFrame);
			for (var i:int = 0; i < currentClient.ClientID; i++) {
				spawnCharacter();
			}
		}

		private function spawnCharacter():void {
			var character:CharacterController = new CharacterController(input);
			addChild(character);
			allCharacters.push(character);
		}

		private function onEnterFrame(e:*):void {
			if(isHost) hostServer.PERFORMALL();
			if(!currentClient.allControllersHaveSameLength() || allCharacters.length < currentClient.ClientID || currentClient.ClientID < 1) return;
			for (var i:int = 0; i < currentClient.Controllers.length; i++) {
				if(i >= allCharacters.length || allCharacters[i] == null) continue;
				allCharacters[i].addToInputBuffer(currentClient.Controllers, i + 1);
				allCharacters[i].PERFORMALL();
			}
			delayedInputs.push(allCharacters[currentClient.ClientID - 1].getInputState(input.getBuffer()));
			frameTimer++;
			if(frameTimer < MAX_INPUT_WAIT) return;
			currentClient.sendInput(delayedInputs, frameTimer);
			delayedInputs.length = 0;
			for (i = 0; i < currentClient.Controllers.length; i++) {
				currentClient.Controllers[i].shift();
			}
			/*character.PERFORMALL();
			var inputMaximum:int = character.InputBuffer.length < MAX_INPUT_BUFFER ? character.InputBuffer.length : MAX_INPUT_BUFFER;
			var output:String = "Input Buffer: ";
			for (var i:int = 0; i < inputMaximum; i++) {
				output += character.InputBuffer[i] + (i < inputMaximum - 1 ? ", " : "");
			}
			currentInputs.text = output;*/
		}

	}
	
}
