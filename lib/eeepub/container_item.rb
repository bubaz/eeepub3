require 'builder'

module EeePub
  # Abstract base class for container item of ePub. Provides some helper methods.
  #
  # @abstract
  class ContainerItem
    class << self

      private

      # Set default value to attribute
      #
      # @param [Symbol] name the attribute name
      # @param [Object] default the default value
      def default_value(name, default)
        instance_variable_name = "@#{name}"
        define_method(name) do
          self.instance_variable_get(instance_variable_name) ||
            self.instance_variable_set(instance_variable_name, default)
        end
      end

      # Define alias of attribute accessor
      #
      # @param [Symbol] name the attribute name as alias
      # @param [Symbol] name the attribute name as source
      def attr_alias(name, src)
        alias_method name, src
        alias_method :"#{name}=", :"#{src}="
      end
    end

    # @param [Hash<Symbol, Object>] values the hash of symbols and objects for attributes
    def initialize(values)
      set_values(values)
    end

    # Set values for attributes
    #
    # @param [Hash<Symbol, Object>] values the hash of symbols and objects for attributes
    def set_values(values)
      values.each do |k, v|
        self.send(:"#{k}=", v)
      end
    end

    # Convert to xml of container item
    #
    # @return [String] the xml of container item
    def to_xml
      out = ""
      builder = Builder::XmlMarkup.new(:target => out, :indent => 2)
      builder.instruct!
      build_xml(builder)
      out
    end

    # Save as container item
    #
    # @param [String] filepath the file path for container item
    def save(filepath)
      File.open(filepath, 'w') do |file|
        file << self.to_xml
      end
    end

    private

    # Guess media type from file name
    #
    # @param [String] filename the file name
    # @return [String] the media-type
    def guess_media_type(filename)
      ext = File.extname(filename)
      mimes = {
        '.png' => 'image/png',
        '.js' => 'application/x-javascript',
        '.html' => 'application/xhtml+xml',
        '.jpeg' => 'image/jpeg',
        '.jpg' => 'image/jpeg',
        '.gif' => 'image/gif',
        '.svg' => 'image/svg+xml',
        '.ncx' => 'application/x-dtbncx+xml',
        '.css' => 'text/css',
        '.less' => 'text/plain', #explicit not text/css because of validation failure
        '.mp4' => 'video/mp4',
        '.mp3' => 'audio/mpeg',
        '.webm' => 'video/webm',
        '.woff' => 'application/font-woff',
        '.otf' => 'application/vnd.ms-opentype',
        '.ttf' => 'application/vnd.ms-opentype',
        '.eot' => 'application/vnd.ms-opentype',
        '.db' =>'application/octet-stream',  #explicit,
        '.nes'=>'text/plain; charset=x-user-defined', #explicit
        '.txt'=>'text/plain'
      }

      mimes[ext] || 'application/octet-stream'

    end

    # Convert options for xml attributes
    #
    # @param [Hash<Symbol, Object>] hash the hash of symbols and objects for xml attributes
    # @return [Hash<String, Object>] the options for xml attributes
    def convert_to_xml_attributes(hash)
      result = {}
      hash.each do |k, v|
        key = k.to_s.gsub('_', '-').to_sym
        result[key] = v
      end
      result
    end
  end
end
