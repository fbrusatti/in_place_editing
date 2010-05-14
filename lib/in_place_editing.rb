module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        unless [:post, :put].include?(request.method) then
          return render(:text => 'Method not allowed', :status => 405)
        end
        @item = object.to_s.camelize.constantize.find(params[:id])
        @item.update_attribute(attribute, params[:value])
        render :text => CGI::escapeHTML(@item.send(attribute).to_s)
      end
    end


    # options:
    ##    relation: true/false if attribute is an object that has to be searched in a relation
    ##    class_name: name of the relation where we have to search attribute associated with
    def in_place_edit_for_extended(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        unless [:post, :put].include?(request.method) then
          return render(:text => 'Method not allowed', :status => 405)
        end
        @item = object.to_s.camelize.constantize.find(params[:id])

        @relation = options[:relation] || false
        if @relation
          @class_name = options[:class_name] || attribute
          @attribute = @class_name.to_s.camelize.constantize.find(params[:value])
        else
          @attribute = params[:value]
        end

        @item.update_attribute(attribute, @attribute)

        render :text => CGI::escapeHTML(@item.send(attribute).to_s)
      end
    end
  end
end
