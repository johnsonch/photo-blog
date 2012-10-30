class WelcomeController < ApplicationController
  require 'flickr'
  def index
    flickr = Flickr.new('89088b8f6156cda02e3cdb36718a4f6e') 
    user = flickr.users('johnsonch@rocketmail.com')
    @photos = user.photos
  end
end
