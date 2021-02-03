# frozen_string_literal: true

require 'spec_helper'
require 'hiera'

describe 'vision_server' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(root_home: '/root')
      end
      # Default check to see if manifest compiles
      context 'compile' do
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
