module Startback
  module Support
    module DataObject

      def initialize(data = {})
        @_data = data.dup.freeze
      end

      attr_writer :_data
      protected :_data=

      def method_missing(name, *args, &bl)
        return super unless args.empty? && bl.nil?
        return super unless pair = _data_key_for(name)

        pair.last ? !!@_data[pair.first] : @_data[pair.first]
      end

      def [](name)
        return nil unless pair = _data_key_for(name, false, false)

        @_data[pair.first]
      end

      def respond_to?(name)
        super || !_data_key_for(name).nil?
      end

      def to_data
        @_data
      end
      alias :to_h :to_data

      def to_json(*args, &bl)
        to_data.to_json(*args, &bl)
      end

    private

      def _data_key_for(key, try_camelize = _data_allow_camelize, try_query = _data_allow_query)
        if @_data.key?(key)
          [key, false]
        elsif @_data.key?(key.to_s)
          [key.to_s, false]
        elsif key.is_a?(String) && @_data.key?(key.to_sym)
          [key.to_sym, false]
        elsif try_camelize
          cam = key.to_s.gsub(/_([a-z])/){ $1.upcase }.to_sym
          _data_key_for(cam, false, true)
        elsif try_query && key.to_s =~ /\?$/
          got = _data_key_for(key[0...-1].to_sym, false, false)
          got ? [got.first, true] : _data_key_not_found(key)
        else
          _data_key_not_found(key)
        end
      end

      def _data_allow_camelize
        true
      end

      def _data_allow_query
        true
      end

      def _data_key_not_found(key)
        nil
      end
    end # module DataObject
  end # module Support
end # module Startback
