// Generated by CoffeeScript 1.6.3
(function() {
  this.RandomShapes = (function() {
    function RandomShapes(_opts) {
      var folder,
        _this = this;
      this.options = _opts;
      this.camera = _opts.camera;
      this.scene = _opts.scene;
      this.notes = _opts.notes;
      this.colors = _.map(Please.make_color({
        colors_returned: 20
      }), function(clr) {
        return new THREE.Color(clr);
      });
      this.kinds = [];
      this.camVelocity = new THREE.Vector3(0, 0, 0);
      this.geometries = [new THREE.PlaneGeometry(3, 5)];
      this.config = {
        enabled: true,
        camSpeed: 0.01,
        spawnPosX: 0,
        spawnPosY: 0,
        spawnPosZ: -3,
        spawnPosOffset: 3,
        spawnPosRandomize: 3,
        spawnRotX: 0,
        spawnRotY: 0,
        spawnRotZ: 2,
        spawnRotOffset: 3,
        spawnRotRandomize: 0.01
      };
      if (this.options.gui) {
        this.options.gui.remember(this.config);
        folder = this.options.gui.addFolder('RandomShapes');
        _.each(Object.keys(this.config), function(key) {
          var item;
          return item = folder.add(_this.config, key);
        });
      }
      this.notes.on('add', function(note) {
        var mesh;
        mesh = _this.add(note.get('note'), 1.0);
        return note.set({
          randomShapeMesh: mesh
        });
      });
      this.notes.on('remove', function(note) {
        return _this.scene.remove(note.get('randomShapeMesh'));
      });
      this.notes.on('reset', function(collection, options) {
        _.each(options.previousModels, function(note) {
          _this.scene.remove(note.get('randomShapeMesh'));
          return note.unset('randomeShapeMesh');
        });
        return _this.kinds = [];
      });
    }

    RandomShapes.prototype.kindToIndex = function(kind) {
      var idx;
      idx = _.indexOf(this.kinds, kind);
      if (idx > -1) {
        return idx;
      }
      this.kinds.push(kind);
      return this.kinds.length - 1;
    };

    RandomShapes.prototype.add = function(kind, volume) {
      var endPos, endRot, idx, material, mesh, offset, startRot,
        _this = this;
      if (this.config.enabled !== true) {
        return;
      }
      material = new THREE.LineBasicMaterial();
      idx = this.kindToIndex(kind);
      material.color = this.colors[idx];
      mesh = new THREE.Mesh(_.sample(this.geometries), material);
      this.scene.add(mesh);
      offset = new THREE.Vector3(Math.random() * this.config.spawnPosRandomize, 0, 0);
      offset.applyAxisAngle(new THREE.Vector3(0, 0, 1), Math.random() * Math.PI * 2);
      endPos = new THREE.Vector3(this.config.spawnPosX, this.config.spawnPosY, this.config.spawnPosZ);
      endPos.copy(endPos.add(this.camera.position).add(offset));
      offset = new THREE.Vector3(this.config.spawnPosOffset, 0, 0);
      offset.applyAxisAngle(new THREE.Vector3(0, 0, 1), Math.random() * Math.PI * 2);
      mesh.position.addVectors(endPos, offset);
      new TWEEN.Tween(mesh.position).to({
        x: endPos.x,
        y: endPos.y,
        z: endPos.z
      }).easing(TWEEN.Easing.Exponential.Out).start().onComplete(function() {});
      offset = new THREE.Vector3(Math.random() * this.config.spawnRotRandomize, 0, 0);
      offset.applyAxisAngle(new THREE.Vector3(0, 0, 1), Math.random() * Math.PI * 2);
      endRot = new THREE.Vector3(this.config.spawnRotX, this.config.spawnRotY, this.config.spawnRotZ);
      endRot.copy(endRot.add(this.camera.position).add(offset));
      offset = new THREE.Vector3(this.config.spawnRotOffset, 0, 0);
      offset.applyAxisAngle(new THREE.Vector3(0, 0, 1), Math.random() * Math.PI * 2);
      startRot = new THREE.Vector3(0, 0, 0);
      startRot.addVectors(endRot, offset);
      mesh.rotation.set(startRot.x, startRot.y, startRot.z);
      new TWEEN.Tween(mesh.rotation).to({
        x: endRot.x,
        y: endRot.y,
        z: endRot.z
      }).easing(TWEEN.Easing.Exponential.Out).start().onComplete(function() {});
      return mesh;
    };

    RandomShapes.prototype.update = function(dt) {
      if (this.config.enabled !== true) {
        return;
      }
      this.camVelocity.z = this.config.camSpeed;
      return this.camera.position.add(this.camVelocity);
    };

    RandomShapes.prototype.log = function(msg) {
      return console.log('RandomShapes', msg);
    };

    return RandomShapes;

  })();

}).call(this);
