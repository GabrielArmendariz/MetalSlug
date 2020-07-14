package states;

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
	var touchJoystick:VirtualGamepad;
	var enemyCollisions:CollisionGroup;
	var enemyBullets:CollisionGroup;
	var chestCollisions:CollisionGroup;
	var portrait:Sprite;
	var weapon:Sprite;
	var scoreDisplay:Text;
	var ammo:Text;
	var ammoCount:Text;
	var score:Int;

	public function new(room:String, fromRoom:String = null) {
		super();
	}

	override function load(resources:Resources) {
		screenWidth = GEngine.i.width;
        screenHeight = GEngine.i.height;
		resources.add(new DataLoader("Mapa1_tmx"));
		resources.add(new DataLoader("Mapa3_tmx"));
		resources.add(new DataLoader(Assets.blobs.Mapa1_tmxName));
		resources.add(new DataLoader(Assets.blobs.Mapa3_tmxName));
		//resources.add(new SoundLoader("BGM"));
		var atlas = new JoinAtlas(2048, 2048);
		atlas.add(new SparrowLoader("Protagonist", "Protagonist_xml"));
		atlas.add(new SparrowLoader("ProtagonistShotgun", "ProtagonistShotgun_xml"));
		atlas.add(new SparrowLoader("RangedEnemy", "RangedEnemy_xml"));
		atlas.add(new SparrowLoader("MeleeEnemy", "MeleeEnemy_xml"));
		atlas.add(new SparrowLoader("Chest", "Chest_xml"));
		atlas.add(new ImageLoader("Bullet"));
		atlas.add(new ImageLoader("HUDPortrait"));
		atlas.add(new ImageLoader("HUDGun"));
		atlas.add(new ImageLoader("HUDMachineGun"));
		atlas.add(new TilesheetLoader("marioPNG", 17, 17, 0));
		atlas.add(new TilesheetLoader("Tileset", 16, 16, 0));
		atlas.add(new FontLoader(Assets.fonts._04B_03__Name,30));				
		resources.add(atlas);
	}

	override function init() {
		stageColor(0.5, 0.5, 0.5);
		simulationLayer = new Layer();
		hudLayer = new StaticLayer();
		stage.addChild(simulationLayer);
		stage.addChild(hudLayer);		
		worldMap = new Tilemap("Mapa1_tmx", 1);
		worldMap.init(function(layerTilemap, tileLayer) {
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("marioPNG")));
		}, parseMapObjects);
		enemyCollisions = new CollisionGroup();
		enemyBullets = new CollisionGroup();
		chestCollisions = new CollisionGroup();
		var chest = new Chest(1200,((worldMap.heightInTiles - 8) * 16),chestCollisions,simulationLayer);
		addChild(chest);
		marco = new Marco(250, (worldMap.heightInTiles - 8) * 16, simulationLayer);
		addChild(marco);
		spawnEnemies();		
		stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 16 * 1, worldMap.heightInTiles * 16 * 1);
		stage.defaultCamera().scale = 2.1;
		GGD.marco=marco;
		GGD.simulationLayer=simulationLayer;
		createTouchJoystick();
		initHud();
		score = 0;
		//SoundManager.playMusic("BGM",true);
		//SoundManager.musicVolume(0.1);
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
		scoreDisplay.text="0";
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

	function createTouchJoystick() {		
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
		touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.A);
		touchJoystick.notify(marco.onAxisChange, marco.onButtonChange);
		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(marco.onAxisChange, marco.onButtonChange);
	}	

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {}

	override function update(dt:Float) {
		super.update(dt);	
		CollisionEngine.collide(marco.collision,worldMap.collision);
		CollisionEngine.collide(enemyCollisions,worldMap.collision);
		CollisionEngine.overlap(marco.gun.bulletsCollisions, enemyCollisions, playerBulletVsEnemy);
		CollisionEngine.overlap(marco.collision, enemyBullets, playerVsEnemyBullet);
		CollisionEngine.overlap(marco.collision, enemyCollisions, playerVsEnemy);
		CollisionEngine.overlap(marco.collision, chestCollisions, playerOpenChest);
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

	private function playerOpenChest(chestCollision:ICollider,playerCollisions:ICollider) {
		var chest:Chest = cast chestCollision.userData;
		var newGun = chest.open(marco.gun.bulletsCollisions);
		marco.equipGun(newGun);
	}

	private function spawnEnemies(){
		var enemy = new RangedEnemy(simulationLayer, enemyCollisions, enemyBullets, 500, (worldMap.heightInTiles - 8) * 16);
		addChild(enemy);
		var enemy2 = new MeleeEnemy(simulationLayer, enemyCollisions, 750, (worldMap.heightInTiles - 8) * 16,977,688);
		addChild(enemy2);
		var i = 0;
		var gap = 0;
		while(i++ < 6){
			var newEnemy = new RangedEnemy(simulationLayer, enemyCollisions, enemyBullets, 1500+gap, (worldMap.heightInTiles - 8) * 16);
			gap+= 25;
			addChild(newEnemy);
		}
	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera=stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer,camera);
	}
	#end
}
