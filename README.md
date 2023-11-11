![vscode screenshot in browser](docs/vscode.png)

Custom VSCode server running in docker for quick linux environments. Based on Debian 11.

## Running

Privileged mode is required for the container to run docker-in-docker.

```
docker run --rm --privileged -d -p 8080:8080 ghcr.io/cscosu/vs-workspace
```

Then navigate to http://localhost:8080.

## Preinstalled Tools

- Docker
- Python
  - [pwntools](https://github.com/Gallopsled/pwntools) pwn ctf framework
  - [pyshark](https://github.com/KimiNewt/pyshark) wireshark wrapper
  - [black](https://github.com/psf/black) formatter
- Rust
  - [rust-analyzer](https://github.com/rust-lang/rust-analyzer)
- C/C++
  - [gef](https://github.com/hugsy/gef) gdb usability plugin
  - [clangd](https://clangd.llvm.org) language server
- JavaScript
  - [fnm](https://github.com/Schniz/fnm) node version manager
  - [bun](https://github.com/oven-sh/bun) javascript/typescript runtime

## HTTP Proxying

You can bring through HTTP servers from the container, without even bringing any ports through to the host.

![hosted proxied server in browser](docs/server.png)