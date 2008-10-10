package nGameLib {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.geom.*;

    /**
     * class nlSprite
     * 画像
     */
    public class nlSprite {
        private var misLoaded:Boolean;
        private var misLoadFault:Boolean;
        private var loadLevel:uint;
        private var bm:BitmapData = null;
        private var bitmap:Bitmap = null;
        private var loader:Loader;
        private var _tmpRect:Rectangle = new Rectangle();
        private var _tmpPoint:Point = new Point();
        private var _tmpMatrix:Matrix = new Matrix();
        private var bgColor:uint = 0x00000000;

        // コンストラクタ
        public function nlSprite() {
            misLoaded = false;
            misLoadFault = false;
            loadLevel = 0;
        }

        // 空のスプライトを作成
        public function create(width:int, height:int, transparent:Boolean = true, fillColor:uint = 0):void {
            misLoaded = true;
            misLoadFault = false;
            loadLevel = 0;

            this.bgColor = fillColor;

            this.bitmap = null;
            this.bm = new BitmapData(width, height, transparent, fillColor);
        }

        // 消去
        public function clear():void {
            if (this.bm == null) return;

            this._tmpRect.x = 0;
            this._tmpRect.y = 0;
            this._tmpRect.width = this.width;
            this._tmpRect.height = this.height;

            this.bm.fillRect(this._tmpRect, this.bgColor);
        }

        // リモートから読み込み
        public function load(path:String):void {
            misLoaded = false;
            misLoadFault = false;
            loadLevel = 0;

            this.loader = new Loader();

            with(loader.contentLoaderInfo) {
                addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                addEventListener(ProgressEvent.PROGRESS, onProgress);
                addEventListener(Event.COMPLETE, onComplete);
            }

            this.loader.load(new URLRequest(path));
        }

        // DisplayObjectから読み込み
        public function loadFromDisplayObject(src:DisplayObject):void {
            misLoaded = true;
            misLoadFault = false;
            loadLevel = 0;

            this.bitmap = null;
            this.bm = new BitmapData(src.width, src.height, true, 0);
            this.bm.draw(src);
        }

        // 読み込みステータス

        public function onIOError(evt:IOErrorEvent):void {
            misLoaded = false;
            misLoadFault = true;
            loadLevel = 0;
        }

        public function onProgress(evt:ProgressEvent):void {
            loadLevel = evt.bytesLoaded * 100 / evt.bytesTotal;
        }

        public function onComplete(evt:Event):void {
            this.create(this.loader.width, this.loader.height, true);
            this.bm.draw(loader);

            misLoaded = true;
            loadLevel = 100;
        }

        public function isLoaded():Boolean {
            return misLoaded;
        }

        public function isLoadFault():Boolean {
            return misLoadFault;
        }

        // 0-100
        public function getLoadLevel():uint {
            return loadLevel;
        }

        /////////////////////////////////////////////////

        // 高速描画
        public function bltFast(dst_x:int, dst_y:int, width:uint, height:uint, src:nlSprite, src_x:int, src_y:int):void {
            this._tmpPoint.x = dst_x;
            this._tmpPoint.y = dst_y;

            this._tmpRect.x = src_x;
            this._tmpRect.y = src_y;
            this._tmpRect.width = width;
            this._tmpRect.height = height;

            this.copyPixels(src, this._tmpRect, this._tmpPoint);
        }

        // copyPixelsラッパー
        public function copyPixels(src:nlSprite, sourceRect:Rectangle, destPoint:Point, alpha:nlSprite = null, alphaPoint:Point = null, mergeAlpha:Boolean = false):void {
            if (this.bm == null) return;
            if (src == null) return;
            if (src.getBitmapData() == null) return;

            var al:BitmapData = null;
            if (alpha != null) {
                al = alpha.getBitmapData();
            }

            this.bm.copyPixels(src.getBitmapData(), sourceRect, destPoint, al, alphaPoint, mergeAlpha);
        }

        // 拡大描画
        public function scaleblt(dst_x:int, dst_y:int, width:uint, height:uint, src:nlSprite, src_x:int, src_y:int, scaleX:Number = 1, scaleY:Number = 1):void {
            if (this.bm == null) return;
            if (src == null) return;
            if (src.getBitmapData() == null) return;

            src_x *= scaleX;
            src_y *= scaleY;

            this._tmpRect.x = dst_x;
            this._tmpRect.y = dst_y;
            this._tmpRect.width = width * scaleX;
            this._tmpRect.height = height * scaleY;

            this._tmpMatrix.createBox(scaleX, scaleY, 0, dst_x - src_x, dst_y - src_y);

            this.bm.draw(src.getBitmapData(), this._tmpMatrix, null, BlendMode.NORMAL, this._tmpRect);
        }

        // BitmapDataを取得
        public function getBitmapData():BitmapData {
            return bm;
        }

        // Bitmapを取得
        public function getBitmap():Bitmap {
            if (bm == null) return null;

            if (bitmap == null) {
                bitmap = new Bitmap(bm);
            }
            return bitmap;
        }

        // 幅を取得
        public function get width():uint {
            return this.bm.width;
        }

        // 高さを取得
        public function get height():uint {
            return this.bm.height;
        }
    }

}
