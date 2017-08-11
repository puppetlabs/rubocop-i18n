shared_examples 'accepts' do |code|
  let(:source) { code }

  it 'does not register an offense' do
    investigate(cop, source)
    expect(cop.offenses).to be_empty
  end
end
