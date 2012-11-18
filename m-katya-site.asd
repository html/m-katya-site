(defpackage #:m-katya-site-asd
  (:use :cl :asdf))

(in-package :m-katya-site-asd)

(defsystem m-katya-site
   :name "m-katya-site"
   :version "0.0.3"
   :maintainer ""
   :author ""
   :licence ""
   :description "m-katya-site"
   :depends-on (:weblocks :weblocks-utils :cl-config :yaclml :cl-gd :prevalence-serialized-i18n :weblocks-strings-translation-app :weblocks-twitter-bootstrap-application :weblocks-mustache-template)
   :components ((:file "m-katya-site")
     (:module conf
      :components ((:file "stores"))
      :depends-on ("m-katya-site"))
     (:module src 
      :components ((:file "init-session" :depends-on ("models" "widgets" "tinymce-textarea-presentation" "image-resize-util"))
        (:module "models" 
         :components 
         ((:file "page")
          (:file "collection")
          (:file "shop-item"))
         :depends-on ("image-resize-util"))
        (:module "widgets" 
         :components 
         ((:file "pages-grid")
          (:file "collection-grid")))
        (:file "tinymce-textarea-presentation")
        (:file "image-resize-util"))
      :depends-on ("m-katya-site" conf))))
