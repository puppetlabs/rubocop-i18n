shared_examples 'accepts' do |code|
  let(:source) { code }

  it 'does not register an offense' do
    investigate(cop, source)
    expect(cop.offenses).to be_empty
  end
end

shared_examples 'a_detecting_cop' do |unfixed, function, expected_warning|
  let(:source) { "#{unfixed}" }
  it 'has the correct rubocop warning' do
    expect(cop.offenses[0]).not_to be_nil
    expect(cop.offenses[0].message).to include(expected_warning)
  end

  it 'has the correct number of offenses' do
    expect(cop.offenses.size).to eq(1)
  end
  end

shared_examples 'a_multiple_detecting_cop' do |unfixed, function, expected_warning|
  let(:source) { "#{unfixed}" }
  it 'has the correct rubocop warning' do
    expect(cop.offenses[0]).not_to be_nil
    expect(cop.offenses[0].message).to include(expected_warning)
  end

  it 'has the correct number of offenses' do
    expect(cop.offenses.size).to be >= 1
  end
end

shared_examples 'a_no_cop_required' do |fixed, function|
  let(:source) { "#{fixed}" }
  it 'has no offenses found' do
    expect(cop.offenses).to be_empty 
  end
end

shared_examples 'a_fixing_cop' do |unfixed, fixed, function|
  let(:source) { "#{unfixed}" }
  it 'autocorrects' do
    corrected = autocorrect_source(unfixed)
    expect(corrected).to eq(fixed)
  end

  it 'is idempotent' do
    idempotent = autocorrect_source(fixed)
    expect(idempotent).to eq(fixed)
  end
end
