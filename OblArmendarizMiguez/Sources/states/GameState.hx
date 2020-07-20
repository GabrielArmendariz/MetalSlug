package states;

import cinematic.Dialog;
import com.soundLib.SoundManager;
import com.loading.basicResources.SoundLoader;
import com.collision.platformer.CollisionBox;
import format.tmx.Data.TmxImageLayer;
import com.loading.basicResources.FontLoader;
import com.gEngine.display.Text;
import com.gEngine.display.StaticLayer;
import gameObjects.Bullet;
import com.collision.platformer.ICollider;
import kha.Assets;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import com.gEngine.display.Sprite;
import format.tmx.Data.TmxObject;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionEngine;
import gameObjects.*;
import com.loading.basicResources.TilesheetLoader;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import com.collision.platformer.Tilemap;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;
import com.loading.basicResources.SparrowLoader;
import com.loading.basicResources.ImageLoader;
import com.collision.platformer.CollisionGroup;
import com.gEngine.GEngine;
import GlobalGameData.GGD;

class GameState extends State {

	var screenWidth:Int;
	var screenHeight:Int;
	var worldMap:Tilemap;
	var marco:Marco;
	var simulationLayer:Layer;
	var hudLayer:StaticLayer;
	var enemyCollisions:CollisionGroup;
	var enemyBullets:CollisionGroup;
	var chestCollisions:CollisionGroup;
	var spikesCollisions:CollisionGroup;
	var finishCollisions:CollisionGroup;
	var doorCollisions:CollisionGroup;
	var dialogCollision:CollisionGroup;
	var portrait:Sprite;
	var weapon:Sprite;
	var scoreDisplay:Text;
	var ammo:Text;
	var ammoCount:Text;
	var score:Int;
	var map:String = "Mapa1_tmx";
	var tileset:String = "marioPNG";
	var tileSize:Int = 17;
	var complete = false;
	var nextMapName:String;

	public function new(room:String = null, tileset:String = null, tileSize:Int = null, score:Int) {
		super();
		if(room != null){
			map = room;
			this.tileset = tileset;
			this.tileSize = tileSize;
			this.score = score;
		}else{
			this.score = 0;
		}		
	}

	override function load(resources:Resources) {
		screenWidth = GEngine.i.width;
        screenHeight = GEngine.i.height;
		resources.add(new DataLoader(map));
		resources.add(new SoundLoader("BGM",false));
		resources.add(new SoundLoader("MarcoScream"));
		resources.add(new SoundLoader("EnemyScream1"));
		resources.add(new SoundLoader("EnemyScream2"));
		resources.add(new SoundLoader("MissionComplete"));
		resources.add(new SoundLoader("GunShot"));
		resources.add(new SoundLoader("MachinegunShot"));
		resources.add(new SoundLoader("HeavyMachinegun"));
		var atlas = new JoinAtlas(4096, 4096);
		atlas.add(new SparrowLoader("Protagonist", "Protagonist_xml"));
		atlas.add(new SparrowLoader("ProtagonistShotgun", "ProtagonistShotgun_xml"));
		atlas.add(new SparrowLoader("RangedEnemy", "RangedEnemy_xml"));
		atlas.add(new SparrowLoader("MeleeEnemy", "MeleeEnemy_xml"));
		atlas.add(new SparrowLoader("Chest", "Chest_xml"));
		atlas.add(new ImageLoader("Bullet"));
		atlas.add(new ImageLoader("HUDPortrait"));
		atlas.add(new ImageLoader("HUDGun"));
		atlas.add(new ImageLoader("HUDMachineGun"));
		atlas.add(new TilesheetLoader(tileset, tileSize, tileSize, 0));
		atlas.add(new FontLoader(Assets.fonts._04B_03__Name,30));
		atlas.add(new FontLoader("Kenney_Pixel",18));
		atlas.add(new ImageLoader("Desert"));		
		atlas.add(new ImageLoader("CloudAndMountain"));
		resources.add(atlas);
	}

	override function init() {
		stageColor(0.5, 0.5, 0.5);
		simulationLayer = new Layer();
		GGD.simulationLayer = simulationLayer;
		hudLayer = new StaticLayer();
		stage.addChild(simulationLayer);
		stage.addChild(hudLayer);		
		enemyCollisions = new CollisionGroup();
		enemyBullets = new CollisionGroup();
		chestCollisions = new CollisionGroup();
		spikesCollisions = new CollisionGroup();
		finishCollisions = new CollisionGroup();
		doorCollisions = new CollisionGroup();
		dialogCollision = new CollisionGroup();
		initHud();
		worldMap = new Tilemap(map, 1);
		worldMap.init(function(layerTilemap, tileLayer) {
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite(tileset)));
		}, parseMapObjects);
		stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 16 * 1, worldMap.heightInTiles * 16 * 1);
		stage.defaultCamera().scale = 2.1;
		SoundManager.playMusic("BGM",true);
		SoundManager.musicVolume(0.1);
	}


	function initHud(){
		portrait = new Sprite("HUDPortrait");
		hudLayer.addChild(portrait);
		portrait.x = 10;
		portrait.y = 35;
		weapon = new Sprite("HUDGun");
		hudLayer.addChild(weapon);
		weapon.x = 120;
		weapon.y = 50;
		scoreDisplay= new Text(Assets.fonts._04B_03__Name);
		scoreDisplay.x=650;
		scoreDisplay.y=40;
		hudLayer.addChild(scoreDisplay);
		scoreDisplay.text=""+score;
		ammo= new Text(Assets.fonts._04B_03__Name);
		ammo.x=125;
		ammo.y=120;
		hudLayer.addChild(ammo);
		ammo.text="Ammo: ";
		ammoCount= new Text(Assets.fonts._04B_03__Name);
		ammoCount.x=215;
		ammoCount.y=120;
		hudLayer.addChild(ammoCount);
		ammoCount.text="INFINITE";
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		switch(object.objectType){
			case OTRectangle: 
				if(object.properties.exists("Type")){
					switch (object.properties.get("Type")){
						case "RangedEnemy" : 
							var enemy = new RangedEnemy(simulationLayer, enemyCollisions, enemyBullets, object.x, object.y);
							addChild(enemy);
						case "MeleeEnemy" :
							var maxX = Std.parseFloat(object.properties.get("xMax"));
							var minX = Std.parseFloat(object.properties.get("xMin"));
							var enemy = new MeleeEnemy(simulationLayer, enemyCollisions, object.x, object.y,maxX,minX);
							addChild(enemy);
						case "Chest" :
							var chest = new Chest(object.x,object.y,chestCollisions,simulationLayer);
							addChild(chest);
						case "Protagonist" :
							marco = new Marco(object.x, object.y, simulationLayer);
							addChild(marco);
							// createTouchJoystick();
							GGD.marco=marco;
						default : 
					}
				}
				if(object.properties.exists("Harmful")){
					var collision = new CollisionBox();
					collision.width = object.width;
					collision.height = object.height;
					collision.x = object.x;
					collision.y = object.y;
					spikesCollisions.add(collision);
				}
				if(object.properties.exists("FinishLine")){
					var collision = new CollisionBox();
					collision.width = object.width;
					collision.height = object.height;
					collision.x = object.x;
					collision.y = object.y;
					finishCollisions.add(collision);
				}
				if(object.properties.exists("Door")){
					var collision = new CollisionBox();
					collision.width = object.width;
					collision.height = object.height;
					collision.x = object.x;
					collision.y = object.y;
					doorCollisions.add(collision);
					nextMapName = object.properties.get("Door");
				}
				if(object.properties.exists("Text")){
					var text=object.properties.get("Text");
					var dialog=new Dialog(text,object.x,object.y,object.width,object.height);
					dialogCollision.add(dialog.collider);
					addChild(dialog);
				}
			case OTTile(gid):
				var background;
				if(map == "Mapa1_tmx"){
					background = "Desert";
				}else{
					background = "CloudAndMountain";
				}
				var sprite = new Sprite(background);
				sprite.smooth = false;
				sprite.x = object.x;
				sprite.y = object.y - sprite.height();
				sprite.pivotY=sprite.height();
				sprite.scaleX = object.width/sprite.width();
				sprite.scaleY = object.height/sprite.height();
				sprite.rotation = object.rotation*Math.PI/180;
				simulationLayer.addChild(sprite);
					
			default :
		}
	}

	override function update(dt:Float) {
		super.update(dt);	
		if(marco.display.timeline.currentAnimation == "die_" && marco.display.timeline.isComplete()){
			changeState(new EndgameScreen(""+score,"MissionFailed"));
		}
		CollisionEngine.collide(marco.collision,worldMap.collision);
		CollisionEngine.overlap(marco.gun.bulletsCollisions, worldMap.collision, bulletVsWall);
		CollisionEngine.collide(enemyCollisions,worldMap.collision);
		CollisionEngine.overlap(marco.gun.bulletsCollisions, enemyCollisions, playerBulletVsEnemy);
		CollisionEngine.overlap(marco.collision, enemyBullets, playerVsEnemyBullet);
		CollisionEngine.overlap(marco.collision, enemyCollisions, playerVsEnemy);
		CollisionEngine.overlap(marco.collision, spikesCollisions, playerVsEnemy);
		CollisionEngine.collide(marco.collision, chestCollisions, playerOpenChest);
		CollisionEngine.overlap(marco.collision, finishCollisions, missionClear);
		CollisionEngine.collide(marco.collision, doorCollisions, nextMap);
		CollisionEngine.overlap(dialogCollision,marco.collision,playerVsDialog);
		stage.defaultCamera().setTarget(marco.collision.x, marco.collision.y);
		if(marco.gun.ammo > -1){
			hudLayer.remove(weapon);
			weapon = new Sprite("HUDMachineGun");
			hudLayer.addChild(weapon);
			weapon.x = 120;
			weapon.y = 50;
			ammoCount.text = ""+marco.gun.ammo;		
		}
		if(marco.gun.ammo == 0){
			hudLayer.remove(weapon);
			weapon = new Sprite("HUDGun");
			hudLayer.addChild(weapon);
			weapon.x = 120;
			weapon.y = 50;
			ammoCount.text = "INFINITE";	
		}
	}

	private function bulletVsWall(mapCollision:ICollider, bulletCollisions:ICollider){
		var bullet:Bullet = cast bulletCollisions.userData;
        bullet.die();
	}

	private function playerBulletVsEnemy(bulletCollisions:ICollider, enemyCollisions:ICollider){
		var bullet:Bullet = cast bulletCollisions.userData;
        bullet.die();
		var enemy:Enemy = cast enemyCollisions.userData;
		enemy.takeDamage();
		score++;
		scoreDisplay.text = ""+score;
	}

	private function playerVsEnemyBullet(playerCollision:ICollider, enemyBulletCollisions:ICollider){
		var bullet:Bullet = cast enemyBulletCollisions.userData;
        bullet.die();
		marco.takeDamage();
	}

	private function playerVsEnemy(enemyCollision:ICollider, playerCollisions:ICollider){
		marco.takeDamage();
	}

	function playerVsDialog(dialogCollision:ICollider,chivitoCollision:ICollider) {
		var dialog:Dialog=cast dialogCollision.userData;
		dialog.showText(simulationLayer);
	}

	private function missionClear(playerCollision:ICollider, finishCollisions:ICollider) {
		if(!complete){
			SoundManager.playFx("MissionComplete").volume = 0.1;
			complete = true;
			changeState(new EndgameScreen(""+score,"missionComplete"));
		}		
	}

	private function nextMap(playerCollision:ICollider, finishCollisions:ICollider) {
		var nextState = new GameState(nextMapName, "Tileset", 16,score);
		changeState(nextState);
	}

	private function playerOpenChest(chestCollision:ICollider,playerCollisions:ICollider) {
		var sound = SoundManager.playFx("HeavyMachinegun");
		sound.position = 1;
		sound.volume = 0.1;
		var chest:Chest = cast chestCollision.userData;
		var newGun = chest.open(marco.gun.bulletsCollisions);
		marco.equipGun(newGun);
	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera=stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer,camera);
	}
	#end
}
