// Generated by CoffeeScript 1.6.3
(function() {
  this.SingleLine = (function() {
    function SingleLine(_opts) {
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
      this.geometry = new THREE.CubeGeometry(1, 1, 1);
      this.relativeSpawnPos = new THREE.Vector3(0, 0, -30);
      this.kinds = [];
      this.camVelocity = new THREE.Vector3(0, 0, 0.001);
      this.config = new function() {
        this.enabled = true;
        return this.camSpeed = 0.1;
      };
      if (this.options.gui) {
        this.options.gui.remember(this.config);
        folder = this.options.gui.addFolder('SingleLine');
        _.each(Object.keys(this.config), function(key) {
          var item;
          return item = folder.add(_this.config, key);
        });
      }
      this.notes.on('add', function(note) {
        var mesh;
        mesh = _this.add(note.get('note'), 1.0);
        return note.set({
          singleLineMesh: mesh
        });
      });
      this.notes.on('remove', function(note) {
        return _this.scene.remove(note.get('singleLineMesh'));
      });
      this.notes.on('reset', function(collection, options) {
        _.each(options.previousModels, function(note) {
          _this.scene.remove(note.get('singleLineMesh'));
          return note.unset('singleLineMesh');
        });
        return _this.kinds = [];
      });
    }

    SingleLine.prototype.kindToIndex = function(kind) {
      var idx;
      idx = _.indexOf(this.kinds, kind);
      if (idx > -1) {
        return idx;
      }
      this.kinds.push(kind);
      return this.kinds.length - 1;
    };

    SingleLine.prototype.add = function(kind, volume) {
      var idx, material, mesh;
      if (this.config.enabled !== true) {
        return;
      }
      material = new THREE.LineBasicMaterial();
      idx = this.kindToIndex(kind);
      material.color = this.colors[idx];
      mesh = new THREE.Mesh(this.geometry, material);
      mesh.position.addVectors(this.camera.position, this.relativeSpawnPos);
      mesh.position.y += idx * this.geometry.height;
      this.scene.add(mesh);
      return mesh;
    };

    SingleLine.prototype.update = function(dt) {
      if (this.config.enabled !== true) {
        return;
      }
      this.camVelocity.x = this.config.camSpeed;
      return this.camera.position.add(this.camVelocity);
    };

    SingleLine.prototype.log = function(msg) {
      return console.log('SingleLine', msg);
    };

    return SingleLine;

  })();

}).call(this);
