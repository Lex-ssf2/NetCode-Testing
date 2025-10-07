package
{
    import flash.events.EventDispatcher;
    import __AS3__.vec.Vector;
    import flash.events.Event;
    import __AS3__.vec.*;

    public class InputEventsManager 
    {

        public static var dispatcher:InputEventsManager = new (InputEventsManager)();

        private var _eventDispatcher:EventDispatcher;
        private var _eventList:Vector.<String>;
        private var _functionList:Vector.<Function>;
        private var _useCaptureList:Vector.<Boolean>;

        public function InputEventsManager()
        {
            this._eventDispatcher = new EventDispatcher();
            this._eventList = new Vector.<String>();
            this._functionList = new Vector.<Function>();
            this._useCaptureList = new Vector.<Boolean>();
        }

        public function addEventListener(_arg_1:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
        {
            this._eventDispatcher.addEventListener(_arg_1, listener, useCapture, priority, useWeakReference);
            this._eventList.push(_arg_1);
            this._functionList.push(listener);
            this._useCaptureList.push(useCapture);
        }

        public function removeEventListener(_arg_1:String, listener:Function, useCapture:Boolean=false):void
        {
            var i:int;
            while (i < this._eventList.length)
            {
                if ((((_arg_1 == this._eventList[i]) && (listener == this._functionList[i])) && (this.hasEvent(_arg_1, listener))))
                {
                    this._eventList.splice(i, 1);
                    this._functionList.splice(i, 1);
                    this._useCaptureList.splice(i, 1);
                    this._eventDispatcher.removeEventListener(_arg_1, listener, useCapture);
                    i--;
                };
                i++;
            };
        }

        public function dispatchEvent(event:Event):void
        {
            this._eventDispatcher.dispatchEvent(event);
        }

        public function hasEvent(_arg_1:String, listener:Function):Boolean
        {
            var i:int;
            while (i < this._eventList.length)
            {
                if (((_arg_1 == this._eventList[i]) && (listener == this._functionList[i])))
                {
                    return (true);
                };
                i++;
            };
            return (false);
        }

        public function removeAllEvents():void
        {
            while (this.Count > 0)
            {
                this.removeEventListener(this._eventList[0], this._functionList[0], this._useCaptureList[0]);
                this._eventList.splice(0, 1);
                this._functionList.splice(0, 1);
                this._useCaptureList.splice(0, 1);
            };
        }

        public function get Count():int
        {
            return (this._eventList.length);
        }

    }
}