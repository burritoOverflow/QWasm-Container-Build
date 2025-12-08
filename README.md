A simple container for building the [WASM Quake2 port](https://github.com/GMH-Code/Qwasm2).

Running `build.sh` builds and runs a container that pulls dependencies and builds `qwasm2`. Upon a successful build, the build assets are copied to the host, under `dist/`. Provide a relative path via `--dest` if a different directory is desired. The `--rebuild` flag ignores cache when rebuilding the image.

__NOTE__: These assets are uncompressed by deafult and are copied to the host in their original state. Pass the  `--compress` flag to compress with both `gzip` and `brotli`.

For the game to properly boot, it requires `PAK` fies present in the project's `wasm/baseq2` subdirectory (at build time).

For the build, we expect `*.pak` files in this project's root directory; the `build.sh` checks for the presence of these.

For local Steam installs, the following works:

```bash
cp ~/.local/share/Steam/steamapps/common/Quake\ 2/baseq2/*.pak .
```