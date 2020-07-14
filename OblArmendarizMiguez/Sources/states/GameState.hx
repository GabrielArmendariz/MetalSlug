package states;

import js.html.CacheStorage;
import gameObjects.Bullet;
import com.collision.platformer.ICollider;
import kha.Assets;
import helpers.Tray;
import com.gEngine.display.extra.TileMapDisplay;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import com.gEngine.display.Sprite;
import format.tmx.Data.TmxObject;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionEngine;
import gameObjects.*;
import com.loading.basicResources.TilesheetLoader;
import com.loading.basicResources.SpriteSheetLoader;
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
	var touchJoystick:VirtualGamepad;
	var enemyCollisions:CollisionGroup;
	var enemyBullets:CollisionGroup;
	var chestCollisions:CollisionGroup;

	public function new(room:String, fromRoom:String = null) {
		super();
	}

	override function load(resources:Resources) {
		screenWidth = GEngine.i.width;
        screenHeight = GEngine.i.height;
		resources.add(new DataLoader("Mapa1_tmx"));
		resources.add(new DataLoader(Assets.blobs.Mapa1_tmxName));
		var atlas = new JoinAtlas(2048, 2048);
		atlas.add(new SparrowLoader("Protagonist", "Protagonist_xml"));
		atlas.add(new SparrowLoader("RangedEnemy", "RangedEnemy_xml"));
		atlas.add(new SparrowLoader("MeleeEnemy", "MeleeEnemy_xml"));
		atlas.add(new SparrowLoader("Chest", "Chest_xml"));
		atlas.add(new ImageLoader("Bullet"));
		atlas.add(new TilesheetLoader("marioPNG", 17, 17, 0));		
		resources.add(atlas);
	}

	override function init() {
		stageColor(0.5, 0.5, 0.5);
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
				
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
		var enemy = new RangedEnemy(simulationLayer, enemyCollisions, enemyBullets, 500, (worldMap.heightInTiles - 8) * 16);
		addChild(enemy);
		var enemy2 = new MeleeEnemy(simulationLayer, enemyCollisions, 900, (worldMap.heightInTiles - 8) * 16);
		addChild(enemy2);		
		stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 16 * 1, worldMap.heightInTiles * 16 * 1);
		stage.defaultCamera().scale = 2.1;
		GGD.marco=marco;
		GGD.simulationLayer=simulationLayer;
		//marco.equipGun(new MachineGun(marco.gun.bulletsCollisions));
		createTouchJoystick();
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
	}

	private function playerBulletVsEnemy(bulletCollisions:ICollider, enemyCollisions:ICollider){
		var bullet:Bullet = cast bulletCollisions.userData;
        bullet.die();
		var enemy:Enemy = cast enemyCollisions.userData;
		enemy.takeDamage();
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

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera=stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer,camera);
	}
	#end

}
