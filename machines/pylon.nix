_: {
  config = {
    dusk.system = {
      hostname = "pylon";

      nixos = {
        desktop.enable = false;
        nvidia.enable = false;
        server.enable = true;
      };
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];

        kernelModules = [ "kvm-intel" ];
      };
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/e94280a2-7d84-41ea-a24a-f6a17ef23921";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/4506-BEC5";
        fsType = "vfat";
      };
    };

    swapDevices = [ ];

    # Workaround fix for nm-online-service from stalling on Wireguard interface.
    # https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}