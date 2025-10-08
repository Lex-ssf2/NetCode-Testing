package
{
    import flash.events.Event;
    public class InputEvents extends Event 
    {

        public static const KEY_DOWN:String = "InputEvents::keyDown";
        public static const KEY_UP:String = "InputEvents::keyUp";
        public static const JOINED:String = "InputEvents::joined";
        public static const OTHER_USER_CONNECTED:String = "InputEvents::otherUserConnected";
        public static const HAS_SPAWNED:String = "InputEvents::hasSpawned";
        public static const HAS_PRESSED_A:String = "InputEvents::hasPressedA";
        public static const HAS_PRESSED_B:String = "InputEvents::hasPressedB";

        public var data:Object;

        public function InputEvents(_arg_1:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(_arg_1, bubbles, cancelable);
            this.data = ((data) || ({}));
        }

    }
}