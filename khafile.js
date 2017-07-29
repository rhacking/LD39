let project = new Project('New Project');
project.addAssets('Assets/**');
project.addShaders("Libraries/rGine3/Shaders/**");
project.addSources('Sources');
project.addLibrary("rGine3");

project.addLibrary("haxebullet");
project.addLibrary("actuate");
project.addLibrary("hxmath2");
project.addLibrary("tink_xml");
project.addLibrary("tink_macro");
project.addLibrary("thx.core");

resolve(project);
