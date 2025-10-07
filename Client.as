package {

  import flash.errors.*;
  import flash.events.*;
  import flash.net.Socket;
  import flash.display.MovieClip;
  import flash.text.TextField;

  public class Client extends Socket {

    private var currentInput:InputController;
    private var clientID:int = -1;
    private var stageRef:MovieClip;

    public function Client(ip:String, port:int, stageRef:MovieClip) {
      super();
      this.stageRef = stageRef;
      configureListeners();
      connect(ip, port);
    }

    private function configureListeners():void {
      addEventListener(Event.CLOSE, closeHandler);
      addEventListener(Event.CONNECT, connectHandler);
      addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
      addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
      addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
    }

      
    private function sendRequest():void {
      trace("sendRequest");
      var request:Object = {type: "join"};
      writeObject(request);
      flush();
    }

    private function readResponse():void {
      var response:Object = readObject();
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
        }
      }
      if(response.type == "otherUserConnected") {
        trace("Another user connected with ID: " + response.id);
        stageRef.inputTextFieldVector.push(new TextField());
        stageRef.inputTextFieldVector[response.id - 1].width = 400;
        stageRef.inputTextFieldVector[response.id - 1].height = 30;
        stageRef.inputTextFieldVector[response.id - 1].border = true;
        stageRef.inputTextFieldVector[response.id - 1].x = 100;
        stageRef.inputTextFieldVector[response.id - 1].y = 50 + (40 * (response.id - 1));
        stageRef.addChild(stageRef.inputTextFieldVector[response.id - 1]);
        InputEventsManager.dispatcher.dispatchEvent(new Event(InputEvents.OTHER_USER_CONNECTED));
      }else if(response.type == "update") {
        var controllers:Array = response.controllers;
        for(i = 0; i < controllers.length; i++) {
          var inputStr:String = "User " + (i + 1) + " Inputs: ";
          for each(var inputCode:int in controllers[i]) {
            inputStr += inputCode + " ";
          }
          stageRef.inputTextFieldVector[i].text = inputStr;
        }
      }
    }

    private function closeHandler(event:Event):void {
      trace("closeHandler: " + event);
    }

    private function connectHandler(event:Event):void {
      trace("connectHandler: " + event);
      InputEventsManager.dispatcher.dispatchEvent(new Event(InputEvents.JOINED));
      sendRequest();
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
      trace("ioErrorHandler: " + event);
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
      trace("securityErrorHandler: " + event);
    }

    private function socketDataHandler(event:ProgressEvent):void {
      trace("socketDataHandler: " + event);
      readResponse();
    }

    public function sendInput(input:Array, currentFrame:int):void {
      if(clientID == -1) return; // Not yet assigned an ID
      var response:Object = {type: "input", data: {input: input, id: clientID, frame: currentFrame}};
      writeObject(response);
      flush();
    }
  }

}