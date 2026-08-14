# Changelog

## [0.4.10](https://github.com/joinrepublic/fontello_rails_converter/compare/fontello_rails_converter/v0.4.9...fontello_rails_converter/v0.4.10) (2026-08-14)


### Bug Fixes

* [DOPS-4938] install Ruby before configuring Bundler CodeArtifact credentials ([dad71ba](https://github.com/joinrepublic/fontello_rails_converter/commit/dad71ba6644b61137240b4af835db645d63b3c8c))
* [DOPS-4938] use Bearer token gem credentials for CodeArtifact push ([248074a](https://github.com/joinrepublic/fontello_rails_converter/commit/248074a65870f1d1f5661d42107a124cd535fe67))
* [DOPS-4938] use Bearer token gem credentials for CodeArtifact push (matches docx_replace) ([b7480d5](https://github.com/joinrepublic/fontello_rails_converter/commit/b7480d56b55c939a27eec9b58260e8c5cfb2540e))
* [DOPS-4938] use URL-embedded credentials for gem push to CodeArtifact ([5f7b0e8](https://github.com/joinrepublic/fontello_rails_converter/commit/5f7b0e8d35055f9d1788402116f83a87391c6460))
* [DOPS-4938] use URL-embedded credentials for gem push to CodeArtifact ([5e23559](https://github.com/joinrepublic/fontello_rails_converter/commit/5e23559de7eb08d27c5a1e7192fd66ac2f63166a))

## [0.4.9](https://github.com/joinrepublic/fontello_rails_converter/compare/fontello_rails_converter-v0.4.8...fontello_rails_converter/v0.4.9) (2026-03-06)


### Features

* Add rubocop-rake as a development dependency ([dda4035](https://github.com/joinrepublic/fontello_rails_converter/commit/dda40350f7d07bf177ebe41434b85327ea95072e))
* Enhance publish workflow with release validation and Ruby environment setup ([a91fab4](https://github.com/joinrepublic/fontello_rails_converter/commit/a91fab4f4327c264845693edb866774066d72eea))
* Refactor CI/CD pipeline to enhance gem publishing workflow and add release validation ([f5a1ba8](https://github.com/joinrepublic/fontello_rails_converter/commit/f5a1ba88d6fe6985bee9d202a9f1110c20e80f44))
* Update rubyzip dependency range to &gt;=1.0, &lt;3.0 ([76f6755](https://github.com/joinrepublic/fontello_rails_converter/commit/76f675544f44a1c31ccf53e7d3fd77f48da6671f))
* Update rubyzip to &gt;=2.0 and refactor nil checks ([b8014ea](https://github.com/joinrepublic/fontello_rails_converter/commit/b8014ea6f18bc6fd3031492ef2f984e34f7b93fd))


### Bug Fixes

* [PLAT-0] Enhance publish workflow with release validation and Ruby environment setup ([b7f4fbd](https://github.com/joinrepublic/fontello_rails_converter/commit/b7f4fbdeaf09a3b303cb7dbe9473cdb1a844bd8e))
* Exclude "vendor" folders from rubocop config ([3d69592](https://github.com/joinrepublic/fontello_rails_converter/commit/3d69592d2cdfde7e47693668d3a75db1cb726166))
* Extract gem version with sed instead of ruby -e to remove pre-setup Ruby dependency ([264f466](https://github.com/joinrepublic/fontello_rails_converter/commit/264f466175b8764d63768e1bf92dc99e466e0417))
* Extract gem version with sed instead of ruby -e to remove pre-setup Ruby dependency ([0c463ec](https://github.com/joinrepublic/fontello_rails_converter/commit/0c463ecfd0d6bf53fdfb73688aac22ecfeacd170))
* Guard against nil values in stylesheet_file and fontello_name methods ([bc5f8ff](https://github.com/joinrepublic/fontello_rails_converter/commit/bc5f8ff9ba845ee8f5f602f211cd3befec981c23))
* Guard nil values in `stylesheet_file` and `fontello_name` ([341eca1](https://github.com/joinrepublic/fontello_rails_converter/commit/341eca1b30bab6efc920d664369449cad363bbbe))
* remove unnecessary API key from CI/CD gem list command ([559ade2](https://github.com/joinrepublic/fontello_rails_converter/commit/559ade256f5450ab9277118e651f0d00d762ee87))
* Remove unnecessary API key from gem list command in CI/CD pipeline ([b26dcda](https://github.com/joinrepublic/fontello_rails_converter/commit/b26dcdab862523a5b1a61682275d1e421440104b))
* webpack fails to generate embedded file. ([96da951](https://github.com/joinrepublic/fontello_rails_converter/commit/96da95146e75892dc218ce6a7a5f5dcfcf971de2))

## 0.4.8

* [feature] Bump rubyzip version to 2.0.0+

## 0.4.7

* [feature] Bump Ruby version

## 0.4.6

* [feature] added new `--webpack` option to convert stylesheets for use with webpack. #45
* [bugfix] fixed compatibility with Rails 5 #44

## 0.4.5

* [bugfix] embedded base64 fonts (using `url()`) were not decoded correctly #43

## 0.4.4

* added .woff2 support #41

## 0.4.2

* [enhancement] embedded stylesheet (e.g. `fontello-embedded.css`) will also be converted to Sass #32
* [bugfix] the .css source version of a stylesheet will be deleted on conversion, because having both a fontello.css and fontello.scss was creating problems #33

## 0.4.1

* [bugfix] for case where font name in `config.json` is empty #30

## 0.4.0

* added new `copy` command for cases where you don't want to convert assets
* gem now depends on Ruby 2.x

## 0.3.3

* [improvement] changed default stylesheet file extension from `.css.scss` to `.scss` because of recent change in `sass-rails` (see #26)
* [bugfix] fixed stylesheet extension option parsing #25

## 0.3.2

* [bugfix] the `config.json` wasn't being copied anymore

## 0.3.1

* allow configuration (and automatic creation) of icon guide directory (/rails_root/public/fontello-demo.html), fixes #19
* more verbose/helpful CLI output
* add `-v`/`--version` switch to CLI for printing out the current version

## 0.3.0

* allow setting global options using a .yml file (e.g. /rails_root/config/fontello_rails_converter.yml)
* allow configuration of the stylesheet extension for the SCSS files (`.css.scss` or `.scss`)
* fail gracefully when there is no config file yet (90ec5942383cc5558a097aa78c4adcc809ab6a0e)
* fixes for 2 encoding issues #11 and #12 by @hqm42

## 0.2.0

* removed deprecated rake task
* updated railtie integration, so that rails will find and precompile the asset in `vendor/assets/fonts`

## 0.1.1

* only an update to the gemspec description

## 0.1.0

* convert the gem to a CLI tool with `open` and `convert` commands
* deprecated rake task
* make use of the fontello API

## 0.0.2

* updated rubyzip dependency

## 0.0.1

* initial release
