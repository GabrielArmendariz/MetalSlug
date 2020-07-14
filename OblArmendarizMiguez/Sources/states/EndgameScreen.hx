package states;

import com.gEngine.display.Sprite;
import kha.Color;
import com.loading.basicResources.JoinAtlas;
import com.gEngine.display.StaticLayer;
import com.gEngine.GEngine;
import com.gEngine.display.Text;
import kha.Assets;
import com.loading.basicResources.FontLoader;
import com.gEngine.display.Layer;
import kha.input.KeyCode;
import com.framework.utils.Input;
import kha.math.FastVector2;
import com.loading.basicResources.ImageLoader;
import com.loading.Resources;
import com.framework.utils.State;

class EndgameScreen extends State {
    var score:String;
    var outcomePicture:String;

    public function new(score:String, image:String) {
        super();
        this.score=score;
        this.outcomePicture = image;
    }

    override function load(resources:Resources) {
        var atlas:JoinAtlas=new JoinAtlas(1024,1024);
        atlas.add(new ImageLoader(outcomePicture));
        atlas.add(new FontLoader(Assets.fonts._04B_03__Name,30));
        resources.add(atlas);
    }

    override function init() {
        var image=new Sprite(outcomePicture);
        image.x=GEngine.virtualWidth*0.5-image.width()*0.5;
        image.y=100;
        stage.addChild(image);
        var scoreDisplay=new Text(Assets.fonts._04B_03__Name);
        scoreDisplay.text="Your score is "+score;
        scoreDisplay.x=GEngine.virtualWidth/2-scoreDisplay.width()*0.5;
        scoreDisplay.y=GEngine.virtualHeight/2;
        scoreDisplay.color=Color.Red;
        stage.addChild(scoreDisplay);
    }

    var time:Float=0;
    var targetPosition:FastVector2;
    
    override function update(dt:Float) {
        super.update(dt);
        if(Input.i.isKeyCodePressed(KeyCode.Return)){
            changeState(new GameState("Mapa1_tmx","marioPNG",17,0));
        }

    }
}