default:
	@just --list

# Run tests locally
test arch="x86_64":
	./scripts/build_test_app.sh {{arch}} test_app_{{arch}}
	./scripts/download_runtime.sh {{arch}}
	./scripts/build_appimage.sh runtime-{{arch}} test_app_{{arch}} gzip test_gzip.AppImage
	./scripts/build_appimage.sh runtime-{{arch}} test_app_{{arch}} zstd test_zstd.AppImage
	./scripts/test_appimage.sh test_gzip.AppImage {{arch}}
	./scripts/test_appimage.sh test_zstd.AppImage {{arch}}

# Build documentation
docs:
	julia --project=docs -e 'using Pkg; Pkg.instantiate(); include("docs/make.jl")'

# Clean generated files
clean:
	rm -f test_app_* runtime-* *.AppImage
