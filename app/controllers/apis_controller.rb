class ApisController < ApplicationController
  before_action :set_api, only: [:edit, :update, :show]
  before_action :set_schema, only: [:new, :edit, :show]

  def index
    @apis = Api.all(after: after_index, limit: per_page)
  end

  def new
    @api = Api.new
  end

  def edit; end
  def show; end

  def create
    @api = Api.create(server_params)

    if @api.id
      render json: {url: apis_url}, status: 301
    else
      render json: {msg: '创建失败'}
    end
  end

  def update
    ok = @api.update(server_params)

    if ok
      render json: {url: apis_url}, status: 301
    else
      render json: {msg: '更新失败'}
    end
  end

  def destroy
    redirect_to apis_url if Api.destroy(params.slice(:id))
  end

  private

  def set_api
    @api = Api.find_by(params.slice(:id))
  end

  def server_params
    params.delete(:api)
    [:ip_access_control, :default_value, :render_template].each do |x|
      if params[x].blank? || params[x].as_json.all?{|_, v| v.blank?}
        params[x] = nil
      end
    end
    if params[:nodes].present?
      params[:nodes].each do |x|
        byebug
        x[:cache] = nil if (x[:cache] || {})[:keys].blank?
        if x[:default_value].blank? || x[:default_value].as_json.all?{|_, v| v.blank?}
          x[:default_value] = nil
        end
      end
    end
    puts params.to_json
    params
  end

  def set_schema
    clusters = Cluster.all()
    @api_schema = <<-API
    {
      "type": "object",
      "format": "grid",
      "definitions": {
        "parameter": {
          "type": "object",
          "title": "Parameter",
          "properties": {
            "name": {
              "type": "string",
              "title": "Name",
              "propertyOrder": 1
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
              "propertyOrder": 3
            }
          },
          "options": {
            "layout": "grid"
          }
        },
        "pair_value": {
          "type": "object",
          "title": "PairValue",
          "properties": {
            "name": {
              "type": "string",
              "title": "Name",
              "propertyOrder": 1
            },
            "value": {
              "type": "string",
              "title": "Value",
              "propertyOrder": 2
            }
          }
        },
        "default_value": {
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
              "items": {
                "$ref": "#/definitions/pair_value"
              },
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
                "$ref": "#/definitions/pair_value"
              },
              "propertyOrder": 3
            }
          }
        }
      },
      "properties": {
        "name": {
          "type": "string",
          "title": "Name",
          "propertyOrder": 20
        },
        "url_pattern": {
          "type": "string",
          "title": "UrlPattern",
          "propertyOrder": 50
        },
        "method": {
          "type": "string",
          "title": "Method",
          "enum": [
            "GET", "POST", "PUT", "DELETE", "*"
          ],
          "propertyOrder": 40
        },
        "domain": {
          "type": "string",
          "title": "Domain",
          "propertyOrder": 30
        },
        "status": {
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
          "propertyOrder": 60
        },
        "ip_access_control": {
          "type": "object",
          "title": "IpAccessControl",
          "description": "只支持通配符`*`",
          "properties": {
            "whitelist": {
              "title": "白名单",
              "type": "array",
              "format": "table",
              "options": {
                "grid_columns": 6
              },
              "items": {
                "type": "string",
                "title": "IP地址",
                "minLength": 3,
                "maxLength": 15
              }
            },
            "blacklist": {
              "type": "array",
              "title": "黑名单",
              "format": "table",
              "options": {
                "grid_columns": 6
              },
              "items": {
                "type": "string",
                "title": "IP地址",
                "minLength": 3,
                "maxLength": 15
              }
            }
          },
          "propertyOrder": 100
        },
        "default_value": {
          "$ref": "#/definitions/default_value",
          "title": "DefaultValue",
          "propertyOrder": 200
        },
        "nodes": {
          "type": "array",
          "title": "Nodes",
          "format": "tabs",
          "items": {
            "type": "object",
            "title": "节点",
            "properties": {
              "cluster_id": {
                "type": "integer",
                "title": "ClusterID",
                "enum": #{clusters.map(&:id)},
                "options": {
                  "enum_titles": #{clusters.map(&:name)}
                }
              },
              "url_rewrite": {
                "type": "string",
                "title": "UrlRewrite",
              },
              "attr_name": {
                "type": "string",
                "title": "AttrName"
              },
              "validations": {
                "type": "array",
                "format": "tabs",
                "title": "Validations",
                "items": {
                  "type": "object",
                  "properties": {
                    "parameter": {
                      "$ref": "#/definitions/parameter"
                    },
                    "required": {
                      "type": "boolean",
                      "title": "Required",
                      "options": {
                        "grid_columns": 11
                      },
                    },
                    "rules": {
                      "type": "array",
                      "format": "table",
                      "items": {
                        "type": "object",
                        "properties": {
                          "rule_type": {
                            "type": "integer",
                            "title": "RuleType",
                            "enum": [
                              0
                            ],
                            "options": {
                              "enum_titles": [
                                "RuleRegexp"
                              ]
                            }
                          },
                          "expression": {
                            "type": "string",
                            "title": "Expression"
                          }
                        }
                      }
                    }
                  }
                }
              },
              "cache": {
                "type": "object",
                "title": "Cache",
                "properties": {
                  "keys": {
                    "type": "array",
                    "format": "table",
                    "title": "Keys",
                    "items": {
                      "$ref": "#/definitions/parameter"
                    },
                    "propertyOrder": 10
                  },
                  "deadline": {
                    "type": "integer",
                    "title": "Deadline",
                    "options": {
                      "grid_columns": 11
                    },
                    "propertyOrder": 30
                  },
                  "conditions": {
                    "type": "array",
                    "format": "table",
                    "title": "Conditions",
                    "items": {
                      "type": "object",
                      "properties": {
                        "parameter": {
                          "$ref": "#/definitions/parameter"
                        },
                        "cmp": {
                          "type": "integer",
                          "title": "Cmp"
                        },
                        "expect": {
                          "type": "string",
                          "title": "Expect"
                        }
                      }
                    },
                    "propertyOrder": 20
                  }
                }
              },
              "default_value": {
                "title": "DefaultValue",
                "$ref": "#/definitions/default_value"
              },
              "use_default": {
                "type": "boolean",
                "title": "UseDefault"
              },
              "batch_index": {
                "type": "integer",
                "title": "BatchIndex"
              }
            }
          },
          "propertyOrder": 300
        },
        "auth_filter": {
          "type": "string",
          "title": "AuthFilter",
          "options": {
            "grid_columns": 3
          },
          "propertyOrder": 950
        },
        "perms": {
          "type": "array",
          "format": "table",
          "title": "Perms",
          "items": {
            "type": "string",
            "title": "Plugin"
          },
          "options": {
            "grid_columns": 6
          },
          "propertyOrder": 400
        },
        "render_template": {
          "type": "object",
          "title": "RenderTemplate",
          "properties": {
            "objects": {
              "type": "array",
              "format": "tabs",
              "title": "Objects",
              "items": {
                "type": "object",
                "title": "Object",
                "properties": {
                  "name": {
                    "type": "string",
                    "title": "Name"
                  },
                  "attrs": {
                    "type": "array",
                    "format": "table",
                    "items": {
                      "type": "object",
                      "properties": {
                        "name": {
                          "type": "string",
                          "title": "Name"
                        },
                        "extract_exp": {
                          "type": "string",
                          "title": "ExtractExp"
                        }
                      }
                    }
                  },
                  "flat_attrs": {
                    "type": "boolean",
                    "title": "FlatAttrs"
                  }
                }
              }
            }
          },
          "propertyOrder": 600
        },
        "use_default": {
          "type": "boolean",
          "title": "UseDefault",
          "propertyOrder": 85
        }
      }
    }
    API
  end
end
