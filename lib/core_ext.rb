module ActiveRecord
  module FinderMethods

    alias :old_find_one :find_one
    alias :old_find_some :find_some

    def find_one(id)
      ignore_deleted_at_is_nil_condition
      old_find_one(id)
    end

    def find_some(ids)
      ignore_deleted_at_is_nil_condition
      old_find_some(ids)
    end

    private

    def ignore_deleted_at_is_nil_condition
      @where_values = @where_values.reject do |c|
        if c.kind_of? String
          c == "#{table.name}.deleted_at IS NULL"
        elsif c.kind_of? Arel::Nodes::Equality
          c.right.nil? && c.left && c.left.kind_of?(Arel::Attributes::Attribute) && c.left.name == 'deleted_at'
        end
      end
    end
  end
end
