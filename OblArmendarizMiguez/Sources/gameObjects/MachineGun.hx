package gameObjects;

import com.soundLib.SoundManager;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionGroup;

class MachineGun extends Gun
{
	private var gap = 0;

	public function new(collisions:CollisionGroup) 
	{
		super(collisions);
        ammo = 18;
        maxBulletsPerShot = 3;
	}

	override function shoot(aX:Float, aY:Float,dirX:Float,dirY:Float):Void
	{
		SoundManager.playMusic("MachinegunShot",false);
		SoundManager.musicVolume(0.1);
		while(bulletsShot < maxBulletsPerShot && ammo != 0){
			var bullet:Bullet=cast recycle(Bullet);
			bulletsShot++;
			bullet.shoot(aX+gap,aY,dirX,dirY,bulletsCollisions);
			gap+=35;
			ammo--;
		}
		gap = 0;		
	}		
}