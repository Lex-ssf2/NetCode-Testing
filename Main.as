package  {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	
	public class Main extends MovieClip {
		
		private const MAX_INPUT_WAIT:int = 1;
		private const MAX_MISSING_PACKETS_WAIT:int = 30;

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

		private var frameTimerText:TextField;

		private var missingPacketCounter:int = 0;
		private var m_myInputs:Array = [];

		public function Main() {
			addChild(hostIP = new TextField());
			hostIP.width = 200;
			hostIP.height = 30;
			hostIP.border = true;
			hostIP.text = "127.0.0.1";
			hostIP.x = 10;
			hostIP.y = 10;
			hostIP.type = "input";
			addChild(joinButton = new MovieClip());
			addChild(createButton = new MovieClip());
			createButtons();
			InputEventsManager.dispatcher.addEventListener(InputEvents.OTHER_USER_CONNECTED, onOtherUserConnected);
			InputEventsManager.dispatcher.addEventListener(InputEvents.HAS_SPAWNED, onHasSpawned);
		}

		private function onHasSpawned(e:*):void {
			trace("Joined the server!");
			removeButtons();
			input = new InputController(stage);
			addEventListener("enterFrame", onEnterFrame);
			trace("A character has spawned!" + currentClient.ClientID);
			frameTimer = 0;
			for (var i:int = 0; i < currentClient.ClientID; i++) {
				spawnCharacter();
			}
			frameTimerText = new TextField();
			frameTimerText.width = 200;
			frameTimerText.height = 30;
			frameTimerText.border = true;
			frameTimerText.x = 200;
			frameTimerText.y = 50;
			addChild(frameTimerText);
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

		private function spawnCharacter():void {
			var character:CharacterController = new CharacterController(input);
			addChild(character);
			allCharacters.push(character);
		}

		private function onEnterFrame(e:*):void {
			if(isHost) hostServer.PERFORMALL();
			/*if(!currentClient.allControllersHaveSameLength() || allCharacters.length < currentClient.ClientID || currentClient.ClientID < 1) return;
*/
			var currentInputInt:int = -1;
			if(currentClient.Controllers[currentClient.ClientID - 1] && currentClient.Controllers[currentClient.ClientID - 1].length > frameTimer - MAX_INPUT_WAIT) {
				currentInputInt = currentClient.Controllers[currentClient.ClientID - 1][frameTimer - MAX_INPUT_WAIT];
			}
			if(currentInputInt == -1) {
				/*trace("Missing input for frame " + (frameTimer - MAX_INPUT_WAIT) + ", waiting up to " + MAX_INPUT_WAIT + " frames...");
				trace("Current input buffer length: " + (currentClient.Controllers[currentClient.ClientID - 1] ? currentClient.Controllers[currentClient.ClientID - 1].length : 0) + ", required: " + (frameTimer - MAX_INPUT_WAIT));
				trace("Waiting for all controllers to sync...");*/
				missingPacketCounter++;
				if(missingPacketCounter > MAX_MISSING_PACKETS_WAIT) {
					//trace("Missing the frame asking for it again");
					currentClient.askFrame(frameTimer - MAX_INPUT_WAIT);
				}
				return;
			}
			missingPacketCounter = 0;
			var currentInput:int = allCharacters[currentClient.ClientID - 1].getInputState(input.getBuffer());
			currentClient.sendInput(currentInput, frameTimer);
			for (var i:int = 0; i < currentClient.Controllers.length; i++) {
				if(i >= allCharacters.length || allCharacters[i] == null) continue;
				allCharacters[i].addToInputBuffer(currentClient.Controllers, i + 1, frameTimer - MAX_INPUT_WAIT);
				allCharacters[i].PERFORMALL();
			}
			frameTimer++;
			frameTimerText.text = "Frame: " + frameTimer;
			/*for (i = 0; i < currentClient.Controllers.length; i++) {
				currentClient.Controllers[i].shift();
			}*/
		}

	}
	
}
