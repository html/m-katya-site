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
   :depends-on (:weblocks :weblocks-utils :cl-config :yaclml :cl-gd)
   :components ((:file "m-katya-site")
     (:module conf
      :components ((:file "stores"))
      :depends-on ("m-katya-site"))
     (:module src 
      :components ((:file "init-session" :depends-on ("models" "widgets" "tinymce-textarea-presentation" "image-resize-util"))
        (:module "models" 
         :components 
         ((:file "page")
          (:file "collection"))
         :depends-on ("image-resize-util"))
        (:module "widgets" 
         :components ((:file "pages-grid")))
        (:file "tinymce-textarea-presentation")
        (:file "image-resize-util"))
      :depends-on ("m-katya-site" conf))))
