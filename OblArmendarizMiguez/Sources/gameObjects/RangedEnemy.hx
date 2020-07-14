package gameObjects;

import com.framework.utils.Random;
import com.collision.platformer.Sides;
import com.collision.platformer.CollisionGroup;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import com.gEngine.display.Layer;
import kha.math.FastVector2;
import gameObjects.Enemy;

/**
 * ...
 * @author Joaquin
 */
class RangedEnemy extends Enemy {
	private static inline var SHOOTINGRADIO:Float = 200;
	private static inline var MAX_SPEED:Float = 150;
    var gun:Gun;	
	var shooting = false;
	var bulletsShot = 0;

	public function new(layer:Layer, collisions:CollisionGroup, bulletCollisions:CollisionGroup, x:Float, y:Float) {
		super(layer,collisions,x,y,"RangedEnemy");
		collisionGroup = collisions;	
		display.scaleX = display.scaleY = 1.2;
		display.timeline.playAnimation("idle");
		display.pivotX=display.width()*0.7;
		collision.x = x + display.width()/2;
		collision.y = y -  display.height() - 1;
		collision.width = 29;
		collision.height = display.height() * display.scaleY;
        gun=new Gun(bulletCollisions);
		addChild(gun);
	}

	override public function update(dt:Float):Void {
		if(display.timeline.currentAnimation == "die"){
			return;
        }
		var target:Marco = GGD.marco;
        var vecX= target.collision.x-collision.x;
		var vecY= (target.collision.y + target.display.height()/2) - (collision.y + (display.height() * display.scaleY)/2);
		shooting = vecX*vecX+vecY*vecY<SHOOTINGRADIO*SHOOTINGRADIO;
		if(display.timeline.currentAnimation == "attack_" && display.timeline.currentFrame == 8){
			shoot();
		}
		if(display.timeline.currentAnimation == "attack_" && display.timeline.currentFrame == 10){
			shooting = false;
			bulletsShot = 0;
		}
		super.update(dt);
	}

	private function shoot (){
		bulletsShot++;
		if(bulletsShot == 1){
			var target:Marco = GGD.marco;
			var vecX= target.collision.x-collision.x;
			var vecY= (target.collision.y + target.display.height()/2) - (collision.y + (display.height() * display.scaleY)/2);
			var dir:FastVector2 = new FastVector2(vecX , vecY);
			dir.setFrom(dir.normalized());
			display.scaleX = Math.abs(display.scaleX);
			if(dir.x > 0){
				display.scaleX = -Math.abs(display.scaleX);
			}
			gun.shoot(collision.x, collision.y + (display.height() * display.scaleY)/2 , dir.x, dir.y);
		}		
	}

	override function render() {
		display.x = collision.x - display.width()/2;
		display.y = collision.y;
		if(display.timeline.currentAnimation == "die_"){
			if(display.timeline.isComplete()){
				display.removeFromParent();
				die();
			}
			return;
		}
		if(shooting){
			display.timeline.playAnimation("attack_");
			display.timeline.loop =  false;
		}
		else if(display.timeline.isComplete()){
			bulletsShot = 0;
			display.timeline.playAnimation("idle");
			display.timeline.loop =  true;
		}		
		super.render();
	}
}