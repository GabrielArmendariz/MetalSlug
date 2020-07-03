package states;

import kha.Assets;
import helpers.Tray;
import com.gEngine.display.extra.TileMapDisplay;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import format.tmx.Data.TmxObject;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionEngine;
import gameObjects.Marco;
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
import GlobalGameData.GGD;

class GameState extends State {
	var worldMap:Tilemap;
	var marco:Marco;
	var simulationLayer:Layer;
	var touchJoystick:VirtualGamepad;
	var tray:helpers.Tray;

	public function new(room:String, fromRoom:String = null) {
		super();
	}

	override function load(resources:Resources) {
		resources.add(new DataLoader("testRoom_tmx"));
		resources.add(new DataLoader(Assets.blobs.testRoom_tmxName));
		var atlas = new JoinAtlas(2048, 2048);
		atlas.add(new SparrowLoader("Protagonist", "Protagonist_xml"));
		atlas.add(new ImageLoader("Bullet"));
		atlas.add(new TilesheetLoader("tiles2", 32, 32, 0));
		
		resources.add(atlas);
	}

	override function init() {
		stageColor(0.5, .5, 0.5);
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
				
		var mayonnaiseMap:TileMapDisplay;
		worldMap = new Tilemap("testRoom_tmx", "tiles2", 1);
		worldMap.init(function(layerTilemap, tileLayer) {
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer));
			mayonnaiseMap = layerTilemap.createDisplay(tileLayer);
			simulationLayer.addChild(mayonnaiseMap);
		}, parseMapObjects);

		tray = new Tray(mayonnaiseMap);

		
		marco = new Marco(250,200,simulationLayer);
		addChild(marco);
		stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 32 * 1, worldMap.heightInTiles * 32 * 1);

		GGD.marco=marco;
		GGD.simulationLayer=simulationLayer;

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
		stage.defaultCamera().setTarget(marco.collision.x, marco.collision.y);

        tray.setContactPosition(marco.collision.x + marco.collision.width / 2, marco.collision.y + marco.collision.height + 1, Sides.BOTTOM);
		tray.setContactPosition(marco.collision.x + marco.collision.width + 1, marco.collision.y + marco.collision.height / 2, Sides.RIGHT);
		tray.setContactPosition(marco.collision.x-1, marco.collision.y+marco.collision.height/2, Sides.LEFT);

	}
	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera=stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer,camera);
	}
	#end

}
