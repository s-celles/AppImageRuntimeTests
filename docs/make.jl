using Documenter
using DocumenterLandingPage

makedocs(
    sitename = "AppImageRuntimeTests",
    format = Documenter.HTML(),
    modules = Module[],
    pages = [
        "Home" => "index.md",
    ]
)

# Optional: Add any extra generation steps here (e.g. building llms.txt)
# Since we just need to satisfy the structure, this basic setup suffices.
