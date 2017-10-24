# frozen_string_literal: true

module OpenapiParser
  class Node
    class Info < Node
      def title
        attributes["title"]
      end

      def description
        attributes["description"]
      end

      def terms_of_service
        attributes["termsOfService"]
      end

      def contact
        attributes["contact"]
      end

      def license
        attributes["license"]
      end

      def version
        attributes["version"]
      end
    end
  end
end
