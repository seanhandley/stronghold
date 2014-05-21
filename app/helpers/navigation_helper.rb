module NavigationHelper
  def build_support_navigation
    navigation = {}

    if can? :read, :instance
      navigation["Instances"] = support_instances_path
    end

    if can? :modify, :user
      navigation["Users and Roles"] = support_users_path
    end

    navigation
  end
end