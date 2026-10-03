# nixpkgs pins claude-code to whatever build was current when that
# nixpkgs commit landed, which lags Anthropic's actual releases by days
# to weeks. This overlay repoints the package at
# claude-code-manifest.zst.json — a snapshot of the manifest Anthropic
# publishes alongside each release — so `claude-code` tracks the real
# latest release instead of nixpkgs' lag.
#
# It must be the *.zst* manifest: nixpkgs' installPhase runs the
# downloaded artifact through `unzstd`, and it builds the download URL
# from the manifest's per-platform `binary` field. The plain
# manifest.json names the uncompressed `claude`, which then fails the
# build with "zstd: unsupported format".
#
# To bump: fetch the manifest for the version you want, e.g.
#   VERSION=$(curl -fsSL https://downloads.claude.ai/claude-code-releases/latest)
#   curl -fsSL "https://downloads.claude.ai/claude-code-releases/$VERSION/manifest.zst.json" \
#     -o modules/claude-code-manifest.zst.json
final: prev: {
  claude-code = prev.claude-code.override {
    manifest = builtins.fromJSON (builtins.readFile ./claude-code-manifest.zst.json);
  };
}
