module JsonSchema
  include Concerns::Enum

  extend self

  def parameter(order = 0)
    <<-PARAMETER
    {
      "type": "object",
      "title": "Parameter",
      "properties": {
        "name": {
          "type": "string",
          "title": "Name",
          "propertyOrder": 1,
          "minLength": 5
        },
        "source": {
          "type": "integer",
          "title": "Source",
          "enum": [
            0, 1, 2, 3, 4, 5
          ],
          "options": {
            "enum_titles": [
              "QueryString", "FormData", "JSONBody", "Header", "Cookie", "PathValue"
            ]
          },
          "propertyOrder": 2
        },
        "index": {
          "type": "integer",
          "title": "Index",
          "minimum": 0,
          "propertyOrder": 3
        }
      },
      "options": {
        "layout": "grid"
      },
      "propertyOrder": #{order},
      "required": [
        "source"
      ]
    }
    PARAMETER
  end

  def pair_value(order = 0)
    <<-PAIRVALUE
    {
      "type": "object",
      "title": "PairValue",
      "properties": {
        "name": {
          "type": "string",
          "title": "Name",
          "minLength": 1,
          "propertyOrder": 1
        },
        "value": {
          "type": "string",
          "title": "Value",
          "propertyOrder": 2
        }
      },
      "required": [
        "name", "value"
      ],
      "propertyOrder": #{order}
    }
    PAIRVALUE
  end

  def default_value(order = 0)
    <<-DEFAULTVALUE
    {
      "type": "object",
      "title": "DefaultValue",
      "properties": {
        "body": {
          "type": "string",
          "title": "Body",
          "format": "textarea",
          "description": "内容可以为Base64编码，也可以为原始数据",
          "options": {
            "grid_columns": 12
          },
          "propertyOrder": 1
        },
        "headers": {
          "type": "array",
          "format": "table",
          "title": "Headers",
          "options": {
            "grid_columns": 6
          },
          "items": #{pair_value},
          "propertyOrder": 2
        },
        "cookies": {
          "type": "array",
          "format": "table",
          "title": "Cookies",
          "options": {
            "grid_columns": 6
          },
          "items": {
            "$ref": #{pair_value}
          },
          "propertyOrder": 3
        }
      },
      "propertyOrder": #{order}
    }
    DEFAULTVALUE
  end

  def conditions(order = 0)
    <<-CONDITIONS
    {
      "type": "array",
      "format": "table",
      "title": "Conditions",
      "items": {
        "type": "object",
        "properties": {
          "parameter": #{parameter},
          "cmp": {
            "type": "integer",
            "title": "Cmp",
            "enum": #{CompareType.values},
            "options": {
              "enum_titles": #{CompareType.keys.map(&:to_s)}
            }
          },
          "expect": {
            "type": "string",
            "title": "Expect"
          }
        },
        "required": [
          "cmp", "expect"
        ]
      },
      "propertyOrder": #{order}
    }
    CONDITIONS
  end

  def cluster_id(order = 0)
    clusters = Cluster.all
    <<-CLUSTERID
    {
      "type": "integer",
      "title": "ClusterID",
      "enum": #{clusters.map(&:id)},
      "options": {
        "enum_titles": #{clusters.map(&:name)}
      },
      "propertyOrder": #{order}
    }
    CLUSTERID
  end

  def status(order = 60)
    <<-STATUS
    {
      "type": "integer",
      "title": "Status",
      "enum": [
        0, 1, 2
      ],
      "options": {
        "enum_titles": [
          "Down", "Up", "Unknown"
        ]
      },
      "propertyOrder": #{order}
    }
    STATUS
  end

  def api(order = 0)
    apis = Api.all
    <<-API
    {
      "type": "integer",
      "title": "API",
      "enum": #{apis.map(&:id)},
      "options": {
        "enum_titles": #{apis.map(&:name)}
      },
      "propertyOrder": #{order}
    }
    API
  end

end
