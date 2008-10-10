package {
    import nGameLib.nlGameFrame;
    import flash.display.*;

    ////////////////////////////////////////////////////////////
    // 本体

    public class sampleApp extends Sprite {

        private var frame:nlGameFrame;

        // エントリーポイント
        public function sampleApp() {
            stage.frameRate = 30;

            frame = new nlGameFrame(this);
            frame.initScreen(640, 480, 0x00000000); // 画面を初期化
            frame.changeScene(new titleScene());  // 初期シーンを指定
            //            frame.changeScene(new mainScene());  // 初期シーンを指定
            frame.start(); // ゲーム開始
        }
    }

}

import flash.events.*;
import nGameLib.nlScene;
import nGameLib.nlSprite;
import nGameLib.nlInput;
import flash.ui.*;

////////////////////////////////////////////////////////////
// タイトル画面

class titleScene extends nlScene {
    private var image01:nlSprite;
    private var image_loading:nlSprite;

    // loading画像
    [Embed(source='nowloading.gif')]
        private var loadingimage:Class;

    // コンストラクタ
    public function titleScene() {
        this.setFadeIn(false);  // フェードインしない
        image_loading = new nlSprite();
        image_loading.loadFromDisplayObject(new loadingimage());
    }

    // 初期化
    override public function onInit():void {
        image01 = new nlSprite();
        image01.load('title.gif'); // タイトル画像の読み込み
    }

    // loading画面の表示
    override public function onLoading():Boolean {
        canvas.bltFast(540,448,100,32,image_loading,0,0);

        return image01.isLoaded();
    }

    // フレーム毎の処理
    override public function onFrame():void {
        if (input.isKeyPress(nlInput.KEY_BUTTON1)) {
            gameframe.changeScene(new mainScene());  // 初期シーンを指定
        }
    }

    override public function onDraw():void {
        canvas.bltFast(0, 0, 640, 480, image01, 0, 0); // 描画
    }
}

////////////////////////////////////////////////////////////
// ゲームメイン

class mainScene extends nlScene {
    private var image01:nlSprite;
    private var x:int = 320, y:int = 50;   // キャラの座標
    private var screen_x:int = 0, screen_y:int = 0;    // 画面の座標
    private var fallspeed:int = 4; // 落下速度
    private var walkspeed:int = 4; // 移動速度
    private var fallupcount:int = 0; // 上昇速度
    private var isFalling:Boolean = true; // 落下中か？

    [Bindable]
        [Embed(source='chip.gif')]
        private var chip:Class;

    private var mapData:Array = new Array(); // マップデータ
    private static const MAP_WIDTH:uint = 30; // マップ幅
    private static const MAP_HEIGHT:uint = 29; // マップ高

    // コンストラクタ
    public function mainScene() {
    }

    // 初期化
    override public function onInit():void {

        initMapData(); // マップデータ初期化

        image01 = new nlSprite();
        image01.loadFromDisplayObject(new chip());
        //        image01.load('chip.gif'); // マップチップ読み込み
    }

    // フレーム毎の処理
    override public function onFrame():void {
        if (input.isKeyDown(nlInput.KEY_LEFT)) {
            // 左
            for(i=0;i<walkspeed;i++) {
                if ((this.getMapData( (this.x - 1) / 32, (this.y     ) / 32 ) != 1) &&
                        (this.getMapData( (this.x - 1) / 32, (this.y + 31) / 32 ) != 1)) {
                    this.x -= 1;
                } else {
                    break;
                }
            }
        } else if (input.isKeyDown(nlInput.KEY_RIGHT)) {
            // 右
            for(i=0;i<walkspeed;i++) {
                if ((this.getMapData( (this.x + 32) / 32, (this.y     ) / 32 ) != 1) &&
                        (this.getMapData( (this.x + 32) / 32, (this.y + 31) / 32 ) != 1)) {
                    this.x += 1;
                } else {
                    break;
                }
            }
        }

        // ジャンプ
        if ((!isFalling) && (fallupcount == 0)) {
            if (input.isKeyPress(nlInput.KEY_BUTTON1)) {
                this.fallupcount = 15;  // 上昇量
                this.fallspeed = 0;    // 落下を抑制
            }
        }

        var i:int;

        // 足元がなかったら落下
        for(i=0;i<fallspeed;i++) {
            if ((this.getMapData(  this.x       / 32, (this.y + 32) / 32 ) != 1) &&
                    (this.getMapData( (this.x + 31) / 32, (this.y + 32) / 32 ) != 1)) {
                this.y += 1;
                isFalling = true;
            } else {
                isFalling = false;
                this.fallspeed = 1;
                break;
            }
        }

        // 上昇
        for(i=0;i<fallupcount;i++) {
            if ((this.getMapData(  this.x       / 32, (this.y - 1) / 32 ) != 1) &&
                    (this.getMapData( (this.x + 31) / 32, (this.y - 1) / 32 ) != 1)) {
                this.y -= 1;
            } else {
                fallupcount = 1;    // 下に処理させるため1で設定
                break;
            }
        }

        // 下降処理
        if (this.fallspeed > 0) {
            if (this.fallspeed < 10) {
                this.fallspeed ++;
            }
        }

        // 上昇処理
        if (this.fallupcount > 0) {
            this.fallupcount -= 1;
            if (this.fallupcount == 0) { 
                this.fallspeed = 1;
                isFalling = true;
            }
        }
    }

    // フレーム毎の描画
    override public function onDraw():void {
        screen_x = x - 320;
        screen_y = y - 240;
        if (screen_x < 0) screen_x = 0;
        if (screen_y < 0) screen_y = 0;
        if ((screen_x + 640) >= (MAP_WIDTH * 32)) screen_x = MAP_WIDTH * 32 - 640;
        if ((screen_y + 480) >= (MAP_HEIGHT * 32)) screen_y = MAP_HEIGHT * 32 - 480;

        this.drawMapData(); // マップ

        var chr_x:int = x - screen_x;
        var chr_y:int = y - screen_y;

        canvas.bltFast(chr_x, chr_y, 32, 32, image01, 2 * 32, 0); // キャラ
    }

    // 終了
    override public function onEnd():void {
    }

    ////////////////////////////////////////////////////////////

    // マップデータを定義（面倒なのでとりあえず埋め込みで）
    private function initMapData():void {
        mapData[ 0] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
        mapData[ 1] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[ 2] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[ 3] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[ 4] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1];
        mapData[ 5] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[ 6] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[ 7] = [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[ 8] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[ 9] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[10] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[11] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1];
        mapData[12] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[13] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1];
        mapData[14] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1];
        mapData[15] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[16] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1];
        mapData[17] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[18] = [1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[19] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[20] = [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[21] = [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[22] = [1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[23] = [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[24] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1];
        mapData[25] = [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1];
        mapData[26] = [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[27] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1];
        mapData[28] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
    }

    // マップを描画
    private function drawMapData():void {
        var base_y:int = int(screen_y / 32);
        var base_x:int = int(screen_x / 32);
        var ofs_y:int = - int(screen_y % 32);
        var ofs_x:int = - int(screen_x % 32);

        for(var y:int = -1;y < 16;y ++) {
            for(var x:int = -1;x < 21;x ++) {
                canvas.bltFast(x * 32 + ofs_x, y * 32 + ofs_y, 32, 32, image01, getMapData(base_x + x, base_y + y) * 32, 0);
            }
        }
    }

    // マップデータを取得
    private function getMapData(x:int, y:int):uint {
        if ((x < 0) || (y < 0) || (x >= MAP_WIDTH) || (y >= MAP_HEIGHT)) return 1;

        return mapData[y][x];
    }
}
