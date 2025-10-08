package {
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.KeyboardEvent;

  public class CharacterController extends Sprite {

    private const MAX_INPUT_BUFFER:int = 10;
    private const INPUT_DELAY:int = 0;

    private var m_UP:int;
    private var m_DOWN:int;
    private var m_LEFT:int;
    private var m_RIGHT:int;
    private var m_A:int;
    private var m_B:int;

    private var isPressingUp:int = 1;
    private var isPressingDown:int = 2;
    private var isPressingLeft:int = 4;
    private var isPressingRight:int = 8;
    private var isPressingA:int = 16;
    private var isPressingB:int = 32;

    private var input:InputController;

    private var m_inputBuffer:Vector.<int> = new Vector.<int>();
    private var m_mc:sonic_mc;

    public function CharacterController(input:InputController, data:Object = null) {
      this.input = input;
      m_UP = (data && data.UP) ? data.UP : 87;
      m_DOWN = (data && data.DOWN) ? data.DOWN : 83;
      m_LEFT = (data && data.LEFT) ? data.LEFT : 65;
      m_RIGHT = (data && data.RIGHT) ? data.RIGHT : 68;
      m_A = (data && data.A) ? data.A : 79;
      m_B = (data && data.B) ? data.B : 80;
      addChild(m_mc = new sonic_mc());
    }

    public function getInputState(input:Array):int {
      var state:int = 0;
      for each (var keyCode:int in input) {
        switch (keyCode) {
          case m_UP:
            state |= isPressingUp;
            break;
          case m_DOWN:
            state |= isPressingDown;
            break;
          case m_LEFT:
            state |= isPressingLeft;
            break;
          case m_RIGHT:
            state |= isPressingRight;
            break;
          case m_A:
            state |= isPressingA;
            break;
          case m_B:
            state |= isPressingB;
            break;
        }
      }
      return state;
    }

    public function addToInputBuffer(buffer:Array, currentClient:int, frame:int):void {
      if (currentClient < 0 || !buffer || !buffer[currentClient - 1] || frame < 0 || buffer.length <= 0 || buffer[currentClient - 1].length <= 0) return;
      m_inputBuffer.unshift(buffer[currentClient - 1][frame]);
    }

    private function movement():void{
      if(m_inputBuffer.length <= INPUT_DELAY) return;
      if(m_inputBuffer[INPUT_DELAY] & 63) m_mc.gotoAndStop("walk");
      else m_mc.gotoAndStop("idle");
      if (m_inputBuffer[INPUT_DELAY] & isPressingLeft) {
        m_mc.x -= 5;
        m_mc.scaleX = -1;
      }
      if (m_inputBuffer[INPUT_DELAY] & isPressingRight) {
        m_mc.x += 5;
        m_mc.scaleX = 1;
      }
      if (m_inputBuffer[INPUT_DELAY] & isPressingUp) {
        m_mc.y -= 5;
      }
      if (m_inputBuffer[INPUT_DELAY] & isPressingDown) {
        m_mc.y += 5;
      }

    }

    public function PERFORMALL():void {
      movement();
      return;
    }

    public function get InputBuffer():Vector.<int> {
      return m_inputBuffer;
    }
  }
}