# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-05-20
### Added
- Initial release of integration tests for AppImage Type 2 runtimes.
- Added GitHub Actions workflow to cross-compile and test x86_64, i686, aarch64, and armv7l architectures.
- Added tests for `gzip` and `zstd` SquashFS compression.
- Added fallback execution (`--appimage-extract-and-run`) for environments where FUSE is unavailable.
- Documentation for test levels and FUSE behavior in QEMU.
