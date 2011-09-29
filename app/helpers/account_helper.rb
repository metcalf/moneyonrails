module AccountHelper

  def listAccounts(parent)
    @content = parent.name
    if parent.children.size > 0
      parent.children.each do |child|
        @content = @content << listAccounts(child)
      end
    end
    '<div class="indent">' << @content << '</div>'
  end

end