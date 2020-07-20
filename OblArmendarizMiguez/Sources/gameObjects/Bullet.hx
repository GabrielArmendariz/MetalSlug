package gameObjects;

import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.gEngine.helper.RectangleDisplay;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;
import com.gEngine.display.Sprite;
import com.gEngine.GEngine;

/**
 * ...
 * @author 
 */
class Bullet extends Entity
{
	public var collision:CollisionBox;
	var display:Sprite;
	var lifeTime:Float = 0;
	var totalLifeTime:Float = 3;
	var originX:Float;
	var displayOffSet = 300;

	public function new() 
	{
		super();
		collision=new CollisionBox();
		collision.width=5;
		collision.height=5;
		collision.userData=this;

		display = new Sprite("Bullet");
	}

	override function limboStart() {
		display.removeFromParent();
		collision.removeFromParent();
	}

	override function update(dt:Float) {
		lifeTime+=dt;
		if(lifeTime > totalLifeTime){
			die();
		}
		collision.update(dt);
		display.x=collision.x;
		display.y=collision.y;
		var traveledDistance = display.x - originX;
		if(originX < displayOffSet){
			if(traveledDistance > displayOffSet*2 - originX){
				die();
			}
		}else if(traveledDistance > displayOffSet){
			die();
		}

		
		super.update(dt);
	}
	
	public function shoot(x:Float, y:Float,dirX:Float,dirY:Float,bulletsCollision:CollisionGroup):Void
	{
		lifeTime = 0;
		collision.x=x;
		collision.y=y;
		collision.velocityX = 1000 * dirX;
		collision.velocityY = 1000 * dirY;
		bulletsCollision.add(collision);
		GGD.simulationLayer.addChild(display);
		originX = x;
	}
}