package nGameLib {
    import flash.display.*;  
    import flash.events.*;
    import flash.ui.*;

    /**
     * class nlInput
     * 入力情報の格納クラス
     */
    public class nlInput {
        public static const KEY_UP:uint      = 1 << 0;
        public static const KEY_DOWN:uint    = 1 << 1;
        public static const KEY_LEFT:uint    = 1 << 2;
        public static const KEY_RIGHT:uint   = 1 << 3;
        public static const KEY_BUTTON1:uint = 1 << 4;
        public static const KEY_BUTTON2:uint = 1 << 5;
        public static const KEY_BUTTON3:uint = 1 << 6;
        public static const KEY_BUTTON4:uint = 1 << 7;
        public static const KEY_BUTTON5:uint = 1 << 8;
        public static const KEY_BUTTON6:uint = 1 << 9;
        public static const KEY_BUTTON7:uint = 1 << 10;
        public static const KEY_BUTTON8:uint = 1 << 11;
        
        private static const MAX_KEY:uint = 12;
        private var curState:uint = 0;
        private var prevState:uint = 0;
        
        private var down:uint = 0;
        private var press:uint = 0;
        private var up:uint = 0;
        
        // キーコンフィグ
        private var keyMap:Object = {
            38:KEY_UP,
            40:KEY_DOWN,
            37:KEY_LEFT,
            39:KEY_RIGHT,
            90:KEY_BUTTON1,
            88:KEY_BUTTON2,
            67:KEY_BUTTON3,
            86:KEY_BUTTON4,
            65:KEY_BUTTON5,
            83:KEY_BUTTON6,
            68:KEY_BUTTON7,
            70:KEY_BUTTON8
        };
        
        public function nlInput() {
        }
        
        public function onKeyDown(evt:KeyboardEvent):void {
            if (keyMap[evt.keyCode] != undefined) {
                curState |= keyMap[evt.keyCode];
            }
        }
        
        public function onKeyUp(evt:KeyboardEvent):void {
            if (keyMap[evt.keyCode] != undefined) {
                curState &= (0xFFFFFFFF ^ keyMap[evt.keyCode]);
            }
        }
        
        public function calcFrame():void {
            down = curState;
            var x:uint = down ^ prevState;
            
            press = down & x;
            up = prevState & x;
            
            prevState = curState;
        }
        
        // 入力チェック
        public function isKeyDown(key:uint):Boolean {
            return ((down & key) != 0);
        }
        
        public function isKeyUp(key:uint):Boolean {
            return ((up & key) != 0);
        }
        
        public function isKeyPress(key:uint):Boolean {
            return ((press & key) != 0);
        }
    }

}
