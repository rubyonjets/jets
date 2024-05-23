module Jets::Git
  class Base
    extend Memoist

    def params
      base.merge(info)
    end
    memoize :params

    # interface method
    def info
      {}
    end

    def base
      {
        git_user: user.name
      }
    end

    def user
      User.new
    end
    memoize :user
  end
end
