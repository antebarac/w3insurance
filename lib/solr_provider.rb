module ActsAsSolr
  module SearchExtension

    def wp_count(options, query, method)
      if(query[0].nil? || query[0] == "")
        super
      else
        method =~ /_solr$/ ? count_by_solr(prepare_query(query.first), options) : super
      end
    end
   
    def prepare_query(query)
      prepared_query = "" 
      query.force_encoding('utf-8').downcase().split().each do |token|
        prepared_query += " " unless prepared_query.empty?
        prepared_query += "(#{token} OR #{token}*)"
      end
      return prepared_query
    end

    def find_solr(*args)
      query = args[0]
      result = []
      if query.nil? || query == ""
        result = paginate({ :per_page => 15, :page => 1})
      else
        args[0] = prepare_query(query)
        result = find_by_solr(*args).docs
      end
      return result 
    end
  end
end

module ActsAsSolr::ClassMethods
  include ActsAsSolr::SearchExtension
end

