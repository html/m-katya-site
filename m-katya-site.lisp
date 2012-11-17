(defpackage #:m-katya-site
  (:use :cl :weblocks
        :f-underscore :anaphora :cl-config)
  (:import-from :hunchentoot #:header-in
    #:set-cookie #:set-cookie* #:cookie-in
    #:user-agent #:referer)
  (:documentation
   "A web application based on Weblocks."))

(in-package :m-katya-site)

(export '(start-m-katya-site stop-m-katya-site))

;; A macro that generates a class or this webapp

(defwebapp m-katya-site
           :prefix "/" 
           :description "m-katya-site: A new application"
           :subclasses (weblocks-twitter-bootstrap-application:twitter-bootstrap-webapp)
           :init-user-session 'm-katya-site::init-user-session
           :autostart nil                   ;; have to start the app manually
           :ignore-default-dependencies t ;; accept the defaults
           :debug t
           :dependencies (list 
                           ;(make-instance 'script-dependency :url "/pub/scripts/jquery-1.8.2.js")
                           ;(make-instance 'stylesheet-dependency :url "/pub/stylesheets/main.css")
                           (make-instance 'script-dependency :url "/pub/scripts/weblocks-jquery.js")
                           (make-instance 'script-dependency :url "/pub/scripts/jquery-seq.js")))

;; Top level start & stop scripts

(defun start-m-katya-site (&rest args)
  "Starts the application by calling 'start-weblocks' with appropriate arguments."
  (apply #'start-weblocks args)
  (start-webapp 'm-katya-site)
  (weblocks-strings-translation-app:start-weblocks-strings-translation-app :store *default-store*))

(defun stop-m-katya-site ()
  "Stops the application by calling 'stop-weblocks'."
  (stop-webapp 'm-katya-site)
  (stop-weblocks))
