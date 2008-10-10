package nGameLib {
    import flash.display.*;
    import flash.events.*;
    import nGameLib.nlSprite;
    import nGameLib.nlGameFrame;
    import nGameLib.nlInput;

    /**
     * class nlScene
     * 各ゲームシーンの基底クラス
     */
    public class nlScene {
        private var pausing:Boolean;
        protected var canvas:nlSprite;
        protected var input:nlInput;
        protected var gameframe:nlGameFrame;

        // フェード設定
        private var fadeIn:Boolean = true;
        private var fadeOut:Boolean = true;
        private var fadeSpeed:uint = 60;

        // コンストラクタ
        public function nlScene() {
            pausing = false;
        }

        // オーバーライドして使う関数郡

        // 初期化
        public function onInit():void {}

        // 毎フレームの処理
        public function onFrame():void {}

        // 毎フレームの描画
        public function onDraw():void {}

        // 終了処理
        public function onEnd():void {}

        // Loading処理（trueでLoading終了）
        public function onLoading():Boolean { return true; }

        // その他

        // 一時停止中か？
        public function isPausing():Boolean {
            return pausing;
        }

        // 一時停止
        public function Pause():void {
            pausing = true;
        }

        // 再開
        public function Resume():void {
            pausing = false;
        }

        // このシーンでフェードアウトするか設定
        public function setFadeOut(mode:Boolean):void {
            this.fadeOut = mode;
        }

        // このシーンでフェードインするか設定
        public function setFadeIn(mode:Boolean):void {
            this.fadeIn = mode;
        }

        // フェードの速度を指定（フレーム数）
        public function setFadeSpeed(speed:uint):void {
            this.fadeSpeed = speed;
        }

        // nlGrameFrameが主に使う関数郡

        // canvasの設定
        public function setCanvas(canvas:nlSprite):void {
            this.canvas = canvas;
        }

        // gameframeの設定
        public function setGameFrame(frame:nlGameFrame):void {
            this.gameframe = frame;
        }

        // inputの設定
        public function setInput(input:nlInput):void {
            this.input = input;
        }

        public function get isFadeOut():Boolean {
            return this.fadeOut;
        }

        public function get isFadeIn():Boolean {
            return this.fadeIn;
        }

        public function getFadeSpeed():uint {
            return this.fadeSpeed;
        }

        // 予備

        public function onKeyDown(evt:KeyboardEvent):void {
        }

        public function onKeyUp(evt:KeyboardEvent):void {
        }

        public function onClick(evt:MouseEvent):void {
        }

        public function onDblClick(evt:MouseEvent):void {
        }

        public function onMouseMove(evt:MouseEvent):void {
        }

        public function onMouseDown(evt:MouseEvent):void {
        }

        public function onMouseUp(evt:MouseEvent):void {
        }
    }

}
