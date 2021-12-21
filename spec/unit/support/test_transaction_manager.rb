require 'spec_helper'
module Startback
  module Support
    describe TransactionManager do
      subject do
        TransactionManager.new(db).call(nil, op) do
          op.call
        end
      end

      class FakeDatabase
        def initialize
          @called = false
        end
        attr_reader :called

        def transaction
          @called = true
          yield
        end
      end

      let(:db) do
        FakeDatabase.new
      end

      context 'when called with a default operation' do
        class OperationNotManagingTransactions < Startback::Operation
          def call
            12
          end
        end

        let(:op) do
          OperationNotManagingTransactions.new
        end

        it 'calls db.transaction' do
          expect(subject).to eql(12)
          expect(db.called).to eql(true)
        end
      end

      context 'when called with an operation that manages the transactions itself' do
        class OperationManagingTransactions < Startback::Operation
          self.transaction_policy = :within_call

          def call
            12
          end
        end

        let(:op) do
          OperationManagingTransactions.new
        end

        it 'calls db.transaction' do
          expect(subject).to eql(12)
          expect(db.called).to eql(false)
        end
      end
    end
  end
end
