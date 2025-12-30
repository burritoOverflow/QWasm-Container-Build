A simple container for building the [WASM ioquake3 port](https://github.com/ioquake/ioq3).

Running `build.sh` builds and runs a container that pulls dependencies and builds `ioquake3`.

Upon a successful build, the build assets are copied to the host, under `dist/`.
(if a different directory is desired, provide a relative path via `--dest`.)

The `--rebuild` flag ignores cache when rebuilding the image.

__NOTE__: These assets are uncompressed and are copied to the host in their original state. Ideally, these should be compressed before serving them.

For the game to properly boot, it requires `pk3` fies present in the project's `wasm/baseq2` subdirectory (at build time).

For the build, we expect `*.pk3` files contained in a `baseq3` directory in this project's root directory; the `build.sh` checks for the presence of these.

For local Steam installs, the following works; the build container copies the `*pak` files from the local `baseq3` directory to the build directory.:

```bash
cp -r ~/.local/share/Steam/steamapps/common/Quake\ 3\ Arena/baseq3/ .
```