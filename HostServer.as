package {
  import flash.net.ServerSocket;
  import flash.events.Event;
  import flash.events.ServerSocketConnectEvent;

  public class HostServer {
	  
    private var clients:Array = [];
    private var serverSocket:ServerSocket;

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
    }

    public function get ServerHost():ServerSocket {
      return serverSocket;
    }
  }
}