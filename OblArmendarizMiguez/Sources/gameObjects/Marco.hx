package gameObjects;

import com.soundLib.SoundManager;
import com.collision.platformer.CollisionGroup;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;
import kha.math.FastVector2;
import kha.input.KeyCode;
import com.framework.utils.Input;

class Marco extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;
	public var gun:Gun;
	var layer:Layer;
	var maxSpeed = 150;
	var shooting = false;
	var shoot = false;
	var jump = 0;

	public function new(x:Float,y:Float,layer:Layer) {
		super();
		setupSprite(layer,"Protagonist");
		setupCollisionBox(x,y);
		startupGun();
	}

	override function update(dt:Float) {
		if(display.timeline.currentAnimation == "die_"){
			return;
		}		
		collision.velocityX =0;
		if(Input.i.isKeyCodeDown(KeyCode.Left) && collision.x > 0){
			collision.velocityX = -maxSpeed;
			display.scaleX = -Math.abs(display.scaleX);
		}
		if(Input.i.isKeyCodeDown(KeyCode.Right)){
			collision.velocityX = maxSpeed;
			display.scaleX = Math.abs(display.scaleX);
		}
		if(Input.i.isKeyCodePressed(KeyCode.Space)){
			if (collision.isTouching(Sides.BOTTOM) || jump < 2) {
				collision.velocityY = -600;
				jump++;
			}
		}
        if(Input.i.isKeyCodeDown(KeyCode.A)){
            if(!shooting){
				this.shoot = true;
			}
		}

		if(shoot){
			gun.shoot(collision.x, collision.y + 7, getOrientation(), 0);
		}
		if(collision.x < 0){
			collision.velocityX = 0;
			collision.x = 0;
		}
		
		
		
		super.update(dt);
		collision.update(dt);
	}

	override function render() {
		if(display.timeline.currentAnimation == "die_"){
			if(display.timeline.isComplete()){
				display.removeFromParent();
				destroy();
			}
			return;
		}
		display.x = collision.x;
		display.y = collision.y;	
		if(shoot){
			if (display.timeline.currentAnimation == "jump_") {
				display.timeline.playAnimation("jumpShoot_");
			} else {
				display.timeline.playAnimation("shoot_");
			}
			display.timeline.loop = false;
			shooting = true;
			shoot = false;
		}		
		if(shooting){
			if(!display.timeline.isComplete()){
				return;
			}else{
				shooting = false;
				gun.reload();
				if(!gun.hasAmmo()){
					equipGun(new Gun(gun.bulletsCollisions));
					layer.remove(display);
					setupSprite(layer, "Protagonist");
				}
				display.timeline.loop = true;
			}
		}
		if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
			display.timeline.playAnimation("idle");
			jump = 0;
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX != 0) {
			display.timeline.playAnimation("run_");
			jump = 0;
		} else  if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY < 0) {
			display.timeline.playAnimation("jump_");
		}
	}
	

	public function takeDamage(){
		var sound = SoundManager.playFx("MarcoScream");
		sound.volume = 0.3;
		sound.position = 1;
		display.timeline.playAnimation("die_");
		display.timeline.loop = false;
		collision.width = 0;
		collision.height = 0;
	}

	public function equipGun(newGun:Gun){
		gun = newGun;
		addChild(gun);
		layer.remove(display);
		setupSprite(layer, "ProtagonistShotgun");
	}

	private function setupSprite(layer:Layer, sprite:String){
		this.layer = layer;
		display = new Sprite(sprite);
		display.smooth = false;
		display.timeline.playAnimation("run_");
		display.timeline.frameRate=1/10;		
		display.pivotX=display.width()*0.5;
		display.scaleX = display.scaleY = 1;		
		layer.addChild(display);		
	}

	private function setupCollisionBox(x:Float,y:Float){
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collision.x=x;
		collision.y=y - display.height();
		collision.userData = this;
		collision.accelerationY = 2000;
		collision.velocityX = 0;
		collision.maxVelocityY = 800;
	}

	private function startupGun(){
		gun=new Gun(new CollisionGroup());
		addChild(gun);
	}

	private function getOrientation() : Int{
		if (display.scaleX < 0) {
			return -1;
		} 
		return 1;
	}



}
