{ pkgs, ... }:

# CachyOS desktop — Linux-only packages and overrides go here.
{
  # Example:
  # home.packages = with pkgs; [ docker-compose ];

  xdg.configFile = {
    "environment.d/50-gaming.conf".text = ''
      # Proton: run games on Wine's native Wayland driver (GE-Proton keeps the Steam
      # overlay and Steam Input working in this mode; opt a game out with
      # PROTON_ENABLE_WAYLAND=0 %command%), and auto-upgrade DLSS DLLs inside each
      # game's prefix. ntsync is used automatically by Proton 11 / GE 11.
      PROTON_ENABLE_WAYLAND=1
      PROTON_DLSS_UPGRADE=1
      # NVIDIA: keep up to 12 GB of compiled shaders per cache instead of ~1 GB.
      __GL_SHADER_DISK_CACHE_SIZE=12000000000
    '';

    "environment.d/60-firefox-nvidia-vaapi.conf".text = ''
      # Firefox hardware video decode on the RTX 3090 via nvidia-vaapi-driver.
      # MOZ_DISABLE_RDD_SANDBOX trades the media-decoder sandbox for NVDEC access;
      # remove this entry (and Firefox's user.js prefs) to go back to CPU decode.
      LIBVA_DRIVER_NAME=nvidia
      MOZ_DISABLE_RDD_SANDBOX=1
    '';

    "systemd/user/plasma-foreground-booster.service.d/10-wait-for-wayland.conf".text = ''
      # The first start at login races the session's WAYLAND_DISPLAY import and
      # aborts with "no Qt platform plugin could be initialized" (a coredump on
      # every login). Fail the start cleanly instead and let Restart= retry.
      [Unit]
      StartLimitIntervalSec=60
      StartLimitBurst=30

      [Service]
      ExecStartPre=/bin/sh -c 'test -n "$$WAYLAND_DISPLAY"'
      RestartSec=1
    '';
  };
}
