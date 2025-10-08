
package {
  import flash.events.DatagramSocketDataEvent;
  import flash.net.DatagramSocket;
  import flash.utils.ByteArray;
  import flash.display.MovieClip;
  import flash.text.TextField;
  import flash.events.Event;

  public class Client {

    private const MAX_RESEND:int = 5;

    private var udpSocket:DatagramSocket;
    private var serverIP:String;
    private var serverPort:int;
    private var currentInput:InputController;
    private var clientID:int = -1;
    private var stageRef:MovieClip;
    private var actualControllers:Array = new Array();
    private var canSendAgain:Boolean = true;

    public function Client(ip:String, port:int, stageRef:MovieClip) {
      this.serverIP = ip;
      this.serverPort = port;
      this.stageRef = stageRef;
      udpSocket = new DatagramSocket();
      udpSocket.addEventListener(DatagramSocketDataEvent.DATA, onDataReceived);
      udpSocket.bind();
      udpSocket.receive();
      sendRequest();
    }

    private function sendRequest():void {
      trace("sendRequest UDP");
      var request:Object = {type: "join"};
      sendUDP(request);
    }

    private function sendUDP(obj:Object):void {
      var bytes:ByteArray = new ByteArray();
      bytes.writeUTFBytes(JSON.stringify(obj));
      udpSocket.send(bytes, 0, bytes.length, serverIP, serverPort);
    }

    private function onDataReceived(e:DatagramSocketDataEvent):void {
      var msg:String = e.data.readUTFBytes(e.data.bytesAvailable);
      var response:Object = JSON.parse(msg);
      if (response.type == "clientID") {
        trace("Assigned Client ID: " + response.id);
        clientID = response.id;
        for(var i:int = 0; i < clientID; i++) {
          stageRef.inputTextFieldVector.push(new TextField());
          stageRef.inputTextFieldVector[i].width = 400;
          stageRef.inputTextFieldVector[i].height = 30;
          stageRef.inputTextFieldVector[i].border = true;
          stageRef.inputTextFieldVector[i].x = 100;
          stageRef.inputTextFieldVector[i].y = 50 + (40 * i);
          stageRef.addChild(stageRef.inputTextFieldVector[i]);
          actualControllers.push([]);
        }
        InputEventsManager.dispatcher.dispatchEvent(new Event(InputEvents.HAS_SPAWNED));
      }
      else if(response.type == "otherUserConnected") {
        trace("Another user connected with ID: " + response.id);
        stageRef.inputTextFieldVector.push(new TextField());
        stageRef.inputTextFieldVector[response.id - 1].width = 400;
        stageRef.inputTextFieldVector[response.id - 1].height = 30;
        stageRef.inputTextFieldVector[response.id - 1].border = true;
        stageRef.inputTextFieldVector[response.id - 1].x = 100;
        stageRef.inputTextFieldVector[response.id - 1].y = 50 + (40 * (response.id - 1));
        stageRef.addChild(stageRef.inputTextFieldVector[response.id - 1]);
        actualControllers.push([]);
        for each(var controller:Array in actualControllers)
        {
          controller.length = 1;
        }
        InputEventsManager.dispatcher.dispatchEvent(new Event(InputEvents.OTHER_USER_CONNECTED));
        canSendAgain = true;
      }else if(response.type == "update") {
        for(var j:int = 0; j < actualControllers.length; j++) {
          while(actualControllers[j].length <= response.frame) {
            actualControllers[j].push(-1);
          }
          if(actualControllers[j][response.frame] == -1 && response.frameData[j + 1] != undefined) {
            actualControllers[j][response.frame] = response.frameData[j + 1];
          }
        }
      }
    }

    public function sendInput(input:int, currentFrame:int):void {
      /*var allControllersHaveSameLength:Boolean = allControllersHaveSameLength();
      if(!allControllersHaveSameLength) trace("Waiting for all controllers to sync...");
      if(clientID == -1 || !allControllersHaveSameLength || !canSendAgain) return;*/
      var response:Object = {type: "input", data: {input: input, id: clientID, frame: currentFrame}};
      for (var i:int = 0; i < MAX_RESEND; i++) {
        sendUDP(response);
      }
    }

    public function get Controllers():Array {
      return actualControllers;
    }

    public function get ClientID():int {
      return clientID;
    }

    public function allControllersHaveSameLength():Boolean {
      var allControllersHaveSameLength:Boolean = true;
      for each(var controller:Array in actualControllers)
      {
        if(controller.length < actualControllers[clientID - 1].length)
        {
          allControllersHaveSameLength = false;
          break;
        }
      }
      return allControllersHaveSameLength;
    }
  }
}