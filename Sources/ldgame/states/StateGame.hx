package ldgame.states;

import kha.Framebuffer;

import rgine.util.State;
import rgine.Scene;
import rgine.GameObject;
import rgine.components.ComponentBoxModel;
import rgine.components.ComponentCamera;
import rgine.components.ComponentLight;

import rgine.gfx.Material.MaterialDefault;

import rgine.gfx.Camera.ProjectionType;
import rgine.gfx.Camera.DefaultCamera;

import rgine.gfx.Light.LightDefault;

import kha.math.FastVector3 as V3;
import kha.math.FastVector4 as V4;

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
	private static var HEX_HEIGHT(default, never) = 1.0;
	private static var HEX_WIDTH(default, never) = 1.0;

	public function new() {}

	public function init():Void {
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
								.translate(HEX_SIZE*x + (y%2 == 0 ? 0 : ), 0, HEX_SIZE*0.75), 
					type: Grass}
				;
			}
		}

		world.createObject("test")
			.addComponent(new ComponentBoxModel(
				new MaterialDefault(new V4(1, 1, 1, 1), new V4(0.1, 0.1, 0.1, 1.0), new V4(0.1, 0.1, 0.1, 1.0), 0.5), 
				1, 1, 1
			));

		world.createObject("sun")
			.addComponent(new ComponentLight(new LightDefault(new V3(0.6, 0.3, 0.3), false)))
			.translate(7, 7, 7);

		world.createObject("cam")
			.addComponent(new ComponentCamera(new DefaultCamera(Perspective, 0, 70)))
			.translate(0, 0, 5);

		return world;
	}

	public function start():Void {}
	public function stop():Void {}
	public function update(deltaTime:Float):Void {
		world.getObjectByName("test").rotateY(0.1);
		world.update(deltaTime);
	}
	public function draw(frame:Framebuffer):Void {
		world.draw(frame);
	}
}