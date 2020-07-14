package gameObjects;

import com.soundLib.SoundManager;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionGroup;

class Gun extends Entity
{
	public var bulletsCollisions:CollisionGroup;
	public var ammo:Int;
	private var maxBulletsPerShot:Int;
	private var bulletsShot:Int;

	public function new(collisions:CollisionGroup) 
	{
		super();
		pool=true;
		bulletsCollisions=collisions;
		ammo = -1;
		bulletsShot = 0;
		maxBulletsPerShot = 1;
	}

	public function shoot(aX:Float, aY:Float,dirX:Float,dirY:Float):Void
	{
		if(bulletsShot < maxBulletsPerShot && ammo != 0){
			var bullet:Bullet=cast recycle(Bullet);
			bulletsShot++;
			SoundManager.playMusic("GunShot",false);
			SoundManager.musicVolume(0.1);
			bullet.shoot(aX,aY,dirX,dirY,bulletsCollisions);
			ammo--;
		}		
	}

	public function hasAmmo():Bool{
		return ammo != 0;
	}
	
	public function reload(){
		bulletsShot = 0;
	}
}