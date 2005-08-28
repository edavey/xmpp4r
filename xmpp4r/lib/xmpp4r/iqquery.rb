# =XMPP4R - XMPP Library for Ruby
# License:: GPL (v2 or later)
# Website::http://home.gna.org/xmpp4r/

require 'xmpp4r/xmlelement'

module Jabber
  ##
  # A class used to build/parse IQ Query requests/responses
  #
  class IqQuery < XMLElement
    @@namespace_classes = {}

    ##
    # Initialize a <query/> element
    #
    # Does nothing more than setting the element's name to 'query'
    def initialize
      super("query")
    end

    ##
    # Create a new iq from query
    # xmlelement:: [REXML::Element] to import, will be automatically converted if namespace appropriate
    def IqQuery.import(xmlelement)
      if @@namespace_classes.has_key?(xmlelement.namespace)
        @@namespace_classes[xmlelement.namespace]::new.import(xmlelement)
      else
        IqQuery::new.import(xmlelement)
      end
    end

    ##
    # Add a class by namespace for automatic IqQuery conversion (see IqQuery.import)
    # ns:: [String] Namespace (e.g. 'jabber:iq:roster')
    # queryclass:: [IqQuery] Query class derived from IqQuery
    def IqQuery.add_namespace(ns, queryclass)
      @@namespace_classes[ns] = queryclass
    end
  end
end
