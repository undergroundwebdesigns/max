### Requirements

- If installing to a maxmaster machine running OSX, install the command line
  tools with `xcode-select --install`
- Install homebrew.
- Tap `brew tap watsonbox/cmu-sphinx`
- `brew install --HEAD watsonbox/cmu-sphinx/cmu-sphinxbase`
- `brew install --HEAD watsonbox/cmu-sphinx/cmu-pocketsphinx`
- `brew install rbenv ruby-build`
- `gem install bundler`
- May need to export `MACOSX_DEPLOYMENT_TARGET="10.9"` to get wit gem to
  compile.
- `brew install sox curl` (dependencies for wit)
- `brew install espeak`
