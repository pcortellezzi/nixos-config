{
  pkgs, ...
}:

{
  imports = [
    ../services/openssh.nix
    ../services/tailscale.nix
    ../services/samba.nix
    ../services/plex.nix
    ../services/aria2.nix
  ];

  aria2.downloadDir = "/srv/samba/plex/Downloads";

  samba.shares.plex = {
    "path" = "/srv/samba/plex";
    "browsable" = "yes";
    "read only" = "no";
    "guest ok" = "yes";
    "create mask" = "0644";
    "directory mask" = "0755";
    "force user" = "plex";
    "force group" = "plex";
  };

  users.users.aria2.extraGroups = [ "plex" ];
  users.users.plex.extraGroups = [ "aria2" ];
}
