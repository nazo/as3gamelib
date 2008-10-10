package nGameLib {
    import flash.events.*;
    import nGameLib.nlScene;
    import nGameLib.nlSprite;
    import nGameLib.nlInput;
    import flash.display.*;
    import flash.utils.setTimeout;

    /*
     * class nlGameFrame
     * ゲーム進行を管理するクラス
     */

    public class nlGameFrame {
        private var curScene:nlScene = null;
        private var nextScene:nlScene = null;
        private var fps:uint = 60;
        private var isLoadScene:Boolean = false;

        //        private var canvas:nlSprite;
        //        private var canvasBitmap:Bitmap;
        private var canvas:Array = new Array(2);
        private var canvasBitmap:Array = new Array(2);
        private var curCanvas:int = 0;

        private var primary:Sprite;
        private var stage:Stage;
        private var input:nlInput = new nlInput();

        // フェード関連
        private var fadeMode:int = 0;
        private var fadeCount:int = 0;
        private var fadeRect:Shape;

        // コンストラクタ
        public function nlGameFrame(primary:Sprite) {
            this.primary = primary;
            this.stage = primary.stage;
            this.stage.scaleMode = StageScaleMode.NO_SCALE;
        }

        // 画面初期化
        public function initScreen(width:uint, height:uint, bgcolor:uint):void {
            this.canvas[0] = new nlSprite();
            this.canvas[0].create(width, height, false, bgcolor);
            this.canvasBitmap[0] = this.canvas[0].getBitmap();
            this.canvas[1] = new nlSprite();
            this.canvas[1].create(width, height, false, bgcolor);
            this.canvasBitmap[1] = this.canvas[1].getBitmap();

            this.fadeRect = new Shape();
            this.fadeRect.alpha = 0;
            this.fadeRect.graphics.beginFill(bgcolor);     //背景色
            this.fadeRect.graphics.drawRect(0,0,width,height);    //XY座標,幅,高さ
            this.fadeRect.graphics.endFill();            //塗り潰し終了
            this.primary.addChild(this.fadeRect);

            //            this.canvas = new nlSprite();
            //            this.canvas.create(width, height, false, bgcolor);
            //            this.canvasBitmap = this.canvas.getBitmap();
            //            this.primary.addChild(this.canvasBitmap);
        }

        public function getCanvas():nlSprite {
            return this.canvas[curCanvas];
            //            return this.canvas;
        }

        // ゲーム開始
        public function start():void {
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
            this.stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);

            // this.stage.addEventListener(MouseEvent.CLICK, this.onClick);  
            // this.stage.addEventListener(MouseEvent.DOUBLE_CLICK, this.onDblClick);  
            // this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);  
            // this.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);  
            // this.stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);  

            this.primary.addChild(this.canvasBitmap[1 - curCanvas]);
            this.stage.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        }

        // 毎フレームの処理
        private function onEnterFrame(event:Event):void {
            this.input.calcFrame();
            if (this.curScene != null) {
                this.curScene.setCanvas(this.canvas[curCanvas]);
            }

            // Loading画面を表示
            if (this.isLoadScene) {
                if ( this.curScene.onLoading() ) {
                    this.isLoadScene = false;
                }
                return;
            }

            // シーン切り替え
            if (this.fadeMode == 1) {
                this.fadeCount ++;
                this.fadeRect.alpha = this.fadeCount / this.curScene.getFadeSpeed();
                if ((this.fadeCount >= this.curScene.getFadeSpeed()) || (!this.curScene.isFadeOut)) {
                    if (this.nextScene != null) {
                        if (this.curScene != null) {
                            this.curScene.onEnd();
                            this.curScene = null;
                        }
                        this.initScene();
                        this.fadeCount = 0;
                        this.fadeMode = 2;
                    }
                }
            } else if (this.fadeMode == 2) {
                this.fadeCount ++;
                this.fadeRect.alpha = (this.curScene.getFadeSpeed() - this.fadeCount) / this.curScene.getFadeSpeed();
                if ((this.fadeCount >= this.curScene.getFadeSpeed()) || (!this.curScene.isFadeIn)) {
                    this.fadeCount = 0;
                    this.fadeMode = 0;
                }
            } else {
                // メイン描画
                if (!this.curScene.isPausing()) {
                    this.curScene.onFrame();
                }
            }

            this.curScene.onDraw();

            this.primary.addChildAt(this.canvasBitmap[curCanvas], 0);
            curCanvas = 1 - curCanvas;
            this.primary.removeChild(this.canvasBitmap[curCanvas]);
            this.canvas[curCanvas].clear();
        }

        // シーン切り替え
        public function changeScene(scene:nlScene):void {
            this.setSceneInfo(scene);
            this.nextScene = scene;

            if (this.curScene != null) {
                this.fadeMode = 1;
                this.fadeCount = 0;
            } else {
                this.initScene();
                this.fadeMode = 2;
                this.fadeCount = 100;
            }
        }

        // シーン呼び出し（未実装）
        public function callScene(scene:nlScene):void {
            this.setSceneInfo(scene);
            this.nextScene = scene;
        }

        public function initScene():void {
            this.curScene = this.nextScene;
            this.nextScene = null;
            this.isLoadScene = true;
            this.curScene.onInit();
        }

        private function setSceneInfo(scene:nlScene):void {
            scene.setCanvas(this.canvas[curCanvas]);
            scene.setInput(this.input);
            scene.setGameFrame(this);
        }

        /////////////////////////////////////////////
        // 入力

        private function onKeyDown(evt:KeyboardEvent):void {
            this.input.onKeyDown(evt);
            if (this.curScene != null) {
                this.curScene.onKeyDown(evt);
            }
        }

        private function onKeyUp(evt:KeyboardEvent):void {
            this.input.onKeyUp(evt);
            if (this.curScene != null) {
                this.curScene.onKeyUp(evt);
            }
        }
    }

}
