package {
  import flash.net.ServerSocket;
  import flash.events.Event;
  import flash.events.ServerSocketConnectEvent;
  import flash.events.ProgressEvent;
  import flash.net.Socket;

  public class HostServer {
	  
    private var clients:Array = [];
    private var serverSocket:ServerSocket;
    private var controllers:Array = [];
    private var controllersBuffer:Array = [];

    public function HostServer() {
      super();
      try {
        serverSocket = new ServerSocket();
        serverSocket.bind(1337);
        serverSocket.listen();
        serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onClientConnect);
        trace("Server started on port 1337");
      } catch (error:Error) {
        trace("Error starting server: " + error.message);
      }
    }

    private function onClientConnect(e:ServerSocketConnectEvent):void {
      trace("Client connected: " + e.socket.remoteAddress + ":" + e.socket.remotePort);
      clients.push(e.socket);
      e.socket.writeObject({ type: "clientID", id: clients.length });
      e.socket.flush();
      e.socket.addEventListener(ProgressEvent.SOCKET_DATA, onClientData);
      controllers.push(new Array());
      controllersBuffer.push(new Array());
      for each (var client:Socket in clients) {
        if (client != e.socket) {
          client.writeObject({ type: "otherUserConnected", id: clients.length });
          client.flush();
        }
      }
      for each (var array:Array in controllers) {
       array.length = 0;
      }
      for each (var buffer:Array in controllersBuffer) {
       buffer.length = 0;
      }
    }

    private function onClientData(e:ProgressEvent):void {
      var socket:Socket = e.target as Socket;
      if (socket.bytesAvailable > 0) {
        var data:Object = socket.readObject();
        if(data.type == "input") {
          var clientIndex:int = data.data.id - 1;
          if (clientIndex != -1) {
            controllers[clientIndex] = data.data.input;
            controllersBuffer[clientIndex] = controllers[clientIndex].concat(data.data.input);
          }
        }
      }
    }

    public function PERFORMALL():void {
      if(clients.length == 0) return;
      var allControllersHaveSameLength:Boolean = true;
      for each(var buffer:Array in controllersBuffer) {
        if(buffer.length != controllersBuffer[0].length) {
          allControllersHaveSameLength = false;
          break;
        }
      }
      if(!allControllersHaveSameLength) return;

      for each (var client:Socket in clients) {
        client.writeObject({ type: "update", controllers: controllers });
        client.flush();
      }
    }

    public function get ServerHost():ServerSocket {
      return serverSocket;
    }
  }
}