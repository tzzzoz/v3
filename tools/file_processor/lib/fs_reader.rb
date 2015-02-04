require 'find'

class FsReader

  attr_accessor :pathes

  def initialize(*pathes)
    @pathes = pathes
  end

  def each
    @pathes.each do |p|
      Find.find(p){ |f| yield f if f =~ /\.(jpg|jpeg|jpe)$/i }
    end
  end
end
