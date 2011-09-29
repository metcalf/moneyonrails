module EventHelper

  def setupVars
    if @edit 
      @name = @edit.name
      @moment = @edit.moment
      @credits = @edit.credits
      @debits = @edit.debits
      @amount = @edit.amount
      @wid = "editWindow"
      @action = 'update'
      @link = 'edit' << @edit.id.to_s
      @isEstimate = (@edit.isEstimate == 1)
    else
      @action = 'create'
      @wid = 'editWindow'
      @isEstimate = false
    end
  end
  
  def txnAccount(isCredit, input)
    line = ""
    filterLinks(input).each do |evtAcct|
      acct = evtAcct.account
      color = if(acct == nil)
                 '#999999' # Grey for unknown
               elsif(!(acct.asset?) ^ (isCredit == 1))
                 '#FF0000' # Red for negative
               else
                 '#000000' # Black for positive
               end
      line << "<div style=\"color:#{color}\" class=\"clear\">"
      line << evtAcct.name
      if(acct != nil && acct.user != current_user)
        line << "(#{acct.user.name})"
      end
      line << '</div>'
    end
    
    line
  end
  
  def filterLinks(records)
    ok = Array.new
    records.each do |record|
      if(!record.account.link?)
        ok << record
      end
    end
    ok  
  end

end