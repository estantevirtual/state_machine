require 'byebug'
require 'spec_helper'
require_relative '../../lib/state_machine'
require_relative '../../lib/state_machine/event'
require_relative '../../lib/state_machine/rule'
require_relative '../../lib/state_machine/state_template'
require_relative '../../lib/state_machine/state_notifier_factory'
require_relative '../../lib/state_machine/notifiers/call_event_method_notifier'
require_relative '../../lib/state_machine/notifiers/change_state_value_notifier'
require_relative '../../lib/state_machine/notifiers/retrieve_state_value_notifier'
require_relative '../../lib/state_machine/state_transaction_not_permitted_error'
require_relative 'shared_contexts/entity'

describe Entity do
  context "when defined state_field is #status" do
    describe ".new" do
      context "when initial state value is defined as :created" do
        it "changes #status value to :created" do
          expect(subject.status).to be == :created
        end
      end
    end

    describe "#event_without_param" do
      context "with #status == :created and change_to :second_state, :from => :created defined" do
        before do
          subject.status = :created
        end

        it "changes #status to :second_state" do
          subject.event_without_param
          expect(subject.status).to be == :second_state
        end
      end

      context "with #status == :second_state and change_to :third_state, :from => :second_state defined" do
        before do
          subject.status = :second_state
        end

        it "changes #status to :third_state" do
          subject.event_without_param
          expect(subject.status).to be == :third_state
        end
      end


      context "with #status == :third_state and change_to :fourth_state, :from => :third_state defined, :if => :is_this_true?" do
        before do
          subject.status = :third_state
        end

        context "when #is_this_true? == true" do
          before do
            allow(subject).to receive(:is_this_true?).and_return true
          end

          it "changes #status to :fourth_state" do
            subject.event_without_param
            expect(subject.status).to be == :fourth_state
          end
        end

        context "when #is_this_true? == false" do
          before do
            allow(subject).to receive(:is_this_true?).and_return false
          end

          it "raises StateTransactionNotPermittedError" do
            expect { subject.event_without_param }.to raise_error StateTransactionNotPermittedError
          end
        end
      end

      context "with #status == :another and change_to :third_state, :from => :second_state defined" do
        before do
          subject.status = :another
        end

        it "raises StateTransactionNotPermittedError" do
          expect { subject.event_without_param }.to raise_error StateTransactionNotPermittedError
        end
      end
    end

    describe "#event_with_param" do
      context "with #status == :created and change_to :second_state, :from => :created defined" do
        before do
          subject.status = :created
        end

        it "changes #status to :second_state" do
          subject.event_with_param(:any)
          expect(subject.status).to be == :second_state
        end
      end

      context "with #status == :second_state and change_to :third_state, :from => :second_state defined" do
        before do
          subject.status = :second_state
        end

        it "changes #status to :third_state" do
          subject.event_with_param(:any)
          expect(subject.status).to be == :third_state
        end
      end


      context "with #status == :third_state and change_to :fourth_state, :from => :third_state defined, :if => :is_param_correct?" do
        let(:correct_param) { :correct }

        before do
          allow(subject).to receive(:is_param_correct?).and_return false
          allow(subject).to receive(:is_param_correct?).with(correct_param).and_return true
          subject.status = :third_state
        end

        context "when #event_with_param is called with correct_param" do
          it "changes #status to :fourth_state" do
            subject.event_with_param(correct_param)
            expect(subject.status).to be == :fourth_state
          end
        end

        context "when #event_with_param is NOT called with correct_param" do
          it "raises StateTransactionNotPermittedError" do
            expect { subject.event_with_param(:any) }.to raise_error StateTransactionNotPermittedError
          end
        end
      end

      context "with #status == :another and change_to :third_state, :from => :second_state defined" do
        before do
          subject.status = :another
        end

        it "raises StateTransactionNotPermittedError" do
          expect { subject.event_with_param(:any) }.to raise_error StateTransactionNotPermittedError
        end
      end
    end
  end
end


#class Rule
  #def self.call(params)
    #rule_interfaces = {
      #if: ConditionalRule,
      #from: FromRule
    #}
    #interfaces = params.map do |rule_name, rule_arg|
      #rule_interfaces[rule_name]
    #end
    #Rule.new(interfaces)
  #end

  #def initialize(interfaces)

  #end
#end
