module GlobalModelMethods
    class SanitizationWrapper
        def before_validation(record)
            record.attributes.each do |key, value|
                record[key] = value.squish.force_encoding('utf-8') if value.is_a?(String)
            end
        end
    end
end