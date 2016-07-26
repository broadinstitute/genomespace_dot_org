class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :login, :password, :password_confirmation, :remember_me, :cms_admin, :forem_admin, :deliverables_admin, :super_admin
  
  attr_accessor :login
  
  def to_s
  	return self.email
  end
  
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
  
  def self.admin_description
  	return "User accounts are logins to let administrators log into the GenomeSpace website and edit content.  Each account has several flags that indicate how much access they have to the site: <ul><li><strong>Deliverables Admin</strong>: Can approve project deliverables only</li><li><strong>CMS Admin</strong>: Can edit pages and other content</li><li><strong>Super Admin</strong>: Can edit site content and user accounts</li></ul>"
  end
  
end
