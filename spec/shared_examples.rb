# frozen_string_literal: true

require 'rubocop/rspec/support'

shared_examples 'accepts' do |code|
  let(:source) { code }

  it 'does not register an offense' do
    expect(@offenses).to be_empty
  end
end

shared_examples 'a_detecting_cop' do |unfixed, _function, expected_warning|
  let(:source) { unfixed.to_s }
  it 'has the correct rubocop warning' do
    expect(@offenses[0]).not_to be_nil
    expect(@offenses[0].message).to include(expected_warning)
  end

  it 'has the correct number of offenses' do
    expect(@offenses.size).to eq(1)
  end
end

shared_examples 'a_no_cop_required' do |fixed, _function|
  let(:source) { fixed.to_s }
  it 'has no offenses found' do
    expect(@offenses).to be_empty
  end
end

shared_examples 'a_fixing_cop' do |unfixed, fixed, _function|
  let(:source) { unfixed.to_s }
  it 'autocorrects' do
    corrected = autocorrect_source(unfixed)
    expect(corrected).to eq(fixed)
  end

  it 'is idempotent' do
    idempotent = autocorrect_source(fixed)
    expect(idempotent).to eq(fixed)
  end
end
