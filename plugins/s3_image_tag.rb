module Jekyll
  class S3ImageTag < Liquid::Tag

    def initialize(tag_name, text, token)
      super
      @text = text.strip
      @text =~ /(\w+\.\w+)(\sbucket:)?(\w*)/i
      @file_name = $1
      @bucket_name = $3.empty? ? get_config('aws_bucket') : $3
    end

    def render(context)
      if @file_name && @bucket_name
        "<img src='https://s3.amazonaws.com/#{@bucket_name}/#{@file_name}'>"
      else
        "Error processing input, expected syntax: {% s3_image file_name [bucket:bucket_name] %}"
      end
    end


    private

    def get_config(string)
      Jekyll.configuration({})[string]
    end
  end

end

Liquid::Template.register_tag('s3_image', Jekyll::S3ImageTag)
