{
  pkgs,
  lib,
  ...
}:

{
  imports = [ ../overlays/cosmic-comp.nix ];

  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;

  # Enable debug logging for EVDI cursor plane investigation.
  # Remove once cursor plane behavior is confirmed working.
  systemd.user.services.cosmic-comp.environment.RUST_LOG = "cosmic_comp::backend::kms=debug";

  # Create a dedicated systemd service for nm-applet tied to COSMIC
  systemd.user.services.nm-applet = {
    description = "NetworkManager Applet";
    wantedBy = lib.mkForce [ "cosmic-session.target" ];
    partOf = lib.mkForce [ "cosmic-session.target" ];
    bindsTo = lib.mkForce [ "cosmic-session.target" ];
    after = lib.mkForce [ "cosmic-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
      Restart = "on-failure";
    };
  };

  # Prevent the default XDG autostart from triggering nm-applet.
  # We disable it because we have our own nm-applet.service below specifically for COSMIC.
  # Using an empty ExecStart with mkForce to override the generated one.
  systemd.user.services."app-nm\\x2dapplet@autostart" = {
    serviceConfig.ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";
  };
}
