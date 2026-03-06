require 'spec_helper'
require 'tmpdir'
require 'tempfile'

describe FontelloRailsConverter::Cli do
  let(:options) do
    {
      config_file: 'spec/fixtures/fontello/config.json',
      stylesheet_dir: 'vendor/assets/stylesheets',
      font_dir: 'vendor/assets/fonts',
      asset_dir: 'vendor/assets',
      icon_guide_dir: 'public',
      zip_file: 'tmp/fontello.zip',
      stylesheet_extension: '.scss'
    }
  end

  let(:cli) { described_class.new(options) }

  describe '.convert_icon_guide_html' do
    let(:content) { File.read('spec/fixtures/fontello-demo.html') }
    let(:converted_content) { File.read('spec/fixtures/converted/fontello-demo.html') }

    specify do
      expect(described_class.convert_icon_guide_html(content)).to eql converted_content
    end
  end

  describe '#stylesheet_file' do
    specify do
      expect(cli.send(:stylesheet_file)).to eql 'vendor/assets/stylesheets/test.css'
    end

    context '.scss extension' do
      specify do
        expect(cli.send(:stylesheet_file, extension: '.scss')).to eql 'vendor/assets/stylesheets/test.scss'
      end
    end

    context 'with postfix' do
      specify do
        expect(cli.send(:stylesheet_file, postfix: '-embedded', extension: '.scss')).to eql 'vendor/assets/stylesheets/test-embedded.scss'
      end
    end
  end

  describe '#convert_for_asset_pipeline' do
    specify do
      expect(cli.send(:convert_for_asset_pipeline, "url(/this/is/a/link)")).to eql 'font-url(/this/is/a/link)'
    end

    specify do
      expect(cli.send(:convert_for_webpack, "url(/this/is/a/link)")).to eql 'url(~/this/is/a/link)'
    end

    specify do
      expect(cli.send(:convert_for_webpack, "url('/this/is/a/link')")).to eql "url('~/this/is/a/link')"
    end

    specify do
      expect(cli.send(:convert_for_webpack,
                      "url(data:application/octet-stream;base64,FFF)")).to eql 'url(data:application/octet-stream;base64,FFF)'
    end

    specify do
      expect(cli.send(:convert_for_asset_pipeline,
                      "url(data:application/octet-stream;base64,FFF)")).to eql 'url(data:application/octet-stream;base64,FFF)'
    end
  end

  describe '#fontello_name' do
    context 'no config_file specified' do
      let(:cli) { described_class.new({}) }
      specify do
        expect(cli.send(:fontello_name)).to eql nil
      end
    end

    context 'specified config file doesnt exist' do
      let(:cli) { described_class.new(config_file: 'foo') }
      specify do
        expect(cli.send(:fontello_name)).to eql nil
      end
    end

    context 'name is empty' do
      let(:cli) { described_class.new(config_file: 'spec/fixtures/empty_name_config.json') }
      it 'should fall back to "fontello"' do
        expect(cli.send(:fontello_name)).to eql 'fontello'
      end
    end

    context 'correct config file' do
      specify do
        expect(cli.send(:fontello_name)).to eql 'test'
      end
    end
  end

  describe '#copy_config_json' do
    let(:zipfile) { instance_double('FontelloZipfile') }
    let(:config_file_path) { 'test/config.json' }

    subject do
      cli.send(:copy_config_json, zipfile, config_file_path)
    end

    specify do
      expect(zipfile).to receive(:extract).with(config_file_path, 'spec/fixtures/fontello/config.json')
      subject
    end
  end

  describe '#open' do
    it 'opens a new session when config is present' do
      fontello_api = instance_double(FontelloRailsConverter::FontelloApi, session_url: 'https://fontello.com/abc')
      cli.instance_variable_set(:@fontello_api, fontello_api)

      allow(cli).to receive(:config_file_exists?).and_return(true)
      expect(fontello_api).to receive(:new_session_from_config)
      expect(Launchy).to receive(:open).with('https://fontello.com/abc')

      cli.open
    end

    it 'reuses existing session when open_existing is enabled' do
      fontello_api = instance_double(FontelloRailsConverter::FontelloApi, session_url: 'https://fontello.com/existing')
      cli.instance_variable_set(:@fontello_api, fontello_api)
      cli.instance_variable_set(:@options, options.merge(open_existing: true))

      allow(cli).to receive(:config_file_exists?).and_return(true)
      expect(fontello_api).not_to receive(:new_session_from_config)
      expect(Launchy).to receive(:open).with('https://fontello.com/existing')

      cli.open
    end
  end

  describe '#download' do
    it 'downloads zip body into target file' do
      Tempfile.create('fontello-download') do |file|
        local_options = options.merge(zip_file: file.path)
        local_cli = described_class.new(local_options)

        fontello_api = instance_double(
          FontelloRailsConverter::FontelloApi,
          download_zip_body: 'zip-bytes',
          session_url: 'https://fontello.com/session',
          new_session_from_config: 'session-id'
        )
        local_cli.instance_variable_set(:@fontello_api, fontello_api)
        allow(local_cli).to receive(:config_file_exists?).and_return(true)

        local_cli.download

        expect(File.read(file.path)).to eq('zip-bytes')
      end
    end

    it 'builds a session from config when use_config is enabled' do
      Tempfile.create('fontello-download') do |file|
        local_options = options.merge(zip_file: file.path, use_config: true)
        local_cli = described_class.new(local_options)

        fontello_api = instance_double(
          FontelloRailsConverter::FontelloApi,
          download_zip_body: 'zip',
          session_url: 'https://fontello.com/session'
        )
        local_cli.instance_variable_set(:@fontello_api, fontello_api)
        allow(local_cli).to receive(:config_file_exists?).and_return(true)

        expect(fontello_api).to receive(:new_session_from_config)
        local_cli.download
      end
    end
  end

  describe '#copy' do
    it 'copies grouped zip files through dedicated handlers' do
      zipfile = instance_double(Zip::File)
      grouped = {
        'css' => ['css/test.css'],
        'font' => ['font/test.woff'],
        'config.json' => ['config.json'],
        'demo.html' => ['demo.html']
      }

      allow(cli).to receive(:prepare_directories)
      allow(cli).to receive(:zip_file_exists?).and_return(true)
      allow(zipfile).to receive(:group_by).and_return(grouped)

      expect(cli).to receive(:download)
      expect(cli).to receive(:copy_stylesheets).with(zipfile, ['css/test.css'])
      expect(cli).to receive(:copy_font_files).with(zipfile, ['font/test.woff'])
      expect(cli).to receive(:copy_config_json).with(zipfile, 'config.json')
      expect(cli).to receive(:copy_icon_guide).with(zipfile, 'demo.html')

      allow(Zip::File).to receive(:open).with('tmp/fontello.zip').and_yield(zipfile)

      cli.copy
    end

    it 'skips download when no_download is enabled' do
      zipfile = instance_double(Zip::File,
                                group_by: { 'css' => [], 'font' => [], 'config.json' => ['config.json'], 'demo.html' => ['demo.html'] })
      cli.instance_variable_set(:@options, options.merge(no_download: true))

      allow(cli).to receive(:prepare_directories)
      allow(cli).to receive(:zip_file_exists?).and_return(true)
      allow(Zip::File).to receive(:open).and_yield(zipfile)
      allow(cli).to receive(:copy_stylesheets)
      allow(cli).to receive(:copy_font_files)
      allow(cli).to receive(:copy_config_json)
      allow(cli).to receive(:copy_icon_guide)

      expect(cli).not_to receive(:download)
      cli.copy
    end
  end

  describe '#convert' do
    it 'runs copy and conversion steps' do
      expect(cli).to receive(:copy)
      expect(cli).to receive(:convert_stylesheets).with(nil)
      expect(cli).to receive(:convert_icon_guide)

      cli.convert
    end
  end

  describe '#prepare_directories' do
    it 'creates target directories' do
      expect(FileUtils).to receive(:mkdir_p).with('vendor/assets/fonts')
      expect(FileUtils).to receive(:mkdir_p).with('vendor/assets/stylesheets')
      expect(FileUtils).to receive(:mkdir_p).with('vendor/assets')
      expect(FileUtils).to receive(:mkdir_p).with('public')

      cli.send(:prepare_directories)
    end
  end

  describe '#copy_font_files' do
    it 'extracts only known font file types' do
      zipfile = instance_double(Zip::File)
      files = ['font/a.woff', 'font/b.svg', 'font/readme.txt']

      expect(zipfile).to receive(:extract).with('font/a.woff', 'vendor/assets/fonts/a.woff')
      expect(zipfile).to receive(:extract).with('font/b.svg', 'vendor/assets/fonts/b.svg')

      cli.send(:copy_font_files, zipfile, files)
    end
  end

  describe '#copy_stylesheets' do
    it 'extracts only css files' do
      zipfile = instance_double(Zip::File)
      files = ['css/a.css', 'css/b.scss']

      expect(zipfile).to receive(:extract).with('css/a.css', 'vendor/assets/stylesheets/a.css')

      cli.send(:copy_stylesheets, zipfile, files)
    end
  end

  describe '#convert_icon_guide' do
    it 'rewrites icon guide links for asset pipeline' do
      Dir.mktmpdir do |dir|
        guide_file = File.join(dir, 'fontello-demo.html')
        File.write(guide_file, "<link href='css/test.css'>url('./font/test.woff')")

        local_cli = described_class.new(options.merge(icon_guide_dir: dir))
        local_cli.send(:convert_icon_guide)

        content = File.read(guide_file)
        expect(content).to include('/assets/test.css')
        expect(content).to include("url('/assets/test.woff')")
      end
    end
  end

  describe '#convert_stylesheets' do
    let(:css_content) do
      <<~CSS
        [class^="icon-"] { font-family: "test"; }
        .icon-glass:before { content: '\\e800'; }
        @font-face { src: url('../font/test.woff'); }
      CSS
    end

    it 'converts stylesheets for asset pipeline and removes original css' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'test.css'), css_content)
        File.write(File.join(dir, 'test-embedded.css'), css_content)

        local_cli = described_class.new(options.merge(stylesheet_dir: dir, stylesheet_extension: '.scss'))
        local_cli.send(:convert_stylesheets, false)

        expect(File.exist?(File.join(dir, 'test.css'))).to eq(false)
        expect(File.exist?(File.join(dir, 'test-embedded.css'))).to eq(false)

        converted = File.read(File.join(dir, 'test.scss'))
        expect(converted).to include('font-url(')
        expect(converted).to include('%icon-base')
      end
    end

    it 'converts stylesheets for webpack mode' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'test.css'), css_content)
        File.write(File.join(dir, 'test-embedded.css'), css_content)

        local_cli = described_class.new(options.merge(stylesheet_dir: dir, stylesheet_extension: '.scss'))
        local_cli.send(:convert_stylesheets, true)

        converted = File.read(File.join(dir, 'test.scss'))
        expect(converted).to include("url('~test.woff')")
      end
    end
  end

  describe '#config_file_exists?' do
    it 'returns true when config file exists' do
      local_cli = described_class.new(options.merge(config_file: 'spec/fixtures/fontello/config.json'))
      expect(local_cli.send(:config_file_exists?)).to eq(true)
    end
  end

  describe '#zip_file_exists?' do
    it 'returns true when zip file exists' do
      Tempfile.create('fontello-zip') do |file|
        local_cli = described_class.new(options.merge(zip_file: file.path))
        expect(local_cli.send(:zip_file_exists?)).to eq(true)
      end
    end

    it 'returns false when zip file is missing' do
      local_cli = described_class.new(options.merge(zip_file: '/missing/file.zip'))
      expect(local_cli.send(:zip_file_exists?)).to eq(false)
    end
  end
end
