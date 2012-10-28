(defpackage #:m-katya-site-asd
  (:use :cl :asdf))

(in-package :m-katya-site-asd)

(defsystem m-katya-site
    :name "m-katya-site"
    :version "0.0.1"
    :maintainer ""
    :author ""
    :licence ""
    :description "m-katya-site"
    :depends-on (:weblocks)
    :components ((:file "m-katya-site")
     (:module conf
      :components ((:file "stores"))
      :depends-on ("m-katya-site"))
     (:module src 
      :components ((:file "init-session"))
      :depends-on ("m-katya-site" conf))))
