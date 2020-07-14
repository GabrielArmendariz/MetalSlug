package gameObjects;
import com.soundLib.SoundManager;
import com.framework.utils.Random;
import com.collision.platformer.Sides;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import com.gEngine.display.Layer;
import kha.math.FastVector2;

class Enemy extends Entity {
	static private inline var MAX_SPEED:Float = 225;
	var display:Sprite;
	var collision:CollisionBox;
    var collisionGroup:CollisionGroup;

	public function new(layer:Layer, collisions:CollisionGroup, x:Float, y:Float, spriteSource:String) {
		super();
		collisionGroup = collisions;
		display = new Sprite(spriteSource);		
		collision = new CollisionBox();
		collision.userData = this;		
		collision.x = x;
		collision.y = y -  display.height() - 1;
		collision.width = display.width();
        collision.height = display.height() * display.scaleY;
		display.timeline.frameRate = 1 / 10;
		collisionGroup.add(collision);
		layer.addChild(display);
	}

	override public function update(dt:Float):Void {		        
		super.update(dt);
		collision.update(dt);
	}

	public function takeDamage(){
		SoundManager.playFx("EnemyScream1").volume = 0.1;
        display.timeline.playAnimation("die_");
		display.timeline.loop = false;
		collisionGroup.remove(collision);		
	}

	override function render() {
		super.render();
	}
}