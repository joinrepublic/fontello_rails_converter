require 'spec_helper'

RSpec.describe FontelloRailsConverter::ColorizedOutput do
  let(:dummy_class) do
    Class.new do
      include FontelloRailsConverter::ColorizedOutput
    end
  end

  subject(:instance) { dummy_class.new }

  describe '#colorize' do
    it 'wraps text with ANSI color codes' do
      expect(instance.colorize('hello', 32)).to eq("\e[32mhello\e[0m")
    end
  end

  describe 'generated color helpers' do
    it 'supports a representative color helper method' do
      expect(instance.green('ok')).to eq("\e[32mok\e[0m")
    end
  end
end
