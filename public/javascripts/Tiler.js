// Generated by CoffeeScript 1.6.3
(function() {
  this.Tiler = (function() {
    function Tiler(_opts) {
      var folder,
        _this = this;
      this.options = _opts;
      this.camera = _opts.camera;
      this.scene = _opts.scene;
      this._notes = _opts.notes;
      this.colors = _.map(Please.make_color({
        colors_returned: 20
      }), function(clr) {
        return new THREE.Color(clr);
      });
      this.kinds = [];
      this.gridSize = _opts.gridSize;
      if (_opts.imageUrl) {
        this.setImageUrl(_opts.imageUrl);
      }
      this.config = {
        enabled: true,
        showOriginal: true,
        spacing: 0.0,
        colorize: false,
        offset: 0.0,
        scale: 0.0,
        opacity: 1.0,
        rotX: 0.0,
        rotY: 0.0,
        rotZ: 0.0
      };
      if (this.options.gui) {
        this.options.gui.remember(this.config);
        folder = this.options.gui.addFolder('Tiler');
        _.each(Object.keys(this.config), function(key) {
          var item;
          return item = folder.add(_this.config, key);
        });
        _.find(folder.__controllers, function(cont) {
          return cont.property === 'showOriginal';
        }).onChange(function(showOrig) {
          if (!_this._imageMesh) {
            return;
          }
          if (showOrig) {
            return _this.scene.add(_this._imageMesh);
          } else {
            return _this.scene.remove(_this._imageMesh);
          }
        });
      }
      this._notes.on('add', function(note) {
        var mesh;
        mesh = _this.add(note.get('note'), 1.0);
        return note.set({
          tilerMesh: mesh
        });
      });
      this._notes.on('remove', function(note) {
        return _this.scene.remove(note.get('tilerMesh'));
      });
      this._notes.on('reset', function(collection, options) {
        _.each(options.previousModels, function(note) {
          _this.scene.remove(note.get('tilerMesh'));
          return note.unset('tilerMesh');
        });
        _this.kinds = [];
        return _this.cursor.set(0, 0, 0);
      });
    }

    Tiler.prototype.kindToIndex = function(kind) {
      var idx;
      idx = _.indexOf(this.kinds, kind);
      if (idx > -1) {
        return idx;
      }
      this.kinds.push(kind);
      return this.kinds.length - 1;
    };

    Tiler.prototype.add = function(kind, volume) {
      var material, mesh, offsetter, sc, tex;
      if (this.config.enabled !== true) {
        return;
      }
      tex = this._imageTexture.clone();
      tex.needsUpdate = true;
      material = new THREE.MeshBasicMaterial({
        map: tex
      });
      if (this.config.colorize) {
        material.color = this.colors[this.kindToIndex(kind)];
      }
      if (this.config.opacity !== 1.0) {
        material.transparent = true;
        material.opacity = this.config.opacity;
      }
      mesh = new THREE.Mesh(this._cellGeometry, material);
      mesh.position.set(this._cellOrigin.x + this.cursor.x * this.cellSize.x + this.config.spacing * (this.cursor.x - this.gridSize.x / 2), this._cellOrigin.y - this.cursor.y * this.cellSize.y - this.config.spacing * (this.cursor.y - this.gridSize.y / 2), this._cellOrigin.z + this.cursor.z);
      if (this.config.offset > 0.0) {
        offsetter = new THREE.Vector3(this.config.offset, 0, 0);
        offsetter.applyAxisAngle(new THREE.Vector3(0, 0, 1), Math.random() * Math.PI * 2);
        mesh.position.add(offsetter);
      }
      if (this.config.scale !== 0.0) {
        sc = 1.0 + Math.random() * this.config.scale;
        mesh.scale.set(sc, sc, 1.0);
      }
      tex.repeat.x = 1.0 / this.gridSize.x;
      tex.repeat.y = 1.0 / this.gridSize.y;
      tex.offset.x = 1.0 / this.gridSize.x * this.cursor.x;
      tex.offset.y = 1.0 / this.gridSize.y * (this.gridSize.y - this.cursor.y - 1);
      mesh.rotation.set(Math.random() * this.config.rotX, Math.random() * this.config.rotY, Math.random() * this.config.rotZ);
      this.cursor.x = this.cursor.x + 1;
      if (this.cursor.x >= this.gridSize.x) {
        this.cursor.x = 0;
        this.cursor.y = this.cursor.y + 1;
        if (this.cursor.y >= this.gridSize.y) {
          this.cursor.y = 0;
          this.cursor.z = this.cursor.z + 0.001;
        }
      }
      this.scene.add(mesh);
      return mesh;
    };

    Tiler.prototype.update = function(dt) {
      if (this.config.enabled !== true) {

      }
    };

    Tiler.prototype.log = function(msg) {
      if (arguments.length === 1) {
        console.log('Tiler', msg);
        return;
      }
      if (arguments.length === 2) {
        console.log('Tiler', msg, arguments[1]);
        return;
      }
      if (arguments.length === 3) {
        console.log('Tiler', msg, arguments[1], arguments[2]);
        return;
      }
      return console.log('Tiler', msg, arguments[1], arguments[2], arguments[3]);
    };

    Tiler.prototype.setImageUrl = function(_url) {
      var onError, onProgress, onSuccess,
        _this = this;
      this._imageUrl = _url;
      this.loader || (this.loader = new THREE.TextureLoader());
      onSuccess = function(tex) {
        return _this.setImage(tex);
      };
      onProgress = function(xhr) {
        return _this.log((xhr.loaded / xhr.total * 100) + '% loaded');
      };
      onError = function(xhr) {
        return _this.log('An error happened while loading image');
      };
      return this.loader.load(this._imageUrl, onSuccess, onProgress, onError);
    };

    Tiler.prototype.setImage = function(_tex) {
      this._imageTexture = _tex;
      this._imageMaterial = new THREE.MeshBasicMaterial({
        map: this._imageTexture
      });
      this._imageGeometry = new THREE.PlaneGeometry(this._imageTexture.image.width / this._imageTexture.image.height, 1);
      this._imageMesh = new THREE.Mesh(this._imageGeometry, this._imageMaterial);
      this._imageMesh.position.copy(this.camera.position);
      this._imageMesh.position.z = this._imageMesh.position.z - 1.05;
      if (this.config.showOriginal) {
        this.scene.add(this._imageMesh);
      }
      this.gridSize || (this.gridSize = new THREE.Vector2(10, 10));
      this.cellSize = new THREE.Vector2(this._imageGeometry.width / this.gridSize.x, this._imageGeometry.height / this.gridSize.y);
      this._cellGeometry = new THREE.PlaneGeometry(this.cellSize.x, this.cellSize.y);
      this._cellOrigin = new THREE.Vector3(this._imageMesh.position.x - this._imageGeometry.width / 2 + this.cellSize.x / 2, this._imageMesh.position.y + this._imageGeometry.height / 2 - this.cellSize.y / 2, this._imageMesh.position.z + 0.001);
      this.removeTiles();
      return this.cursor = new THREE.Vector3(0, 0, 0);
    };

    Tiler.prototype.removeTiles = function() {
      var _this = this;
      return this._notes.each(function(note) {
        var m;
        if (m = note.get('tilerMesh')) {
          _this.scene.remove(m);
          return note.unset('tilerMesh');
        }
      });
    };

    return Tiler;

  })();

}).call(this);
