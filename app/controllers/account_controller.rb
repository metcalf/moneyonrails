class AccountController < ApplicationController
  layout "moneyonrails"
  live_tree :account_tree, {:model => :account, :get_item_name_proc => Proc.new { |account| account_tree_line(account) }, :get_item_children_proc => Proc.new { |account| account.children } }
  live_tree :group_tree, {:model => :group, :get_item_name_proc => Proc.new { |group| group_tree_line(group) }, 
                            :get_item_children_proc => Proc.new do |group|
                              if(group.instance_of?(Account))
                                []
                              else
                                group.children
                              end
                            end
                          }


  def index
    get_results
    @groupRoot = Group.getRoot
  end
  
  def self.account_tree_line(item)
    id = 'edit' << item.id.to_s
    result = "<b>#{item.name}</b>"
    if item.instance_of?(Account)
      color = item.amount < 0 ? '#FF0000' : '#000000'
      if item.user_id != User.current_user.id
        result << "  (#{item.user.name})"
      else 
        result <<  "<span style='padding-left:1em; color:#{color}'>$#{item.amount.to_s}</span>"
      end 
        result << link_to_remote('(Edit)', 'edit', item.id)
    end
    return result
  end
  
  def self.group_tree_line(item)
    id = 'edit' << item.id.to_s
    result = "<b>#{item.name}</b>"
    if(item.instance_of?(Account) && item.user_id != User.current_user.id)
        result << "  (#{item.user.name})"
    elsif item.instance_of?(Group)
      result << link_to_remote('(Edit)', 'editGroup', item.id)
    end
    return result
  end
  
  def self.link_to_remote(name, action, id)
    "<a href='#' id='#{action}#{id}' onclick=\"new Ajax.Updater('#{action}#{id}', '/account/#{action}/#{id}', {asynchronous:true, evalScripts:true, insertion:Insertion.After}); return false;\">#{name}</a>"
  end
  
  def edit
    if(params[:id])
      @edit = Account.find(:first, :conditions => {:id => params[:id]}, :include => [:parent, :users])
    end
    @parents = Account.find(:all, :conditions => {:user_id => current_user.id})
    render :partial => 'edit'
  end
  
  def editGroup
    if(params[:id])
      @editGroup = Group.find(:first, :conditions => { :id => params[:id] }, :include => :accounts)
    end
    render :partial => 'edit_group'
  end

  def update
    edit = Account.find(:first, :conditions => ['id = ?', params[:id]])
    
    params[:account][:user_id] = edit.user_id
    params[:account][:type_id] = edit.account_type.id
    
    edit = setAccount(edit, params[:account], params[:users])
    
    redirect_to :action => 'index'
  end
  
  def create
    acct = setAccount(Account.new, params[:account], params[:users])
    redirect_to :action => 'index'
  end
  
  def setGroup
    if params[:group][:id]
      group = Group.find(:first, :conditions => {:id => params[:group][:id]}, :include => :accounts)
    end
    if(!group)
      group = Group.new
    end
    
    if(params[:account][:id].respond_to?(:each_value))
      group.user_id = current_user.id
      group.name = params[:group][:name]
      accounts = Array.new
      params[:account][:id].each_value do |id|
        accounts << Account.find(:first, :conditions => ['id = ?', id])
      end
      group.accounts = accounts
      group.save
    elsif(!group.new_record?)
      group.destroy
    end  
    
    redirect_to :action => :index
  end
  
  def deleteGroup
    begin
      group = Group.find(params[:id], :select => '`groups`.id, `accounts`.id', :include => :accounts)
      group.destroy
      flashInit(:notice)
      flash[:notice] << "'" + group.name + "' destroyed successfully"
    rescue
      flashInit(:warning)
      flash[:warning] << "There was an error deleting the specified group"
    ensure
      redirect_to :action => :index
    end
  end
  
  
  def delete
    Account.find(:first, :conditions => {:id => params[:id]}, :include => [:user_accounts, :groups]).destroy
    redirect_to :action => 'index'
  end
  
  def get_results
    @root = Account.find(:first, :conditions => { :account_type_id => ROOT_ACCT, :user_id => current_user.id }, :include => {:children => { :events_accounts => :event }, :events_accounts => :event} );
    #@foreignResults = Account.find(:all, :conditions => ['user_accounts.`user_id` = ?', current_user.id], :include => :user_accounts)  
  end
  
  def auto_complete_for_user_username
    @results = User.find(:all, 
    :conditions => [ 'LOWER(name) LIKE ? OR LOWER(login) LIKE ?',
      '%' + params[:user][:username].downcase + '%',
      '%' + params[:user][:username].downcase + '%'], 
    :order => 'name ASC',
    :limit => 10)
    render :partial => 'users_complete'  
  end
  
  
 
  private
  
  def setAccount(acct, params, users)
    Account.transaction do
      UserAccount.transaction do
        acct.user_id = params[:user_id] != nil ? params[:user_id] : current_user.id
        acct.name = params[:name]
        acct.account_type_id = params[:type_id] ? params[:type_id] : NORM_ACCT
        # TODO use a real exception class here
        acct.parent_id = Account.exists?(params[:parent_id]) ? params[:parent_id] : (raise "Invalid Parent ID")
        acct.deleteLock = 0
        acct.parentLock = 0
        if acct.save
          flash[:notice] ||= ""
          flash[:notice] << "Account #{acct.name} successfully saved. <br />"
        else
          flash[:warning] ||= ""
          flash[:warning] << acct.errors.full_messages << "<br />"
          return nil
        end

        acct.setAuthorized(users)
        acct
      end
    end
  end

end