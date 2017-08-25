module UsersHelpers


  #################################################
  def get_user_with_id(id)
    return User.first(id: id.to_i)
  end

end