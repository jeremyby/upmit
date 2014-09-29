# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#

#= require jquery
#= require jquery_ujs
#= require jquery.remotipart


#= require detect_timezone
#= require jquery.detect_timezone


#= require lib/jquery.easing.1.3
#= require lib/jquery.backstretch.min
#= require lib/jquery.circliful
#= require lib/jquery.autosize.min

#= require lib/bootstrap/3.2.0/js/bootstrap.min

#= require bootstrap-editable
#= require bootstrap-editable-rails

#= require lib/detectmobilebrowser
#= require lib/owl-carousel/owl.carousel.min
#= require lib/bootstrap-slider

#= require jquery.turbolinks
#= require turbolinks

#= require nprogress
#= require nprogress-turbolinks

#= require home

#= require main
#= require goals
#= require deposit
#= require users

#= require_tree .

NProgress.configure 
  showSpinner: false
  ease: 'ease'
  speed: 500
  parent: '#np-holder'
