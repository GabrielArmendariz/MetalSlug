package cinematic;

import kha.Assets;
import com.sequencer.SequenceCode;
import com.gEngine.display.Layer;
import com.gEngine.display.Text;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class Dialog extends Entity {
	var text:String;

	public var collider:CollisionBox;
	public var displayText:Text;
    public var showingText:Bool = false;
    public var playerInside:Bool=false;
    public var sequence:SequenceCode;
    public var currentLetter:Int=0;

	public function new(text:String, x:Float, y:Float, width:Float, height:Float) {
		super();
		this.text = text;
		collider = new CollisionBox();
		collider.x = x;
		collider.y = y;
		collider.userData = this;
		collider.width = width;
		collider.height = height;
		displayText = new Text("Kenney_Pixel");
		displayText.text = text;
		displayText.x = x;
        displayText.y = y;
        sequence=new SequenceCode();
    }
    override function update(dt:Float) {
        super.update(dt);
        sequence.update(dt);
        if(showingText&&!playerInside){
            displayText.removeFromParent();
            showingText=false;
            sequence.flush();
        }
        playerInside=false;
    }

	public function showText(layer:Layer) {
        playerInside=true;
		if (!showingText) {
            currentLetter=0;
			showingText = true;
            layer.addChild(displayText);
            for(i in 0...displayText.letterCount()){
                displayText.getLetter(i).visible=false;
                sequence.addFunction(showLetter);
                sequence.addWait(0.05);
            }
		}
    }

    public function showLetter(dt:Float):Bool {
        displayText.getLetter(currentLetter).visible=true;
        ++currentLetter;
        return true;
    }
}
