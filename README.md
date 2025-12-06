A simple container for building the [WASM Quake port](https://github.com/GMH-Code/Qwasm).

Running `build.sh` builds and runs a container that pulls dependencies and builds `qwasm`. Upon a successful build, the build assets are copied to the host, under `dist/`.

An `id1` subdirectory populated with `pak` files at this project's root is a build requirement; the build won't proceed without it. See the QWasm docs for more details.

__Note:__ This uses the software-rendered approach, outlined in the QWasm docs.