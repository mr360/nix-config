● NixOS has built-in VM support via nixpkgs.lib.nixosSystem — each nixosConfiguration automatically gets a .config.system.build.vm attribute you can run with QEMU. Here's how to use/extend it:

  What you get for free:

  # Build and run a VM from an existing config
  nix run .#nixosConfigurations.laptop.config.system.build.vm

  This boots a QEMU VM with a temporary disk image. No changes needed.

  To add a dedicated lightweight VM config in flake.nix:

  "vm-test" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit home-manager;
      flakePath = "/tmp/nix-config";
      builderOptions = {
        user.name = "foxskis";
        gui.enable = false;
        cmdpkgs.enable = true;
        powersaver.enable = false;
        sync.enable = false;
        ssh = { enable_agent = false; enable_server = true; };
        container = { traefik.enable = false; };
      };
    };
    modules = [
      ./host/server/default.nix
      { virtualisation.vmVariant.virtualisation.memorySize = 2048; }
      (/* same unstable overlay */ ...)
    ];
  };

  Then run with:

  nix run .#nixosConfigurations.vm-test.config.system.build.vm

  Key VM-specific options (set in any module):

  virtualisation.vmVariant.virtualisation = {
    memorySize = 2048;    # MB
    diskSize = 10240;     # MB
    cores = 2;
    graphics = false;     # headless
    forwardPorts = [{ from = "host"; host.port = 2222; guest.port = 22; }];
  };

  The simplest path: just run the existing laptop or storage-r710 config as a VM with the nix run command above — no flake changes needed.

❯ Can I use waypipe on a server without a gui? And then pipe the client running in qemu to my machine that is connected to it over ssh

● Yes, this works. The server doesn't need a GUI — it just acts as an SSH jump host. Waypipe only needs a compositor on your local machine.

  Architecture:

  Local machine (Wayland compositor) ←→ Server (no GUI, jump host) ←→ QEMU VM (waypipe server + apps)

  How to do it:

  1. Expose the VM's SSH port via QEMU port forwarding (e.g. host port 2222 → VM port 22):
  virtualisation.vmVariant.virtualisation.forwardPorts = [
    { from = "host"; host.port = 2222; guest.port = 22; }
  ];
  2. From your local machine, use waypipe with SSH ProxyJump:
  waypipe ssh -J user@server -p 2222 user@localhost app-name

  2. This tunnels SSH through the server to the VM, and waypipe rides over that connection.
  3. Both your local machine and the VM need waypipe installed. The server needs nothing special — no waypipe, no compositor.

  Alternatively, if you want the VM to be a persistent service rather than a forwarded port, run it with a bridged network and SSH directly to its IP via the jump host the same way.

  The key insight: waypipe ssh -J is just ssh -J with waypipe sockets injected — the jump host is transparent.

