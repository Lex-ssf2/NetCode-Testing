package {

  import flash.errors.*;
  import flash.events.*;
  import flash.net.Socket;
  public class Client extends Socket {

    public function Client(ip:String, port:int) {
      super();
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
      var request:String = "Hello, World!";
      writeUTFBytes(request);
      flush();
    }

    private function readResponse():void {
      var str:String = readUTFBytes(bytesAvailable);
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
  }

}