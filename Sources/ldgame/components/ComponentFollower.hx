package ldgame.components;

import rgine.Component;
import rgine.GameObject;

class ComponentFollower extends Component {
	private var following : GameObject;
	public function new(following) {
		super();
		this.following = following;
	}
	
	override public function update(delta) {
		this.object.transform.position.x = following.transform.position.x;
		this.object.transform.position.z = following.transform.position.z;
		this.object.transform.rotation = following.transform.rotation.inverse();
		//this.object.rotateX(-90);
	}
}