class ApisController < ApplicationController
  before_action :set_api, only: [:edit, :update, :show, :destroy]
  before_action :set_schema, only: [:new, :edit]

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
    begin
      @api.destroy!
      flash.notice = "Api #{@api.id}-#{@api.name} destroyed!"
    rescue => exp
      log(exp, 'apis#destroy')
      flash.alert = exp.message
    end

    redirect_to apis_url
  end

  private

  def set_api
    @api = Api.find_by(params.slice(:id))
  end

  def server_params
    api = params[:api]
    [:ip_access_control, :default_value, :render_template].each do |x|
      if api[x].blank? || api[x].as_json.all?{|_, v| v.blank?}
        api[x] = nil
      end
    end
    if api[:nodes].present?
      api[:nodes].each do |x|
        x[:cache] = nil if (x[:cache] || {})[:keys].blank?
        if x[:default_value].blank? || x[:default_value].as_json.all?{|_, v| v.blank?}
          x[:default_value] = nil
        end
      end
    end

    params.require(:api)
  end

  def set_schema
    @api_schema = <<-API
    {
      "type": "object",
      "format": "grid",
      "definitions": {
        "parameter": #{JsonSchema.parameter},
        "pair_value": #{JsonSchema.pair_value},
        "default_value": #{JsonSchema.default_value}
      },
      "properties": {
        "name": {
          "type": "string",
          "title": "Name",
          "propertyOrder": 20,
          "minLength": 5
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
            "GET", "POST", "PUT", "DELETE", "*", ""
          ],
          "propertyOrder": 40
        },
        "domain": {
          "type": "string",
          "title": "Domain",
          "propertyOrder": 30
        },
        "status": #{JsonSchema.status},
        "ip_access_control": {
          "type": "object",
          "title": "IpAccessControl",
          "description": "通配符只支持`*`",
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
              "cluster_id": #{JsonSchema.cluster_id},
              "url_rewrite": {
                "type": "string",
                "title": "urlRewrite",
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
                  "conditions": #{JsonSchema.conditions}
                },
                "required": [
                  "keys", "deadline"
                ]
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
            },
            "required": [
              "cluster_id", "use_default"
            ]
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
      },
      "required": [
        "method", "status", "use_default"
      ]
    }
    API
  end
end
