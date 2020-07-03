package gameObjects;

import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import kha.math.FastVector2;

class Marco extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;
	public var gun:Gun;
	var direction:FastVector2;
	var maxSpeed = 200;
	var shooting = false;
	var jump = 0;

	public function new(x:Float,y:Float,layer:Layer) {
		super();
		display = new Sprite("Protagonist");
		display.smooth = false;
		display.timeline.playAnimation("ProtagonistRun_");
		display.timeline.frameRate=1/10;

		direction=new FastVector2(0,0);

		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();

		display.pivotX=display.width()*0.5;
		display.scaleX = display.scaleY = 1;

		collision.x=x;
		collision.y=y;

		collision.userData = this;
		collision.accelerationY = 2000;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.9;

		layer.addChild(display);

		gun=new Gun();
		addChild(gun);
	}

	override function update(dt:Float) {
		if(collision.velocityX !=0 || collision.velocityY !=0){
			direction.setFrom(new FastVector2(collision.velocityX,collision.velocityY));
			direction.setFrom(direction.normalized());
		}else{
			if(Math.abs(direction.x)>Math.abs(direction.y)){
				direction.y=0;
			}else{
				direction.x=0;
			}
		}


		super.update(dt);
		collision.update(dt);
	}

	override function render() {
		display.x = collision.x;
		display.y = collision.y;
		
		if (display.timeline.currentAnimation == "ProtagonistShoot_" 
			|| display.timeline.currentAnimation == "ProtagonistJumpShoot_"){
			if(!display.timeline.isComplete()){
				return;
			}
		}

		display.timeline.loop = true;

		if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
			display.timeline.playAnimation("ProtagonistIdle");
			jump = 0;
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX != 0) {
			display.timeline.playAnimation("ProtagonistRun_");
			jump = 0;
		} else  if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY < 0) {
			display.timeline.playAnimation("ProtagonistJump_");
		}

		

		// if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY > 0) {
		// 	display.timeline.playAnimation("fall");
		// } else
	}

	

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD) {
			if (value == 1) {
				collision.accelerationX = -maxSpeed * 4;
				display.scaleX = -Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX < 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.RIGHT_DPAD) {
			if (value == 1) {
				collision.accelerationX = maxSpeed * 4;
				display.scaleX = Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX > 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.A) {
			if (value == 1) {
				if (collision.isTouching(Sides.BOTTOM) || jump < 2) {
					collision.velocityY = -1000;
					jump++;
				}
			}
		}
		if(id == XboxJoystick.X)
		{
			if (value == 1) {
				if(display.timeline.currentAnimation != "ProtagonistShoot_" && display.timeline.currentAnimation != "ProtagonistJumpShoot_"){
						if(display.timeline.currentAnimation == "ProtagonistJump_"){
							display.timeline.playAnimation("ProtagonistJumpShoot_");
						}
						else{
							display.timeline.playAnimation("ProtagonistShoot_");
						}
						gun.shoot(collision.x,collision.y,direction.x,direction.y);						
						display.timeline.loop = false;
					}	
				}
			}
		}

	// 	var s = Math.abs(collision.velocityX / collision.maxVelocityX);
	// 	display.timeline.frameRate = (1 / 30) * s + (1 - s) * (1 / 10);	
	// }

	public function onAxisChange(id:Int, value:Float) {}

	// inline function isWallGrabing():Bool {
	// 	return !collision.isTouching(Sides.BOTTOM) && (collision.isTouching(Sides.LEFT) || collision.isTouching(Sides.RIGHT));
	// }
}
