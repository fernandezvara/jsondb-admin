require 'rubygems'
require 'sinatra'
require 'sinatra/contrib'
require 'jsondb'

#require_relative '../../jsondb/lib/jsondb.rb'
$db = JSONdb::Db.new('/Users/antonio/work/mundoreader/jsondb/spec/dbtest')

class JSONdbAdmin < Sinatra::Base


  set :root, File.dirname(__FILE__)
  set :static, true
  
  set :public_folder, File.join(root, "public")
  
  set :views_folder,  File.join(root, 'views')

  # helpers
  helpers do
    def link_to link_name, link_url
      "<a href=\"#{link_url}\">#{link_name}</a>"
    end


    def pagination(url_base, pages_number, actual_page = 1)

      pagination = '<ul class="pagination pagination0 pagination-sm">'
      if pages_number < 10
        pagination = pagination + "<li #{"class=\"disabled\"" if actual_page == 1}><a href=\"#{url_base}1\">«</a></li>"
        (1..pages_number).each do |p|
          pagination = pagination + "<li #{"class=\"active\"" if actual_page == p}><a href=\"#{url_base}#{p}\">#{p}</a></li>"
        end
        pagination = pagination + "<li #{"class=\"disabled\"" if actual_page == pages_number}><a href=\"#{url_base}#{pages_number}\">»</a></li>"
        pagination = pagination + "</ul>"

      else
        # pages > 10
      end
      return pagination
    end


    def input_for_field(field)

      if field.type == "Bool"

        html = <<EOF
<div class="form-group">
  <label for="#{field.name}" class="control-label">#{field.name}</label>
  <select class="form-control" id="record_#{field.name}" name="record[#{field.name}]">
    <option>true</option>
    <option>false</option>
  </select>
</div>
EOF

      else

        case field.type
        when "String"
          input_type = "text"
        when "Integer", "Float", "Fixnum"
          input_type = "number"
        when "Time"
          input_type = "datetime"
        end

        html = <<EOF
<div class="form-group">
  <label class="control-label" for="#{field.name}">#{field.name}</label>
  <input class="form-control" id="record_#{field.name}" name="record[#{field.name}]" type="#{input_type}" value="#{ field.default if field.default }"  #{"required" if field.nullable == false } />
</div>
EOF
      end

      return html
    end

    def show_save_alert?
      $db.table_names.each do |n|
        return true if $db.table(n).persisted == false
      end
      return false
    end

    def fill_field_with_params(table_name, params, name = nil)

      field_name = name || params[:field][:name]

      $db.table(table_name).field(field_name).type = params[:field][:type]
      if params[:field][:nullable] == "on"
        puts "null = true"
        $db.table(table_name).field(field_name).nullable = true 
      else
        puts "null = false"
        $db.table(table_name).field(field_name).nullable = false
      end
      if params[:field][:default] == ""
        $db.table(table_name).field(field_name).default = nil
      else
        case params[:field][:type]
        when "Fixnum", "Integer"
          default = params[:field][:default].to_i
        when "Float"
          default = params[:field][:default].to_f
        when "String", "Date"
          default = params[:field][:default].to_s
        when "Bool"
          default = true if params[:field][:default] == "true"
          default = false if params[:field][:default] == "false"
        end

        $db.table(table_name).field(field_name).default = default
      end
    end
  end # /helpers

  get '/' do 
    @tables =  JSONdb.tables
    erb :tables #, locals: { tables: JSONdb.tables }
  end

  get "/table/:name" do
    @page = 1
    @table_name = params[:name]
    @table = $db.table(@table_name)
    if @table.class.to_s == "JSONdb::Table"
      @total_pages = @table.records.total_pages
      @records = @table.records.page(@page)
      erb :table
    else
      erb :table_not_found
    end
  end

  get "/table/:name/page/:page" do
    @page = params[:page].to_i
    @table_name = params[:name]
    @table = $db.table(@table_name)
    if @table.class.to_s == "JSONdb::Table"
      @total_pages = @table.records.total_pages
      @records = @table.records.page(@page)
      erb :table
    else
      erb :table_not_found
    end
  end

  get "/table/:name/fields" do
    @table_name = params[:name]
    @table = $db.table(@table_name)
    if @table.class.to_s == "JSONdb::Table"
      @fields = @table.fields
      erb :fields
    else
      erb :table_not_found
    end
  end

  post "/table/:name/fields" do
    puts params.inspect
    $db.table(params[:name]).create_field(params[:field][:name])
    fill_field_with_params(params[:name], params)
  end

  post "/table/:name/field/:id" do
    puts params.inspect
    fill_field_with_params(params[:name], params, params[:id])
  end

  # get from json
  get "/table/:name/field/:id" do
    @field = $db.table(params[:name]).field(params[:id])
    json @field.to_hash
  end

  post "/table/:name/record" do
    @table = $db.table(params[:name])
    puts params[:record].inspect

    record = @table.new_record
    record.data_from_hash(params[:record])
    @table.insert_record(record)
  end

  # get from json
  get "/table/:name/record/:id" do
    @record = $db.table(params[:name]).record(params[:id].to_i)
    json @record.to_hash
  end

  post "/table/:name/record/:id" do
    table = $db.table(params[:name])
    record= table.record(params[:id].to_i)
    puts params[:record].inspect

    record.data_from_hash(params[:record])
    table.update_record(record)
  end

  delete "/table/:name/record/:id" do
    table = $db.table(params[:name])
    record= table.record(params[:id].to_i)
    table.delete_record(record)
  end

  get "/persist" do
    $db.persist
  end

end

