
package {
  import flash.events.DatagramSocketDataEvent;
  import flash.net.DatagramSocket;
  import flash.utils.ByteArray;

  public class HostServer {

    private const MAX_WAITING_TIME:int = 30;

    private var udpSocket:DatagramSocket;
    private var clients:Array = [];
    private var controllers:Array = [];
    private var controllersBuffer:Array = [];
    private var frameBuffer:Object = {};
    private var frameTimer:int = 0;
    private var askTimer:int = 0;

    public function HostServer() {
      udpSocket = new DatagramSocket();
      udpSocket.addEventListener(DatagramSocketDataEvent.DATA, onDataReceived);
      udpSocket.bind(1337);
      udpSocket.receive();
      trace("UDP Server started on port 1337");
    }

    private function onDataReceived(e:DatagramSocketDataEvent):void {
      var msg:String = e.data.readUTFBytes(e.data.bytesAvailable);
      var data:Object = JSON.parse(msg);
      var clientIP:String = e.srcAddress;
      var clientPort:int = e.srcPort;

      var clientIndex:int = getClientIndex(clientIP, clientPort);
      if (clientIndex == -1) {
        clients.push({ip: clientIP, port: clientPort});
        controllers.push([]);
        controllersBuffer.push([]);
        clientIndex = clients.length - 1;
        sendUDP({type: "clientID", id: clients.length}, clientIP, clientPort);
        for (var i:int = 0; i < clients.length - 1; i++) {
          sendUDP({type: "otherUserConnected", id: clients.length}, clients[i].ip, clients[i].port);
        }
        frameTimer = 0;
        frameBuffer = new Object();
      }

      if(data.type == "input") {
        if(frameBuffer[data.data.frame] == null) {
          frameBuffer[data.data.frame] = {};
        }
        if(frameBuffer[data.data.frame][data.data.id] == undefined) {
          frameBuffer[data.data.frame][data.data.id] = data.data.input;
        }
      }
      if(data.type == "askFrame") {
        if(frameBuffer[data.frame] != null && frameBuffer[data.frame][data.id] != undefined) {
          sendUDP({type: "update", frameData: frameBuffer[data.frame], frame: data.frame}, clientIP, clientPort);
        }
      }
    }

    public function PERFORMALL():void{
      if(frameBuffer[frameTimer] != null) {
        var allReceived:Boolean = true;
        for (var i:int = 1; i <= clients.length; i++) {
          // If someone hasn't sent their frame data yet
          if(frameBuffer[frameTimer][i] == undefined) {
            allReceived = false;
            askTimer++;
            if(askTimer > MAX_WAITING_TIME) { // Ask every MAX_WAITING_TIME frames if not received
              sendUDP({type: "askFrameServer", frame: frameTimer, id: i}, clients[i - 1].ip, clients[i - 1].port);
            }
            break;
          }
        }
        if(allReceived){
          for (var j:int = 0; j < clients.length; j++) {
            sendUDP({type: "update", frameData: frameBuffer[frameTimer], frame: frameTimer}, clients[j].ip, clients[j].port);
          }
          frameTimer++;
          askTimer = 0;
        }
      }else{
        // If NOBODY has sent their frame data yet
        askTimer++;
        for (var i:int = 1; i <= clients.length; i++) {
          if(askTimer > MAX_WAITING_TIME) { // Ask every MAX_WAITING_TIME frames if not received
            sendUDP({type: "askFrameServer", frame: frameTimer, id: i}, clients[i - 1].ip, clients[i - 1].port);
          }
        }
      }
    }

    private function sendUDP(obj:Object, ip:String, port:int):void {
      var bytes:ByteArray = new ByteArray();
      bytes.writeUTFBytes(JSON.stringify(obj));
      udpSocket.send(bytes, 0, bytes.length, ip, port);
    }

    private function getClientIndex(ip:String, port:int):int {
      for (var i:int = 0; i < clients.length; i++) {
        if (clients[i].ip == ip && clients[i].port == port) return i;
      }
      return -1;
    }
  }
}