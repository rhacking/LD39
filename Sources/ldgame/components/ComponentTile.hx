package ldgame.components;

import rgine.Component;
import rgine.Input;

import kha.input.KeyCode;
import kha.math.FastVector3;

import rgine.components.ComponentSphereCollider;
import rgine.components.ComponentCamera;
import rgine.components.ComponentModel;
import rgine.gfx.Material.MaterialDefault;

import kha.Framebuffer;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.FastMatrix4;

import rgine.gfx.Camera.DefaultCamera;


class ComponentTile extends Component {
	public var hex : ldgame.states.StateGame.Hex;

	public var selected : Bool;

	public function new(hex) {
		super();
		this.hex = hex;
	}

	override public function update(delta) {
		var col = ldgame.states.StateGame.tileColors[hex.type];
		cast(this.object.getComponent(ComponentModel).model.material, MaterialDefault).diffuse = 
						selected ? new FastVector4(col.x+0.2, col.y+0.2, col.z+0.2, 1.0) :  new FastVector4(col.x, col.y, col.z, 1.0);
		if (ldgame.states.StateGame.tileHeights.exists(hex.type)) {
			this.object.transform.scale.y = ldgame.states.StateGame.tileHeights[hex.type];
		} else {
			this.object.transform.scale.y = 0.5;
		}
	}
}