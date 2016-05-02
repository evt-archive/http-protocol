module HTTP
  module Protocol
    class Headers
      module Common
        def self.included(cls)
          cls.class_eval do
            define_header "Connection" do
              def connections
                %w(close keep-alive)
              end

              def validate(value)
                unless connections.include? value
                  raise Error.new "bad Connection value #{value.inspect}; valid values are #{connections.map(&:inspect) * ", "}"
                end
              end

              def coerce(value)
                value.downcase
              end
            end

            define_header "Content-Length" do
              def validate(value)
                if value < 0
                  raise Error.new "content length must not be negative"
                end
              end

              def coerce(str)
                str.to_i
              end

              def to_i
                value
              end
            end

            define_header "Date" do
              def coerce(str)
                Time.httpdate str
              rescue ArgumentError => error
                raise Error.new error.message
              end

              def value
                @value && @value.httpdate
              end
            end
          end
        end
      end
    end
  end
end
