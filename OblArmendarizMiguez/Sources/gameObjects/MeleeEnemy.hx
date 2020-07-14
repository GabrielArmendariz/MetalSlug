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

/**
 * ...
 * @author Joaquin
 */
class MeleeEnemy extends Enemy {
	static private inline var MAX_SPEED:Float = 225;
	var life = 2;
	var maxX:Float;
	var minX:Float;

	public function new(layer:Layer, collisions:CollisionGroup, x:Float, y:Float, maxX:Float, minX:Float) {
		super(layer,collisions,x,y,"MeleeEnemy");
		display.scaleX = display.scaleY = 1.2;
		display.timeline.playAnimation("run_");
		display.pivotX=display.width()*0.5;
        collision.velocityX = MAX_SPEED;
        display.scaleX = -1;
		display.timeline.frameRate = 1 / 10;
		this.maxX = maxX;
		this.minX = minX;
	}

	override public function update(dt:Float):Void {
		if(display.timeline.currentAnimation == "die_"){
			return;
		}		
		var target:Marco = GGD.marco;
		var vecX= target.collision.x+target.collision.width-collision.x;
		if(Math.abs(vecX) <= 25){
			attack();
		}	
        if(collision.x == minX || collision.x < 0){
            display.scaleX = -1;
            collision.velocityX = MAX_SPEED;
        }
        if(collision.x == maxX){
            display.scaleX = 1;
            collision.velocityX = -MAX_SPEED;
        }
		super.update(dt);
	}

	override function takeDamage(){
        life--;
        if(life == 0){
            super.takeDamage();
        }
	}

	override function render() {
		display.x = collision.x;
		display.y = collision.y;
		if(display.timeline.currentAnimation == "die_"){
			if(display.timeline.isComplete()){
				display.removeFromParent();
				die();
			}
			return;
		}
		if(display.timeline.currentAnimation == "attack_" && display.timeline.isComplete()){
			display.timeline.playAnimation("run_");
			display.timeline.loop = true;
		}
		super.render();
	}

	public function attack(){
		display.timeline.playAnimation("attack_");
		display.timeline.loop = false;
	}
}