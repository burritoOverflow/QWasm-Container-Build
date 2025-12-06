A simple container for building the [WASM Quake port](https://github.com/GMH-Code/Qwasm).

Running `build.sh` builds and runs a container that pulls dependencies and builds `qwasm`. Upon a successful build, the build assets are copied to the host, under `dist/`.

An `id1` subdirectory populated with `pak` files at this project's root is a build requirement; the build won't proceed without it. See the QWasm docs for more details.

__Note:__ This builds both the software-rendered and the hardware-rendered approaches, as outlined in the QWasm docs.

For ease of serving the assets locally, you can use the included `nginx` `Dockerfile`; running `run-server.sh` builds the image specified in this `Dockerfile`, mounts the assets, and starts the container serving both build variants via a 'landing page'.

The contents of the `dist/` directory after successful build(s) should look like the following:

```bash
tree -sh dist/
[   50]  dist/
├── [  276]  gl
│   ├── [  50M]  index.data
│   ├── [  15M]  index.data.br
│   ├── [  23M]  index.data.gz
│   ├── [ 5.2K]  index.html
│   ├── [ 1.6K]  index.html.br
│   ├── [ 2.0K]  index.html.gz
│   ├── [ 200K]  index.js
│   ├── [  43K]  index.js.br
│   ├── [  49K]  index.js.gz
│   ├── [ 1.2M]  index.wasm
│   ├── [ 335K]  index.wasm.br
│   └── [ 428K]  index.wasm.gz
├── [  470]  index.html
├── [  276]  soft
│   ├── [  50M]  index.data
│   ├── [  15M]  index.data.br
│   ├── [  23M]  index.data.gz
│   ├── [ 5.2K]  index.html
│   ├── [ 1.6K]  index.html.br
│   ├── [ 2.0K]  index.html.gz
│   ├── [ 193K]  index.js
│   ├── [  41K]  index.js.br
│   ├── [  48K]  index.js.gz
│   ├── [ 1.0M]  index.wasm
│   ├── [ 279K]  index.wasm.br
│   └── [ 351K]  index.wasm.gz
└── [  975]  style.css

3 directories, 26 files
```
