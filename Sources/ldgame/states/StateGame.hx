package ldgame.states;

import ldgame.components.ComponentCamControl;

import kha.Framebuffer;

import rgine.util.State;
import rgine.Scene;
import rgine.GameObject;
import rgine.components.ComponentModel;
import rgine.components.ComponentBoxModel;
import rgine.components.ComponentCamera;
import rgine.components.ComponentLight;
import rgine.components.ComponentHexCollider;
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
}

class StateGame implements State {
	private var world : Scene;

	private var hexes : Vector<Vector<Hex>>;
	private static var HEX_HEIGHT(default, never) = 2.0;
	private static var HEX_WIDTH(default, never) = 1.732;

	private static var tileModel : Model;

	public function new() {}

	public function init():Void {
		if (tileModel == null) tileModel = ColladaLoaderNew.loadCollada(kha.Assets.blobs.tile_dae, true)[0];
		world = genWorld(5);
	}

	private function genWorld(n) {
		hexes = new Vector(n);
		var world = new Scene();
		for (x in 0...n) {
			hexes[x] = new Vector(n);
			for (y in 0...n) {
				hexes[x][y] = {
					object: world.createObject("hex_tile")
								.addComponent(new ComponentModel(tileModel))
								.addComponent(new ComponentHexCollider(HEX_WIDTH, HEX_HEIGHT, 0.2))
								.translate(HEX_WIDTH*x + (y%2 == 0 ? 0 : HEX_WIDTH*0.5), 0, y*HEX_HEIGHT*0.75), 
					type: Grass}
				;
			}
		}

		world.createObject("sun")
			.addComponent(new ComponentLight(new LightDefault(new V3(3.6, 3.3, 3.3), false)))
			.translate(7, 7, 7);

		world.createObject("cam")
			.addComponent(new ComponentCamera(new DefaultCamera(Perspective, 0, 70)))
			.translate(0, 8, 5)
			.addComponent(new ComponentCamControl())
			.lookAt(new V3(0, 0, 0));

		world.createObject("coltest")
			.addComponent(new ComponentRayCollider(new V3(0, -1, 0)))
			.translate(0, 5, 0);

		return world;
	}

	public function start():Void {}
	public function stop():Void {}
	public function update(deltaTime:Float):Void {
		world.update(deltaTime);
	}
	public function draw(frame:Framebuffer):Void {
		world.draw(frame);
	}
}