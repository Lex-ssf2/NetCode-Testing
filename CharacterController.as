package {
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.KeyboardEvent;

  public class CharacterController extends Sprite {

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

    public function CharacterController(input:InputController , data:Object = null) {
      this.input = input;
      m_UP = (data && data.UP) ? data.UP : 87;
      m_DOWN = (data && data.DOWN) ? data.DOWN : 83;
      m_LEFT = (data && data.LEFT) ? data.LEFT : 65;
      m_RIGHT = (data && data.RIGHT) ? data.RIGHT : 68;
      m_A = (data && data.A) ? data.A : 79;
      m_B = (data && data.B) ? data.B : 80;
    }

    public function getInputState():int {
      var state:int = 0;
      var buffer:Array = input.getBuffer();
      for each (var keyCode:int in buffer) {
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

    public function PERFORMALL():void {
      m_inputBuffer.unshift(getInputState());
      if (m_inputBuffer.length > 10) {
        m_inputBuffer.pop();
      }
      return;
    }

    public function get InputBuffer():Vector.<int> {
      return m_inputBuffer;
    }
  }
}