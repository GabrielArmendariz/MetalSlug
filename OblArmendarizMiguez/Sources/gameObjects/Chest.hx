package gameObjects;

import com.collision.platformer.CollisionBox;
import com.gEngine.display.Layer;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Sprite;

class Chest extends Entity
{
    public var collisions:CollisionGroup;
    public var display:Sprite;
    var collision:CollisionBox;

	public function new(x:Float,y:Float,collisions:CollisionGroup, layer:Layer) 
	{
		super();
        this.collisions = collisions;
        setupSprite(layer);
        setupCollision(x,y,collisions);
	}

	public function open(bulletCollisions:CollisionGroup):Gun
	{
        display.timeline.playAnimation("open_");
		display.timeline.loop = false;
		return new MachineGun(bulletCollisions);
    }

    override function update(dt:Float) {
		super.update(dt);
		collision.update(dt);
	}

	override function render() {
		display.x = collision.x;
		display.y = collision.y;	
	}
    
    private function setupSprite(layer:Layer) {
        display = new Sprite("Chest");
		display.smooth = false;
		display.timeline.playAnimation("closed");
		display.timeline.frameRate=1/10;		
		display.scaleX = display.scaleY = 2;		
		layer.addChild(display);
    }

    private function setupCollision(x:Float,y:Float,collisions:CollisionGroup) {
        collision = new CollisionBox();
		collision.userData = this;		
		collision.x = x;
		collision.y = y -  display.height() - 1;
		collision.width = display.width();
        collision.height = display.height() * display.scaleY;
		collisions.add(collision);
    }
}