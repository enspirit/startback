module Startback
  module Support
    module DataObject

      def initialize(data)
        @_data = data.dup.freeze
      end

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

      def to_json(*args, &bl)
        to_data.to_json(*args, &bl)
      end

    private

      def _data_key_for(key, try_camelize = true, try_query = true)
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
          got ? [got.first, true] : nil
        else
          nil
        end
      end

    end # module DataObject
  end # module Support
end # module Startback
