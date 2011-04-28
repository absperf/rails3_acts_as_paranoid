module ActiveRecord
  module FinderMethods

  def find_one(id)
      id = id.id if ActiveRecord::Base === id

      record = unscoped.where(primary_key.eq(id)).first

      unless record
        conditions = arel.where_sql
        conditions = " [#{conditions}]" if conditions
        raise RecordNotFound, "Couldn't find #{@klass.name} with ID=#{id}#{conditions}"
      end

      record
    end

    def find_some(ids)
      result = unscoped.where(primary_key.in(ids)).all

      expected_size =
        if @limit_value && ids.size > @limit_value
          @limit_value
        else
          ids.size
        end

      # 11 ids with limit 3, offset 9 should give 2 results.
      if @offset_value && (ids.size - @offset_value < expected_size)
        expected_size = ids.size - @offset_value
      end

      if result.size == expected_size
        result
      else
        conditions = arel.wheres.map { |x| x.value }.join(', ')
        conditions = " [WHERE #{conditions}]" if conditions.present?

        error = "Couldn't find all #{@klass.name.pluralize} with IDs "
        error << "(#{ids.join(", ")})#{conditions} (found #{result.size} results, but was looking for #{expected_size})"
        raise RecordNotFound, error
      end
    end
  end
end
