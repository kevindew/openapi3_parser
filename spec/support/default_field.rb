# frozen_string_literal: true

RSpec.shared_examples "default field" do |field:, defaults_to:, var_name: nil|
  var_name ||= field.to_sym

  context "when #{field} is not set" do
    let(var_name) { nil }

    it "has a default value of #{defaults_to}" do
      node = described_class.new(node_factory_context).node(node_context)
      expect(node[field]).to eq defaults_to
    end
  end
end
