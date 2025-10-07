package
{
    import flash.events.Event;
    public class InputEvents extends Event 
    {

        public static const KEY_DOWN:String = "InputEvents::keyDown";
        public static const KEY_UP:String = "InputEvents::keyUp";
        public static const JOINED:String = "InputEvents::joined";

        public var data:Object;

        public function InputEvents(_arg_1:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(_arg_1, bubbles, cancelable);
            this.data = ((data) || ({}));
        }

    }
}