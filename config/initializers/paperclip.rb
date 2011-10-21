module Paperclip
  class ChangeColor < Processor
    def initialize file, options = {}, attachment = nil
#      raise options.inspect unless options[:geometry] == "4000x4000"
      super
      @file = file
      @current_format = File.extname(@file.path)
      @basename = File.basename(@file.path, @current_format)
      @resize = options[:resize]
      @color = options[:color]
    end

    def make
      dst = Tempfile.new(@basename)
      dst.binmode

      command = "#{File.expand_path(@file.path)} -fill '#{@color}' -opaque black -scale '#{@resize}' #{File.expand_path(dst.path)}"
      begin
        success = Paperclip.run("convert", command)
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error converting the color for #{@basename}"
      end

      dst
    end
  end
end
