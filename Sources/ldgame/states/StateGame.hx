package ldgame.states;

import ldgame.components.*;

import kha.Framebuffer;

import rgine.util.State;
import rgine.Scene;
import rgine.GameObject;
import rgine.components.ComponentModel;
import rgine.components.ComponentBoxModel;
import rgine.components.ComponentCamera;
import rgine.components.ComponentLight;
import rgine.components.ComponentSphereCollider;
import rgine.components.ComponentRayCollider;

import rgine.gfx.Material.MaterialDefault;

import rgine.gfx.Camera.ProjectionType;
import rgine.gfx.Camera.DefaultCamera;

import rgine.gfx.Light.LightDefault;
import rgine.gfx.Model;

import kha.math.FastVector3 as V3;
import kha.math.FastVector4 as V4;

import rgine.loader.ColladaLoaderNew;

import haxe.ds.Vector;

typedef Hex = {
	var object : GameObject;
	var type : HexType;
}

enum HexType {
	Grass;
	Village;
	VisMine;
	Water;
	SolemCollector;
}

class StateGame implements State {
	private var world : Scene;

	public static var tileColors = [
		Grass => new V4(0.2, 0.9, 0.3), 
		Village => new V4(0.7, 0.4, 0.1), 
		VisMine => new V4(0.05, 0.1, 0.9),
		Water => new V4(0.05, 0.6, 0.95), 
		SolemCollector => new V4(1.0, 1.0, 0.1)
	];

	public static var tileHeights = [
		Water => 0.27, 
		Village => 0.65, 
		VisMine => 0.6, 
		SolemCollector => 0.76
	];

	public static var costs = [
		Grass => 1, 
		Village => 10, 
		VisMine => 20,
		Water => 5, 
		SolemCollector => 35
	];

	public var hexes : Vector<Vector<Hex>>;
	private static var HEX_HEIGHT(default, never) = 1.0;
	private static var HEX_WIDTH(default, never) = 0.866;

	private static var tileModel : Model;

	public function new() {}

	public function init():Void {
		if (tileModel == null) tileModel = ColladaLoaderNew.loadCollada(kha.Assets.blobs.tile_dae, true)[0];
		world = genWorld(11);
	}

	private function genWorld(n) {
		hexes = new Vector(n);
		var world = new Scene();
		var f1 = Math.random()/2+0.1;
		var f2 = Math.random()/2+0.4;
		var a1 = Math.random()*(n/5)+1;
		var a2 = Math.random()*(n/5)+1;
		for (x in 0...n) {
			hexes[x] = new Vector(n);
			var riverVal = Math.sin(x*f1)*a1 + Math.cos(x*f2+0.2)*a2 + n/2;
			for (y in 0...n) {
				hexes[x][y] = {
					object: world.createObject("hex_tile")
								.addComponent(new ComponentModel(new Model(tileModel.mesh, new rgine.gfx.Material.MaterialDefault(new V4(), new V4(0.1, 0.1, 0.1, 1.0), new V4(), 0.5))))
								.addComponent(new ComponentSphereCollider(HEX_WIDTH*0.49))
								.translate(HEX_WIDTH + HEX_WIDTH*x + (y%2 == 0 ? 0 : HEX_WIDTH*0.5), 0, y*HEX_HEIGHT*0.75), 
					type: Math.abs(riverVal - y) < 1.8 ? Water : Grass}
				;
				//(new ComponentBoxCollider(-HEX_WIDTH/2, 0, -HEX_HEIGHT*0.25, HEX_WIDTH, 0.1, HEX_HEIGHT*0.5))
				hexes[x][y].object.transform.setScale(0.5);
				hexes[x][y].object.addComponent(new ComponentTile(hexes[x][y]));
				if (Math.random() < 0.2) hexes[x][y].type = Village;
				else if (Math.random() < 0.1) hexes[x][y].type = VisMine;
			}
		}

		world.createObject("sun")
			.addComponent(new ComponentLight(new LightDefault(new V3(3.6, 3.3, 3.3), false)))
			.translate(7, 7, 7);

		world.createObject("cam")
			.addComponent(new ComponentCamera(new DefaultCamera(Perspective, 0, 70)))
			.translate(0, 8, 5)
			.addComponent(new ComponentCamControl())
			.lookAt(new V3(0, 0, 3))
			.translate(HEX_WIDTH*n/2, 0, 0);

		world.createObject("background")
			.translate(0, -1, 0)
			.addComponent(new ComponentFollower(world.getObjectByName("cam")))
			.addComponent(new ComponentModel(new Model(rgine.ShapeFactory.genRect(20, 20, kha.Color.White, -10, -10), 
				new rgine.gfx.Material.MaterialDefaultTex(new V4(1, 1, 1, 1), new V4(0.1, 0.1, 0.1, 1.0), new V4(1, 1, 1, 1), 0.5, kha.Assets.images.back, null, null))))
			;

		world.createObject("coltest")
			.addComponent(new ComponentRayCollider(new V3(0, -1, 0)))
			.translate(0, 5, 0);

		world.addSystem(new ldgame.systems.WorldSystem());

		return world;
	}

	public function start():Void {
		motion.Actuate.timer(1.2).onComplete(function() kha.audio1.Audio.play(kha.Assets.sounds.music, true));
	}
	public function stop():Void {}
	public function update(deltaTime:Float):Void {
		world.update(deltaTime);
	}
	public function draw(frame:Framebuffer):Void {
		world.draw(frame);
		world.draw2(frame.g2, frame);
	}
}