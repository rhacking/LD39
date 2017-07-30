package ldgame.components;

import rgine.Component;
import rgine.components.ComponentParticleSystem;

import kha.math.FastVector3;

class ComponentExplosion extends Component {
	override public function init() {
		var comp = new ComponentParticleSystem(new kha.math.FastVector3(0.9, 0.02, 0.02));
		this.object.addComponent(comp);
		var light = new rgine.components.ComponentLight(new rgine.gfx.Light.LightDefault(new FastVector3(2.9, 1.3, 1.3), false));
		this.object.addComponent(light);
		motion.Actuate.tween(comp, 3, {spawnRate: 0}).onComplete(function() {
			this.object.scene.removeObject(this.object);
		});
		motion.Actuate.tween(cast(light.light, rgine.gfx.Light.LightDefault).intensity, 3, {x: 0, y: 0, z: 0});
	
		var s = kha.audio1.Audio.play(kha.Assets.sounds.explosion);
		if (s != null) s.volume = 0.5;
	}
}